import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourites_list_view.dart';
import 'package:tmdb/features/library/presentation/widgets/library_sort_sheet.dart';
import 'package:tmdb/features/settings/domain/repositories/settings_repository.dart';
import 'package:tmdb/features/watchlist/presentation/widgets/watchlist_list_view.dart';
import 'package:tmdb/injection_container.dart';
import 'package:tmdb/shared/domain/library/library_sort.dart';
import 'package:tmdb/shared/domain/library/library_view.dart';

/// Combined "Library" tab hosting the user's saved titles under one app bar:
/// Favourites (movies + TV) and the Watchlist (movies + TV) as two segments.
/// A single sort control in the app bar applies to both segments.
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final SettingsRepository _settings = sl<SettingsRepository>();
  late LibrarySort _sort;
  late LibraryView _view;

  @override
  void initState() {
    super.initState();
    // Restore the last-used sort and layout so they persist across launches.
    _sort = _settings.getLibrarySort();
    _view = _settings.getLibraryView();
  }

  Future<void> _pickSort() async {
    final picked = await showLibrarySortSheet(context, selected: _sort);
    if (picked != null && picked != _sort && mounted) {
      setState(() => _sort = picked);
      await _settings.setLibrarySort(picked);
    }
  }

  Future<void> _toggleView() async {
    final next = _view == LibraryView.list
        ? LibraryView.grid
        : LibraryView.list;
    setState(() => _view = next);
    await _settings.setLibraryView(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isList = _view == LibraryView.list;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: NavigationToolbar.kMiddleSpacing,
          title: const Text('Library'),
          actions: [
            IconButton(
              tooltip: isList ? 'Grid view' : 'List view',
              icon: Icon(
                isList ? IconsaxPlusLinear.grid_2 : IconsaxPlusLinear.menu,
                // Optical balance: the grid/list glyphs fill their box more
                // densely than the sort icon, so nudge them down a touch.
                size: isList ? 22 : null,
              ),
              onPressed: _toggleView,
            ),
            IconButton(
              tooltip: 'Sort',
              icon: const Icon(IconsaxPlusLinear.sort),
              onPressed: _pickSort,
            ),
          ],
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
        body: TabBarView(
          children: [
            FavouritesListView(sort: _sort, view: _view),
            WatchlistListView(sort: _sort, view: _view),
          ],
        ),
      ),
    );
  }
}
