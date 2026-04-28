/// Helpers for ISO date strings returned by TMDB (`"2024-08-21"`).
extension YearX on String {
  /// Returns the leading 4-digit year, or `null` if not parseable.
  String? get year {
    if (length < 4) return null;
    final candidate = substring(0, 4);
    if (int.tryParse(candidate) == null) return null;
    return candidate;
  }
}
