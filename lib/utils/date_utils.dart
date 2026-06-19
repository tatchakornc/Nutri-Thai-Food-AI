import 'package:intl/intl.dart';

/// Date utility functions used across the app
class DateUtils {
  DateUtils._();

  static final _dateFormat = DateFormat('yyyy-MM-dd');
  static final _displayFormat = DateFormat('d MMMM yyyy', 'th');
  static final _shortFormat = DateFormat('d MMM', 'th');

  /// Today as yyyy-MM-dd string
  static String todayString() => _dateFormat.format(DateTime.now());

  /// Format DateTime as yyyy-MM-dd
  static String formatDate(DateTime dt) => _dateFormat.format(dt);

  /// Thai display format: "2 มิถุนายน 2567"
  static String displayDate(DateTime dt) => _displayFormat.format(dt);

  /// Short Thai format: "2 มิ.ย."
  static String shortDate(DateTime dt) => _shortFormat.format(dt);

  /// Parse yyyy-MM-dd to DateTime
  static DateTime parseDate(String dateStr) => _dateFormat.parse(dateStr);

  /// Check if two DateTimes are on the same day
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Thai greeting based on time of day
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'สวัสดีตอนเช้า';
    if (hour < 17) return 'สวัสดีตอนบ่าย';
    return 'สวัสดีตอนเย็น';
  }
}
