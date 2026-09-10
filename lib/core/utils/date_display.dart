import 'package:intl/intl.dart';

/// Shared formatting for the two-line "date + time" style used across the app
/// (e.g. the sales history list and a sale's detail page).
///
/// Localization stays in the presentation layer: callers pass an already
/// resolved [todayLabel] rather than this util reaching for `AppLocalizations`,
/// matching the convention in [PrinterHelper].
class DateDisplay {
  const DateDisplay._();

  static final DateFormat _date = DateFormat('dd-MM-yyyy');
  static final DateFormat _time = DateFormat('hh:mm a');

  /// True when [dt] falls on the current calendar day.
  static bool isToday(DateTime dt) {
    final now = DateTime.now();
    return dt.year == now.year && dt.month == now.month && dt.day == now.day;
  }

  /// [todayLabel] (a localized "Today") when [dt] is the current calendar day,
  /// otherwise the calendar date (dd-MM-yyyy).
  static String dateLabel(DateTime dt, String todayLabel) =>
      isToday(dt) ? todayLabel : _date.format(dt);

  /// Time of day, e.g. "03:45 PM".
  static String timeLabel(DateTime dt) => _time.format(dt);
}
