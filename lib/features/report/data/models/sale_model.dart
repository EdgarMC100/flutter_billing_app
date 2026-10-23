import 'package:hive/hive.dart';
import '../../domain/entities/sale.dart';

part 'sale_model.g.dart'; // Hive generator

@HiveType(typeId: 2)
class SaleLineItemModel extends SaleLineItem {
  @override
  @HiveField(0)
  final String productName;
  @override
  @HiveField(1)
  final int quantity;
  @override
  @HiveField(2)
  final double unitPrice;
  @override
  @HiveField(3)
  final double total;

  const SaleLineItemModel({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  }) : super(
          productName: productName,
          quantity: quantity,
          unitPrice: unitPrice,
          total: total,
        );

  factory SaleLineItemModel.fromEntity(SaleLineItem item) {
    return SaleLineItemModel(
      productName: item.productName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      total: item.total,
    );
  }
}

@HiveType(typeId: 3)
class SaleModel extends Sale {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final DateTime createdAt;
  @override
  @HiveField(2)
  final double total;
  @override
  @HiveField(3)
  final int itemsCount;
  @override
  @HiveField(4)
  final List<SaleLineItemModel> lineItems;

  const SaleModel({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.itemsCount,
    this.lineItems = const [],
  }) : super(
          id: id,
          createdAt: createdAt,
          total: total,
          itemsCount: itemsCount,
          lineItems: lineItems,
        );

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      createdAt: sale.createdAt,
      total: sale.total,
      itemsCount: sale.itemsCount,
      lineItems: sale.lineItems.map(SaleLineItemModel.fromEntity).toList(),
    );
  }
}
