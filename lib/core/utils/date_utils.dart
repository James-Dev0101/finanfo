import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static Map<DateTime, List<T>> groupByDate<T>(
    List<T> items,
    DateTime Function(T) getDate,
  ) {
    final grouped = <DateTime, List<T>>{};
    for (final item in items) {
      final date = getDate(item);
      final key = DateTime(date.year, date.month, date.day);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return Map.fromEntries(
      grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  static List<DateTime> lastNMonths(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) {
      final month = now.month - i;
      final year = now.year + (month <= 0 ? -1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;
      return DateTime(year, adjustedMonth, 1);
    }).reversed.toList();
  }

  static String formatRange(DateTime start, DateTime end) {
    final fmt = DateFormat('MMM dd');
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  static DateTime startOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month, 1);
  }

  static DateTime endOfMonth([DateTime? date]) {
    final d = date ?? DateTime.now();
    return DateTime(d.year, d.month + 1, 0, 23, 59, 59, 999);
  }
}
