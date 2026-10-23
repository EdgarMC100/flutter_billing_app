// One-time migration: rewrites a `sales` Hive box from the OLD on-disk schema
// (the one shipped in the earlier installed build) to the CURRENT schema, so
// the app can open it again without discarding sales history.
//
// OLD  Sale         : [0] id, [1] createdAt, [2] lineItems, [3] total
//      SaleLineItem : [0] productName, [1] barcode, [2] unitPrice, [3] quantity
// NEW  Sale         : [0] id, [1] createdAt, [2] total, [3] itemsCount, [4] lineItems
//      SaleLineItem : [0] productName, [1] quantity, [2] unitPrice, [3] total
//
// The old per-line barcode has nowhere to go in the new schema, so it is
// dropped (this was the explicitly approved trade-off). Everything else is
// preserved: product name, quantity, unit price, sale total, and timestamp.
// Fields the new schema requires but the old one never stored are recomputed
// using the app's own formulas:
//   line total = unitPrice * quantity   (cart_item.dart)
//   itemsCount = sum of quantities      (billing_state.dart)
//
// Usage: dart run tool/migrate_sales.dart <inputDir> <outputDir>
import 'package:hive/hive.dart';

import 'package:billing_app/features/report/data/models/sale_model.dart';

/// Read-only adapter that captures the raw stored field map (index -> value)
/// instead of casting to the current model, so OLD data can be inspected even
/// though its layout differs.
class RawMapAdapter extends TypeAdapter<Map<int, dynamic>> {
  RawMapAdapter(this.typeId);
  @override
  final int typeId;

  @override
  Map<int, dynamic> read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    return <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
  }

  @override
  void write(BinaryWriter writer, Map<int, dynamic> obj) {
    throw UnimplementedError('read-only adapter');
  }
}

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run tool/migrate_sales.dart <inputDir> <outputDir>');
    return;
  }
  final inputDir = args[0];
  final outputDir = args[1];

  // ---- Phase 1: read OLD data using raw adapters ----
  Hive.init(inputDir);
  Hive.registerAdapter(RawMapAdapter(2)); // SaleLineItemModel typeId
  Hive.registerAdapter(RawMapAdapter(3)); // SaleModel typeId

  final inBox = await Hive.openBox<Map<int, dynamic>>('sales');
  final rawEntries = <dynamic, Map<int, dynamic>>{};
  for (final key in inBox.keys) {
    final value = inBox.get(key);
    if (value != null) rawEntries[key] = value;
  }
  await inBox.close();
  print('Read ${rawEntries.length} sales from $inputDir');

  // ---- Convert OLD -> NEW in memory ----
  var lineBarcodeDropped = 0;
  var totalMismatch = 0;
  final converted = <dynamic, SaleModel>{};

  for (final entry in rawEntries.entries) {
    final old = entry.value;
    final id = old[0] as String;
    final createdAt = old[1] as DateTime;
    final oldLineItems = (old[2] as List).cast<dynamic>();
    final saleTotal = (old[3] as num).toDouble();

    final newLineItems = <SaleLineItemModel>[];
    var itemsCount = 0;
    var computedSaleTotal = 0.0;

    for (final rawItem in oldLineItems) {
      final item = (rawItem as Map).cast<dynamic, dynamic>();
      final name = item[0] as String;
      final unitPrice = (item[2] as num).toDouble();
      final quantity = item[3] as int;
      final lineTotal = unitPrice * quantity;

      if (item.containsKey(1) && item[1] != null) lineBarcodeDropped++;

      newLineItems.add(SaleLineItemModel(
        productName: name,
        quantity: quantity,
        unitPrice: unitPrice,
        total: lineTotal,
      ));
      itemsCount += quantity;
      computedSaleTotal += lineTotal;
    }

    // The original sale total is authoritative; flag if recomputed lines
    // disagree (they shouldn't — billing always derived total from lines).
    if ((computedSaleTotal - saleTotal).abs() > 0.005) totalMismatch++;

    converted[entry.key] = SaleModel(
      id: id,
      createdAt: createdAt,
      total: saleTotal,
      itemsCount: itemsCount,
      lineItems: newLineItems,
    );
  }

  // ---- Phase 2: swap in the REAL adapters and write to a fresh directory ----
  Hive.registerAdapter(SaleLineItemModelAdapter(), override: true);
  Hive.registerAdapter(SaleModelAdapter(), override: true);
  Hive.init(outputDir);

  final outBox = await Hive.openBox<SaleModel>('sales');
  await outBox.clear();
  for (final entry in converted.entries) {
    await outBox.put(entry.key, entry.value);
  }
  await outBox.close();

  print('Wrote ${converted.length} sales to $outputDir/sales.hive');
  print('Line-item barcodes dropped (old field): $lineBarcodeDropped');
  print('Sales whose recomputed line sum != stored total: $totalMismatch');
}
