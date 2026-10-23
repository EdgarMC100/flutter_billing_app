import 'package:hive/hive.dart';
import 'package:billing_app/features/report/data/models/sale_model.dart';

Future<void> main(List<String> args) async {
  final dirPath = args.isNotEmpty ? args.first : '.';
  Hive.init(dirPath);
  Hive.registerAdapter(SaleLineItemModelAdapter());
  Hive.registerAdapter(SaleModelAdapter());
  final box = await Hive.openBox<SaleModel>('sales');
  print('Total sales: ${box.length}');
  final sales = box.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  for (final s in sales.take(10)) {
    print('${s.createdAt} | \$${s.total} | ${s.itemsCount} items | ${s.lineItems.length} lines');
    for (final li in s.lineItems) {
      print('    ${li.productName} x${li.quantity} @ \$${li.unitPrice} = \$${li.total}');
    }
  }
  await box.close();
}
