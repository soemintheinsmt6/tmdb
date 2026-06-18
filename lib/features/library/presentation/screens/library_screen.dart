import 'package:flutter/material.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourites_list_view.dart';
import 'package:tmdb/features/watchlist/presentation/widgets/watchlist_list_view.dart';

/// Combined "Library" tab hosting the user's saved titles under one app bar:
/// Favourites (movies) and the Watchlist (movies + TV) as two segments.
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: TabBar(
            indicatorColor: AppColors.cyan,
            labelColor: AppColors.cyan,
            unselectedLabelColor: colors.textMuted,
            tabs: const [
              Tab(text: 'Favourites'),
              Tab(text: 'Watchlist'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [FavouritesListView(), WatchlistListView()],
        ),
      ),
    );
  }
}
