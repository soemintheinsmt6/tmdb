import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/search/presentation/screens/search_screen.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_feed_bloc/tv_feed_bloc.dart';
import 'package:tmdb/features/tv/presentation/widgets/tv_feed_content.dart';
import 'package:tmdb/injection_container.dart';

/// The series landing tab: a trending hero plus curated TV category rails.
/// Search lives in the global [SearchScreen], reached from the app-bar icon.
class TvScreen extends StatelessWidget {
  const TvScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TvFeedBloc>(),
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          title: const Text('Series'),
          actions: [
            IconButton(
              tooltip: 'Search',
              icon: const Icon(IconsaxPlusLinear.search_normal_1),
              onPressed: () =>
                  unawaited(pushView(context, const SearchScreen())),
            ),
          ],
        ),
        body: const SafeArea(child: TvFeedContent()),
      ),
    );
  }
}
