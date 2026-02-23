/// Shared date formatting utilities
class DateFormatUtils {
  DateFormatUtils._();

  /// Format DateTime as 'yyyy-MM-dd' string key for provider lookup
  static String formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
