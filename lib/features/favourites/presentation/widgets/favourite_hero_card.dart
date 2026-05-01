import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/favourites/presentation/cubit/favourites_cubit.dart';
import 'package:tmdb/features/movies/data/models/movie.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/movies/presentation/widgets/rating_badge.dart';

/// Full-width 16:9 card with the backdrop as a hero image, a heart in the
/// top-right, and title / rating / year overlaid at the bottom.
class FavouriteHeroCard extends StatelessWidget {
  const FavouriteHeroCard({super.key, required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          _BackgroundImage(movie: movie),
          const Positioned.fill(child: _BottomGradient()),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => pushView(
                  context,
                  MovieDetailScreen(movieId: movie.id, title: movie.title),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: _RemoveButton(movieId: movie.id),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 12,
            child: _CardFooter(movie: movie),
          ),
        ],
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasBackdrop =
        movie.backdropPath != null && movie.backdropPath!.isNotEmpty;
    final imageUrl = hasBackdrop
        ? movie.backdropUrl(size: 'w780')
        : movie.posterUrl(size: 'w500');

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: imageUrl.isEmpty
          ? Container(color: colors.surfaceMuted)
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: colors.surfaceMuted),
              errorWidget: (_, __, ___) =>
                  Container(color: colors.surfaceMuted),
            ),
    );
  }
}

class _BottomGradient extends StatelessWidget {
  const _BottomGradient();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0),
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0.85),
            ],
            stops: const [0.45, 0.75, 1.0],
          ),
        ),
      ),
    );
  }
}

class _CardFooter extends StatelessWidget {
  const _CardFooter({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          movie.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.subTitle.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            RatingBadge(rating: movie.formattedRating, compact: true),
            const SizedBox(width: 10),
            const Icon(
              IconsaxPlusLinear.calendar_1,
              size: 13,
              color: Colors.white70,
            ),
            const SizedBox(width: 4),
            Text(
              movie.releaseYear ?? '—',
              style: AppTypography.smallText.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.movieId});

  final int movieId;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        tooltip: 'Remove from favourites',
        iconSize: 20,
        visualDensity: VisualDensity.compact,
        icon: const Icon(IconsaxPlusBold.heart, color: AppColors.cyan),
        onPressed: () => context.read<FavouritesCubit>().remove(movieId),
      ),
    );
  }
}
