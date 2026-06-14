import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/shared/domain/poster_item.dart';
import 'package:tmdb/shared/widgets/poster_image.dart';
import 'package:tmdb/shared/widgets/rating_badge.dart';

/// Vertical poster card used in grids — poster on top, title + year below.
/// Works for any [PosterItem] (movie or TV show).
class PosterCard extends StatelessWidget {
  const PosterCard({super.key, required this.item, this.onTap});

  final PosterItem item;
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
              PosterImage(url: item.posterUrl()),
              Positioned(
                top: 8,
                right: 8,
                child: RatingBadge(rating: item.formattedRating),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyText.copyWith(
              fontWeight: FontWeight.w600,
              color: context.colors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.year ?? '—',
            style: AppTypography.smallText.copyWith(
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
