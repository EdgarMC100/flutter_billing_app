// Verifies a migrated `sales` box against the original OLD-format box:
// sale count, per-sale totals, timestamps, ids, and line-item
// name/quantity/unitPrice must all match. Reports any drift.
//
// Usage: dart run tool/verify_sales_migration.dart <oldDir> <newDir>
import 'package:hive/hive.dart';

import 'package:billing_app/features/report/data/models/sale_model.dart';

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
  void write(BinaryWriter writer, Map<int, dynamic> obj) =>
      throw UnimplementedError();
}

Future<void> main(List<String> args) async {
  if (args.length < 2) {
    print('Usage: dart run tool/verify_sales_migration.dart <oldDir> <newDir>');
    return;
  }

  // Read OLD (raw).
  Hive.init(args[0]);
  Hive.registerAdapter(RawMapAdapter(2));
  Hive.registerAdapter(RawMapAdapter(3));
  final oldBox = await Hive.openBox<Map<int, dynamic>>('sales');
  final old = <dynamic, Map<int, dynamic>>{};
  for (final k in oldBox.keys) {
    final v = oldBox.get(k);
    if (v != null) old[k] = v;
  }
  await oldBox.close();

  // Read NEW (real adapter) — override the raw ones.
  Hive.registerAdapter(SaleLineItemModelAdapter(), override: true);
  Hive.registerAdapter(SaleModelAdapter(), override: true);
  Hive.init(args[1]);
  final newBox = await Hive.openBox<SaleModel>('sales');
  final newer = <dynamic, SaleModel>{};
  for (final k in newBox.keys) {
    final v = newBox.get(k);
    if (v != null) newer[k] = v;
  }
  await newBox.close();

  final problems = <String>[];
  if (old.length != newer.length) {
    problems.add('COUNT: old=${old.length} new=${newer.length}');
  }

  double oldSum = 0, newSum = 0;
  for (final key in old.keys) {
    final o = old[key]!;
    final n = newer[key];
    if (n == null) {
      problems.add('MISSING sale $key in new box');
      continue;
    }
    final oTotal = (o[3] as num).toDouble();
    oldSum += oTotal;
    newSum += n.total;
    if ((oTotal - n.total).abs() > 0.005) {
      problems.add('TOTAL $key: old=$oTotal new=${n.total}');
    }
    if (o[0] != n.id) problems.add('ID $key: old=${o[0]} new=${n.id}');
    if (o[1] != n.createdAt) {
      problems.add('DATE $key: old=${o[1]} new=${n.createdAt}');
    }

    final oItems = (o[2] as List);
    if (oItems.length != n.lineItems.length) {
      problems.add('LINECOUNT $key: old=${oItems.length} new=${n.lineItems.length}');
      continue;
    }
    var qty = 0;
    for (var i = 0; i < oItems.length; i++) {
      final oi = (oItems[i] as Map).cast<dynamic, dynamic>();
      final ni = n.lineItems[i];
      final name = oi[0] as String;
      final unit = (oi[2] as num).toDouble();
      final quantity = oi[3] as int;
      qty += quantity;
      if (ni.productName != name) {
        problems.add('NAME $key[$i]: old=$name new=${ni.productName}');
      }
      if (ni.quantity != quantity) {
        problems.add('QTY $key[$i]: old=$quantity new=${ni.quantity}');
      }
      if ((ni.unitPrice - unit).abs() > 0.005) {
        problems.add('PRICE $key[$i]: old=$unit new=${ni.unitPrice}');
      }
      if ((ni.total - unit * quantity).abs() > 0.005) {
        problems.add('LINETOTAL $key[$i]: ${ni.total} != $unit*$quantity');
      }
    }
    if (n.itemsCount != qty) {
      problems.add('ITEMSCOUNT $key: new=${n.itemsCount} expected=$qty');
    }
  }

  print('Old sales: ${old.length}   New sales: ${newer.length}');
  print('Old total sum: \$${oldSum.toStringAsFixed(2)}');
  print('New total sum: \$${newSum.toStringAsFixed(2)}');
  if ((oldSum - newSum).abs() > 0.005) {
    problems.add('GRAND TOTAL drift: ${oldSum} vs $newSum}');
  }

  if (problems.isEmpty) {
    print('\nPASS: all sales, totals, dates, ids and line items verified.');
  } else {
    print('\nFAIL: ${problems.length} problem(s):');
    for (final p in problems) {
      print('  - $p');
    }
  }
}
