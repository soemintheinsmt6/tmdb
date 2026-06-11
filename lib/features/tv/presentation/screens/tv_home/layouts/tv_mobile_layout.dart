import 'package:flutter/material.dart';
import 'package:tmdb/features/tv/presentation/widgets/tv_content.dart';

class TvMobileLayout extends StatelessWidget {
  const TvMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TV Shows')),
      body: const SafeArea(child: TvContent()),
    );
  }
}
