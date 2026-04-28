/// Formatters for runtime values in minutes.
extension RuntimeX on int {
  /// Formats `142` → `"2h 22m"`, `42` → `"42m"`, `0` → `"—"`.
  String get runtime {
    if (this <= 0) return '—';
    final h = this ~/ 60;
    final m = this % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
