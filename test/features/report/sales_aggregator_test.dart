import 'package:billing_app/features/report/domain/entities/sale.dart';
import 'package:billing_app/features/report/domain/sales_aggregator.dart';
import 'package:flutter_test/flutter_test.dart';

Sale sale(DateTime createdAt,
    {double total = 10, int itemsCount = 1, String? id}) {
  return Sale(
    id: id ?? 'id-${createdAt.microsecondsSinceEpoch}',
    createdAt: createdAt,
    total: total,
    itemsCount: itemsCount,
  );
}

void main() {
  group('SalesAggregator.aggregate', () {
    test('groups sales by calendar day', () {
      final sales = [
        sale(DateTime(2026, 10, 21, 9, 30), total: 12.5, itemsCount: 2),
        sale(DateTime(2026, 10, 21, 18, 0), total: 7.5, itemsCount: 1),
        sale(DateTime(2026, 10, 22, 12, 0), total: 20, itemsCount: 3),
      ];

      final periods = SalesAggregator.aggregate(sales, SalesGrouping.day);

      expect(periods, hasLength(2));
      expect(periods.first.start, DateTime(2026, 10, 21));
      expect(periods.first.total, 20);
      expect(periods.first.saleCount, 2);
      expect(periods.first.itemsCount, 3);
      expect(periods.last.start, DateTime(2026, 10, 22));
      expect(periods.last.total, 20);
    });

    test('groups sales into semi-monthly periods (1-15 / 16-end)', () {
      final sales = [
        sale(DateTime(2026, 10, 1, 8, 0), total: 10),
        sale(DateTime(2026, 10, 15, 23, 59), total: 15),
        sale(DateTime(2026, 10, 16, 0, 0), total: 20),
        sale(DateTime(2026, 10, 31, 12, 0), total: 5),
      ];

      final periods =
          SalesAggregator.aggregate(sales, SalesGrouping.biweekly);

      expect(periods, hasLength(2));
      expect(periods.first.start, DateTime(2026, 10, 1));
      expect(periods.first.total, 25);
      expect(periods.first.saleCount, 2);
      expect(periods.last.start, DateTime(2026, 10, 16));
      expect(periods.last.total, 25);
      expect(periods.last.saleCount, 2);
    });

    test('second half of February ends at month end in a leap year', () {
      final sales = [
        sale(DateTime(2028, 2, 29, 12, 0), total: 30),
      ];

      final periods =
          SalesAggregator.aggregate(sales, SalesGrouping.biweekly);

      expect(periods.single.start, DateTime(2028, 2, 16));
      expect(SalesAggregator.periodEnd(
              periods.single.start, SalesGrouping.biweekly),
          DateTime(2028, 3, 1));
    });

    test('groups sales by calendar month across year boundary', () {
      final sales = [
        sale(DateTime(2026, 12, 31, 23, 0), total: 100),
        sale(DateTime(2027, 1, 1, 1, 0), total: 5),
      ];

      final periods = SalesAggregator.aggregate(sales, SalesGrouping.month);

      expect(periods, hasLength(2));
      expect(periods.first.start, DateTime(2026, 12));
      expect(periods.first.total, 100);
      expect(periods.last.start, DateTime(2027, 1));
      expect(periods.last.total, 5);
    });

    test('returns periods sorted oldest first', () {
      final sales = [
        sale(DateTime(2026, 10, 22), total: 1),
        sale(DateTime(2026, 10, 20), total: 2),
        sale(DateTime(2026, 10, 21), total: 3),
      ];

      final periods = SalesAggregator.aggregate(sales, SalesGrouping.day);

      expect(periods.map((p) => p.start).toList(),
          [DateTime(2026, 10, 20), DateTime(2026, 10, 21), DateTime(2026, 10, 22)]);
    });

    test('returns empty list when there are no sales', () {
      expect(SalesAggregator.aggregate([], SalesGrouping.day), isEmpty);
    });
  });
}
