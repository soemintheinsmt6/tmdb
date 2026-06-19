import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:tmdb/features/settings/domain/repositories/settings_repository.dart';

/// Holds the active [ThemeMode] and persists changes. Provided app-wide above
/// [MaterialApp], whose `themeMode` follows this cubit's state.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._repository) : super(_repository.getThemeMode());

  final SettingsRepository _repository;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _repository.setThemeMode(mode);
  }
}
