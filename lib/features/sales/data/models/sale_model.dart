import 'package:hive/hive.dart';
import '../../domain/entities/sale.dart';
import '../../domain/entities/sale_item.dart';
import 'sale_item_model.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 3)
class SaleModel extends Sale {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final DateTime dateTime;
  @override
  @HiveField(2)
  final List<SaleItemModel> items;
  @override
  @HiveField(3)
  final double total;

  const SaleModel({
    required this.id,
    required this.dateTime,
    required this.items,
    required this.total,
  }) : super(id: id, dateTime: dateTime, items: items, total: total);

  factory SaleModel.fromEntity(Sale sale) => SaleModel(
        id: sale.id,
        dateTime: sale.dateTime,
        items: sale.items.map((i) => SaleItemModel.fromEntity(i)).toList(),
        total: sale.total,
      );

  Sale toEntity() => Sale(
        id: id,
        dateTime: dateTime,
        items: List<SaleItem>.from(items),
        total: total,
      );
}
