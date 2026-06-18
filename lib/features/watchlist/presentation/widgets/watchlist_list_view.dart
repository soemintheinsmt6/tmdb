import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_cubit.dart';
import 'package:tmdb/features/watchlist/presentation/cubit/watchlist_state.dart';
import 'package:tmdb/features/watchlist/presentation/widgets/watchlist_hero_card.dart';
import 'package:tmdb/shared/domain/library_sort.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';

/// Reactive list body for the watchlist segment of the Library tab. Items are
/// ordered by [sort].
class WatchlistListView extends StatelessWidget {
  const WatchlistListView({super.key, this.sort = LibrarySort.recentlyAdded});

  final LibrarySort sort;

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
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, index) => WatchlistHeroCard(item: items[index]),
        );
      },
    );
  }
}
