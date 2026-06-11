import 'package:flutter/material.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';
import 'package:tmdb/features/tv/presentation/widgets/tv_content.dart';

/// Wider scaffold with extra horizontal padding so the grid doesn't stretch
/// edge-to-edge on tablets.
class TvTabletLayout extends StatelessWidget {
  const TvTabletLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final padding = context.horizontalPadding;
    return Scaffold(
      appBar: AppBar(title: const Text('TV Shows')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: const TvContent(),
        ),
      ),
    );
  }
}
