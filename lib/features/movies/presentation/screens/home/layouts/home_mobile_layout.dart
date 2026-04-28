import 'package:flutter/material.dart';
import 'package:tmdb/features/movies/presentation/widgets/home_content.dart';

class HomeMobileLayout extends StatelessWidget {
  const HomeMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TMDB')),
      body: const SafeArea(child: HomeContent()),
    );
  }
}
