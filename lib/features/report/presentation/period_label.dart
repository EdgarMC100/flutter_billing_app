import 'package:intl/intl.dart';

import '../domain/sales_aggregator.dart';

/// Localized label for a period start date, e.g. "Tue, Oct 21, 2026" (day),
/// "Oct 1–15, 2026" (biweekly), "October 2026" (month).
///
/// [short] produces a compact variant suitable for chart axis ticks.
String periodLabel(
    DateTime start, SalesGrouping grouping, String locale,
    {bool short = false}) {
  switch (grouping) {
    case SalesGrouping.day:
      return short
          ? DateFormat('d MMM', locale).format(start)
          : DateFormat.EEEE(locale)
              .add_d()
              .add_MMM()
              .add_y()
              .format(start);
    case SalesGrouping.biweekly:
      final end = SalesAggregator.periodEnd(start, SalesGrouping.biweekly)
          .subtract(const Duration(days: 1));
      if (short) {
        return DateFormat('d', locale).format(start);
      }
      return '${DateFormat('d MMM', locale).format(start)}–'
          '${DateFormat('d', locale).format(end)}, '
          '${DateFormat.y(locale).format(start)}';
    case SalesGrouping.month:
      return short
          ? DateFormat('MMM', locale).format(start)
          : DateFormat.yMMMM(locale).format(start);
  }
}

/// Clock time of a sale within its period. Day/biweekly views only need the
/// time of day, while the month view also shows the day to disambiguate.
String saleTimeLabel(DateTime createdAt, SalesGrouping grouping, String locale) {
  final time = DateFormat.Hm(locale).format(createdAt);
  if (grouping == SalesGrouping.month) {
    return '${DateFormat.MMMd(locale).format(createdAt)}, $time';
  }
  return time;
}
