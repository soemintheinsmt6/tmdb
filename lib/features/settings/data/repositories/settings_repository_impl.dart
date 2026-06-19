import 'package:flutter/material.dart' show ThemeMode;

import 'package:tmdb/core/storage/hive_storage.dart';
import 'package:tmdb/features/settings/domain/repositories/settings_repository.dart';

/// [SettingsRepository] backed by the Hive `settings` box. Preferences are
/// stored as primitives (no TypeAdapter) keyed by name.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  final HiveStorage _storage;

  static const String _themeModeKey = 'theme_mode';

  @override
  ThemeMode getThemeMode() {
    final index = _storage.settingsBox.get(_themeModeKey);
    if (index is! int || index < 0 || index >= ThemeMode.values.length) {
      return ThemeMode.system;
    }
    return ThemeMode.values[index];
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) =>
      _storage.settingsBox.put(_themeModeKey, mode.index);
}
