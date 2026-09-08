import 'package:hive/hive.dart';
import '../../domain/entities/sale_item.dart';

part 'sale_item_model.g.dart';

@HiveType(typeId: 2)
class SaleItemModel extends SaleItem {
  @override
  @HiveField(0)
  final String productName;
  @override
  @HiveField(1)
  final String barcode;
  @override
  @HiveField(2)
  final double unitPrice;
  @override
  @HiveField(3)
  final int quantity;

  const SaleItemModel({
    required this.productName,
    required this.barcode,
    required this.unitPrice,
    required this.quantity,
  }) : super(
          productName: productName,
          barcode: barcode,
          unitPrice: unitPrice,
          quantity: quantity,
        );

  factory SaleItemModel.fromEntity(SaleItem item) => SaleItemModel(
        productName: item.productName,
        barcode: item.barcode,
        unitPrice: item.unitPrice,
        quantity: item.quantity,
      );
}
