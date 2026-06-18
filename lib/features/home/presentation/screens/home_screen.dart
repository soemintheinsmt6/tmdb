import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/home/presentation/bloc/home_bloc.dart';
import 'package:tmdb/features/home/presentation/widgets/home_content.dart';
import 'package:tmdb/features/search/presentation/screens/search_screen.dart';
import 'package:tmdb/injection_container.dart';

/// The editorial landing tab: a hero plus curated and personalised rails.
/// Search lives in the global [SearchScreen], reached from the app-bar icon
/// (no inline search field here).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeBloc>(),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          title: const Text('TMDB'),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(IconsaxPlusLinear.search_normal_1),
              onPressed: () =>
                  unawaited(pushView(context, const SearchScreen())),
            ),
          ],
        ),
        body: const SafeArea(child: HomeContent()),
      ),
    );
  }
}
