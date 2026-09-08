import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String productName;
  final String barcode;
  final double unitPrice;
  final int quantity;

  const SaleItem({
    required this.productName,
    required this.barcode,
    required this.unitPrice,
    required this.quantity,
  });
  double get total => unitPrice * quantity;
  @override
  List<Object> get props => [productName, barcode, unitPrice, quantity];
}