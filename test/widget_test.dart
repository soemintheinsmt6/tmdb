import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tmdb/core/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme exposes a usable dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: Text('Hello, TMDB')),
      ),
    );

    expect(find.text('Hello, TMDB'), findsOneWidget);
    final theme = AppTheme.darkTheme;
    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.dark);
  });
}
