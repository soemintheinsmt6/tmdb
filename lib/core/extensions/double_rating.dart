/// Formatters for TMDB rating values (0–10 floats).
extension RatingX on double {
  /// Formats `7.4567` → `"7.5"`. Always one decimal digit.
  String get rating => toStringAsFixed(1);

  /// Formats `7.4567` → `"75%"` (TMDB user score rendered as percentage).
  String get ratingPercent => '${(this * 10).round()}%';
}
