import 'package:equatable/equatable.dart';
import 'entities/sale.dart';

/// How sales are bucketed in the report: by calendar day, by semi-monthly
/// period (1st–15th / 16th–end of month, see [SalesAggregator]), or by
/// calendar month.
enum SalesGrouping { day, biweekly, month }

/// One aggregated bucket of [SalesGrouping] sales.
class SalesPeriod extends Equatable {
  /// Start of the period, inclusive, normalized to local midnight.
  final DateTime start;

  /// Total revenue of the period.
  final double total;

  /// Number of sales recorded in the period.
  final int saleCount;

  /// Number of individual items sold in the period.
  final int itemsCount;

  const SalesPeriod({
    required this.start,
    required this.total,
    required this.saleCount,
    required this.itemsCount,
  });

  @override
  List<Object> get props => [start, total, saleCount, itemsCount];
}

class SalesAggregator {
  const SalesAggregator._();

  /// Buckets [sales] by [grouping] and returns one [SalesPeriod] per
  /// non-empty bucket, sorted by period start ascending (oldest first).
  ///
  /// "Biweekly" here means semi-monthly: the 1st–15th and the 16th through
  /// the last day of each month.
  static List<SalesPeriod> aggregate(
      List<Sale> sales, SalesGrouping grouping) {
    final buckets = <DateTime, List<Sale>>{};
    for (final sale in sales) {
      final key = periodStart(sale.createdAt, grouping);
      buckets.putIfAbsent(key, () => []).add(sale);
    }

    final keys = buckets.keys.toList()..sort();
    return keys
        .map((start) => SalesPeriod(
              start: start,
              total: buckets[start]!
                  .fold(0.0, (sum, sale) => sum + sale.total),
              saleCount: buckets[start]!.length,
              itemsCount: buckets[start]!
                  .fold(0, (sum, sale) => sum + sale.itemsCount),
            ))
        .toList();
  }

  /// Start (local midnight) of the period containing [date] for [grouping].
  static DateTime periodStart(DateTime date, SalesGrouping grouping) {
    switch (grouping) {
      case SalesGrouping.day:
        return DateTime(date.year, date.month, date.day);
      case SalesGrouping.biweekly:
        // Semi-monthly: first half starts on the 1st, second on the 16th.
        return DateTime(date.year, date.month, date.day <= 15 ? 1 : 16);
      case SalesGrouping.month:
        return DateTime(date.year, date.month);
    }
  }

  /// End of the period starting at [start] (exclusive), used for labels and
  /// "to" dates. Mirrors the buckets built by [periodStart].
  static DateTime periodEnd(DateTime start, SalesGrouping grouping) {
    switch (grouping) {
      case SalesGrouping.day:
        return start.add(const Duration(days: 1));
      case SalesGrouping.biweekly:
        if (start.day == 1) {
          return DateTime(start.year, start.month, 16);
        }
        // Day 16: next period starts on the 1st of the following month.
        return DateTime(start.year, start.month + 1, 1);
      case SalesGrouping.month:
        return DateTime(start.year, start.month + 1, 1);
    }
  }
}
