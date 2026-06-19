import 'package:flutter/material.dart' show ThemeMode;

import 'package:tmdb/core/storage/hive_storage.dart';
import 'package:tmdb/features/settings/domain/repositories/settings_repository.dart';
import 'package:tmdb/shared/domain/library/library_sort.dart';
import 'package:tmdb/shared/domain/library/library_view.dart';

/// [SettingsRepository] backed by the Hive `settings` box. Enum preferences are
/// stored as their `index` (a primitive — no TypeAdapter) keyed by name.
class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._storage);

  final HiveStorage _storage;

  static const String _themeModeKey = 'theme_mode';
  static const String _librarySortKey = 'library_sort';
  static const String _libraryViewKey = 'library_view';

  @override
  ThemeMode getThemeMode() =>
      _readEnum(_themeModeKey, ThemeMode.values, ThemeMode.system);

  @override
  Future<void> setThemeMode(ThemeMode mode) => _writeEnum(_themeModeKey, mode);

  @override
  LibrarySort getLibrarySort() =>
      _readEnum(_librarySortKey, LibrarySort.values, LibrarySort.recentlyAdded);

  @override
  Future<void> setLibrarySort(LibrarySort sort) =>
      _writeEnum(_librarySortKey, sort);

  @override
  LibraryView getLibraryView() =>
      _readEnum(_libraryViewKey, LibraryView.values, LibraryView.list);

  @override
  Future<void> setLibraryView(LibraryView view) =>
      _writeEnum(_libraryViewKey, view);

  /// Reads an enum stored by its index, returning [fallback] when missing or
  /// out of range (e.g. a value persisted by a newer build).
  T _readEnum<T extends Enum>(String key, List<T> values, T fallback) {
    final index = _storage.settingsBox.get(key);
    if (index is! int || index < 0 || index >= values.length) return fallback;
    return values[index];
  }

  Future<void> _writeEnum(String key, Enum value) =>
      _storage.settingsBox.put(key, value.index);
}
