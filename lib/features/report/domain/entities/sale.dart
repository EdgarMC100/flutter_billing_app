import 'package:equatable/equatable.dart';

class SaleLineItem extends Equatable {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double total;

  const SaleLineItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  @override
  List<Object> get props => [productName, quantity, unitPrice, total];
}

class Sale extends Equatable {
  final String id;
  final DateTime createdAt;
  final double total;
  final int itemsCount;
  final List<SaleLineItem> lineItems;

  const Sale({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.itemsCount,
    this.lineItems = const [],
  });

  @override
  List<Object> get props => [id, createdAt, total, itemsCount, lineItems];
}
