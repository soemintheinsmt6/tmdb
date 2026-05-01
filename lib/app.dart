import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_theme.dart';
import 'package:tmdb/shared/widgets/root_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TMDB',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const RootScreen(),
    );
  }
}
