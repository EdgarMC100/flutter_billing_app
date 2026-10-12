import 'dart:io';
import 'package:hive/hive.dart';
import 'package:billing_app/features/product/data/models/product_model.dart';

const otherProducts = [
  'Notebook Magic Line',
  'Libro "El Secreto Del Exito"',
  'Desodorante Neutro 65ml',
  'Resistol Super Heroes',
  'Glue Print',
  'Gel Antibacterial',
  'Jalea Real',
  'Cepillo Diente Pza',
];

Future<void> main() async {
  final dir = Directory(
      '/private/var/folders/nf/zvszl_sx2hl4nx2chkgj_1lh0000gn/T/opencode');
  Hive.init(dir.path);
  Hive.registerAdapter(ProductModelAdapter());
  final box = await Hive.openBox<ProductModel>('products');
  print('Before: ${box.length}');
  final toDelete = <dynamic>[];
  for (final e in box.toMap().entries) {
    if (otherProducts.any((n) => e.value.name.trim().startsWith(n) || n.startsWith(e.value.name.trim()))) {
      toDelete.add(e.key);
      print('Deleting: ${e.value.name} (${e.value.barcode})');
    }
  }
  await box.deleteAll(toDelete);
  print('After: ${box.length}');
  await box.close();
  await Hive.close();
}
