import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/features/settings/domain/repositories/settings_repository.dart';
import 'package:tmdb/features/settings/presentation/cubit/theme_cubit.dart';

class _MockSettingsRepository extends Mock implements SettingsRepository {}

void main() {
  late _MockSettingsRepository repository;

  setUpAll(() => registerFallbackValue(ThemeMode.system));

  setUp(() {
    repository = _MockSettingsRepository();
    when(() => repository.setThemeMode(any())).thenAnswer((_) async {});
  });

  test('seeds initial state from repository.getThemeMode()', () {
    when(() => repository.getThemeMode()).thenReturn(ThemeMode.dark);

    final cubit = ThemeCubit(repository);
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.dark);
  });

  test('setThemeMode emits the new mode and persists it', () async {
    when(() => repository.getThemeMode()).thenReturn(ThemeMode.system);

    final cubit = ThemeCubit(repository);
    addTearDown(cubit.close);

    final emitted = <ThemeMode>[];
    final sub = cubit.stream.listen(emitted.add);
    addTearDown(sub.cancel);

    await cubit.setThemeMode(ThemeMode.light);

    expect(cubit.state, ThemeMode.light);
    expect(emitted, [ThemeMode.light]);
    verify(() => repository.setThemeMode(ThemeMode.light)).called(1);
  });

  test('setThemeMode is a no-op when the mode is unchanged', () async {
    when(() => repository.getThemeMode()).thenReturn(ThemeMode.dark);

    final cubit = ThemeCubit(repository);
    addTearDown(cubit.close);

    final emitted = <ThemeMode>[];
    final sub = cubit.stream.listen(emitted.add);
    addTearDown(sub.cancel);

    await cubit.setThemeMode(ThemeMode.dark);

    expect(emitted, isEmpty);
    verifyNever(() => repository.setThemeMode(any()));
  });
}
