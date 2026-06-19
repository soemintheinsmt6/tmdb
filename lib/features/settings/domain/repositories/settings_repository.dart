import 'package:flutter/material.dart' show ThemeMode;

import 'package:tmdb/shared/domain/library_sort.dart';
import 'package:tmdb/shared/domain/library_view.dart';

/// Persists user-level app preferences (theme, library sort/view, …) — the seam
/// where future settings (region, language, …) would live.
abstract class SettingsRepository {
  /// The saved theme mode, or [ThemeMode.system] when nothing is stored yet.
  ThemeMode getThemeMode();

  Future<void> setThemeMode(ThemeMode mode);

  /// The saved Library sort order, or [LibrarySort.recentlyAdded] by default.
  LibrarySort getLibrarySort();

  Future<void> setLibrarySort(LibrarySort sort);

  /// The saved Library layout, or [LibraryView.list] by default.
  LibraryView getLibraryView();

  Future<void> setLibraryView(LibraryView view);
}
