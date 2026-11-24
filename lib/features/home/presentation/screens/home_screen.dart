import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/home/presentation/bloc/home_bloc.dart';
import 'package:tmdb/features/home/presentation/widgets/home_content.dart';
import 'package:tmdb/features/search/presentation/screens/search_screen.dart';
import 'package:tmdb/injection_container.dart';

/// The editorial landing tab: a hero plus curated and personalised rails.
/// Search lives in the global [SearchScreen], reached from the app-bar icon
/// (no inline search field here).
///
/// The app bar is drawn over the hero: transparent at rest, fading to solid
/// navy as the feed scrolls past the backdrop.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Scroll distance over which the app bar goes from clear to solid.
  static const double _fadeDistance = 140;

  double _barOpacity = 0;

  bool _onScroll(ScrollNotification notification) {
    if (notification.depth != 0 || notification.metrics.axis != Axis.vertical) {
      return false;
    }
    final opacity = (notification.metrics.pixels / _fadeDistance).clamp(
      0.0,
      1.0,
    );
    if (opacity != _barOpacity) setState(() => _barOpacity = opacity);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          backgroundColor: AppColors.navy.withValues(alpha: _barOpacity),
          scrolledUnderElevation: 0,
          title: const Text(
            'TMDB',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5),
          ),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(IconsaxPlusLinear.search_normal_1),
              onPressed: () =>
                  unawaited(pushView(context, const SearchScreen())),
            ),
          ],
        ),
        body: NotificationListener<ScrollNotification>(
          onNotification: _onScroll,
          child: const HomeContent(),
        ),
      ),
    );
  }
}
