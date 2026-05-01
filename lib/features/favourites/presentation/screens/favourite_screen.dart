import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/favourites/data/models/favourite_movie.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/movies/presentation/widgets/movie_card.dart';
import 'package:tmdb/core/responsive/app_breakpoints.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: BlocBuilder<FavouritesCubit, List<FavouriteMovie>>(
        builder: (context, favourites) {
          if (favourites.isEmpty) return const _EmptyState();
          return _FavouritesGrid(favourites: favourites);
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(IconsaxPlusLinear.heart, size: 48, color: colors.textMuted),
          const SizedBox(height: 12),
          Text(
            'No favourites yet',
            style: AppTypography.subTitle.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavouritesGrid extends StatelessWidget {
  const _FavouritesGrid({required this.favourites});

  final List<FavouriteMovie> favourites;

  @override
  Widget build(BuildContext context) {
    final columns = context.posterGridColumns;
    final aspectRatio = context.posterCardAspectRatio;
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: aspectRatio,
      ),
      itemCount: favourites.length,
      itemBuilder: (_, index) {
        final movie = favourites[index].toMovie();
        return MovieCard(
          movie: movie,
          onTap: () => pushView(
            context,
            MovieDetailScreen(movieId: movie.id, title: movie.title),
          ),
        );
      },
    );
  }
}
