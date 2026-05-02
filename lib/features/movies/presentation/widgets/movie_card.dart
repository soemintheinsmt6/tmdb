import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

import 'movie_poster.dart';
import 'rating_badge.dart';

/// Vertical poster card used in grids — poster on top, title + meta below.
class MovieCard extends StatelessWidget {
  const MovieCard({super.key, required this.movie, this.onTap});

  final Movie movie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              MoviePoster(url: movie.posterUrl()),
              Positioned(
                top: 8,
                left: 8,
                child: RatingBadge(rating: movie.formattedRating),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            movie.releaseYear ?? '—',
            style: AppTypography.smallText.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
