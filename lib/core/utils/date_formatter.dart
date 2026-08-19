
class DateFormatter {
  static final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  /// Format DateTime to readable string e.g. "Aug 20, 2026"
  static String formatDate(DateTime? date) {
    if (date == null) return 'No due date';
    final year = date.year;
    final month = _months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    return '$month $day, $year';
  }

  /// Format DateTime to readable date + time e.g. "Aug 20, 2026 14:30"
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    final dateStr = formatDate(date);
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$dateStr • $hour:$minute';
  }

  /// Convert String ISO / Date string to DateTime safely
  static DateTime? parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      if (value.trim().isEmpty) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Returns relative time description e.g., "Overdue", "Due Today", "Due Tomorrow", or "Aug 25"
  static String getDueStatus(DateTime? date) {
    if (date == null) return 'No due date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final difference = target.difference(today).inDays;
    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due Today';
    } else if (difference == 1) {
      return 'Due Tomorrow';
    } else {
      return 'Due in $difference days';
    }
  }

  /// Convert DateTime to standard ISO 8601 String for Firestore storing
  static String toIsoString(DateTime date) {
    return date.toIso8601String();
  }
}
