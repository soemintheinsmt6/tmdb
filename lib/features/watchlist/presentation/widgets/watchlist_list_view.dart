import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';
import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_state.dart';
import 'package:tmdb/features/watchlist/presentation/watchlist_navigation.dart';
import 'package:tmdb/features/watchlist/presentation/widgets/watchlist_hero_card.dart';
import 'package:tmdb/shared/domain/library/library_sort.dart';
import 'package:tmdb/shared/domain/library/library_view.dart';
import 'package:tmdb/shared/widgets/common/app_empty_view.dart';
import 'package:tmdb/shared/widgets/poster/sectioned_poster_grid.dart';

/// Reactive list body for the watchlist segment of the Library tab. Items are
/// ordered by [sort] and rendered as hero cards or a poster grid per [view].
class WatchlistListView extends StatelessWidget {
  const WatchlistListView({
    super.key,
    this.sort = LibrarySort.recentlyAdded,
    this.view = LibraryView.list,
  });

  final LibrarySort sort;
  final LibraryView view;

  static const _padding = EdgeInsets.fromLTRB(16, 12, 16, 24);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistCubit, WatchlistState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const AppEmptyView(
            message: 'Nothing on your watchlist yet',
            icon: IconsaxPlusLinear.save_2,
          );
        }
        final items = [...state.items]..sort(sort.comparator);
        if (view == LibraryView.grid) {
          // Grid layout separates movies and TV into their own sections;
          // `items` is already sorted, so each section stays in sort order.
          return SectionedPosterGrid(
            padding: _padding,
            onTap: (item) =>
                openWatchlistDetail(context, item as WatchlistItem),
            movies: [
              for (final item in items)
                if (item.mediaType == MediaType.movie) item,
            ],
            tvShows: [
              for (final item in items)
                if (item.mediaType == MediaType.tv) item,
            ],
          );
        }
        return ListView.separated(
          padding: _padding,
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, index) => WatchlistHeroCard(item: items[index]),
        );
      },
    );
  }
}
