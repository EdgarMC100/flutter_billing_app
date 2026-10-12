import 'dart:io';
import 'package:hive/hive.dart';
import 'package:billing_app/features/product/data/models/product_model.dart';

Future<void> main() async {
  final dir = Directory(
      '/private/var/folders/nf/zvszl_sx2hl4nx2chkgj_1lh0000gn/T/opencode');
  Hive.init(dir.path);
  Hive.registerAdapter(ProductModelAdapter());
  final box = await Hive.openBox<ProductModel>('products');
  print('Total products: ${box.length}\n');
  for (final p in box.values) {
    print('${p.name} | barcode: ${p.barcode} | price: \$${p.price} | stock: ${p.stock}');
  }
  await box.close();
}



