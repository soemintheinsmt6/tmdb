import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_state.dart';
import 'package:tmdb/features/favourites/presentation/widgets/favourite_hero_card.dart';
import 'package:tmdb/shared/widgets/app_empty_view.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: BlocBuilder<FavouritesCubit, FavouritesState>(
        builder: (context, state) {
          if (state.movies.isEmpty) {
            return const AppEmptyView(
              message: 'No favourites yet',
              icon: IconsaxPlusLinear.heart,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: state.movies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, index) =>
                FavouriteHeroCard(movie: state.movies[index]),
          );
        },
      ),
    );
  }
}
