import 'package:flutter/material.dart' show ThemeMode;

/// Persists user-level app preferences. Currently just the theme mode; this is
/// the seam where future settings (region, language, …) would live.
abstract class SettingsRepository {
  /// The saved theme mode, or [ThemeMode.system] when nothing is stored yet.
  ThemeMode getThemeMode();

  Future<void> setThemeMode(ThemeMode mode);
}
