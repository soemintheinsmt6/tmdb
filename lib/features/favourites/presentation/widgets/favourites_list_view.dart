import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourite_hero_card.dart';
import 'package:tmdb/shared/domain/library_sort.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';

/// Reactive list body for the favourites segment of the Library tab (also used
/// standalone by [FavouriteScreen]). Items are ordered by [sort].
class FavouritesListView extends StatelessWidget {
  const FavouritesListView({super.key, this.sort = LibrarySort.recentlyAdded});

  final LibrarySort sort;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavouritesCubit, FavouritesState>(
      builder: (context, state) {
        if (state.items.isEmpty) {
          return const AppEmptyView(
            message: 'No favourites yet',
            icon: IconsaxPlusLinear.heart,
          );
        }
        final items = [...state.items]..sort(sort.comparator);
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, index) => FavouriteHeroCard(item: items[index]),
        );
      },
    );
  }
}
