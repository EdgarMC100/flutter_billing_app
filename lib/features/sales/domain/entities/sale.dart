import 'package:equatable/equatable.dart';
import 'sale_item.dart';

class Sale extends Equatable {
  final String id;
  final DateTime dateTime;
  final List<SaleItem> items;
  final double total;

  const Sale({
    required this.id,
    required this.dateTime,
    required this.items,
    required this.total,
  });

  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object> get props => [id, dateTime, items, total];
}
