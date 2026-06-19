/// Formats ISO date strings returned by TMDB (`"2008-01-20"`).
extension DateLabelX on String {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Medium date, e.g. `"Jan 20, 2008"`; `null` when not a parseable
  /// `YYYY-MM-DD` string.
  String? get mediumDate {
    final parts = split('-');
    if (parts.length < 3) return null;
    final year = parts[0];
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year.length != 4 || month == null || day == null) return null;
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    return '${_months[month - 1]} $day, $year';
  }
}
