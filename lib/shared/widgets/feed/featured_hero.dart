import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';
import 'package:tmdb/shared/widgets/common/rating_badge.dart';

/// A single featured backdrop slide. Fills its parent — the carousel supplies
/// the 16:10 box — with a bottom fade into the page background and an overlaid
/// label / title / rating. Tapping opens the item's detail screen.
class FeaturedHero extends StatelessWidget {
  const FeaturedHero({
    super.key,
    required this.item,
    required this.onTap,
    this.label = 'TRENDING',
    this.heroTag,
  });

  final PosterItem item;
  final VoidCallback onTap;
  final String label;

  /// When set, the backdrop is wrapped in a [Hero] with this tag so it shares
  /// a flight transition with the detail screen's [DetailHeader].
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final url = item.backdropUrl();
    Widget image = url.isEmpty
        ? ColoredBox(color: colors.surface)
        : CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (_, __) => ColoredBox(color: colors.surface),
            errorWidget: (_, __, ___) => ColoredBox(color: colors.surface),
          );
    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.background.withValues(alpha: 0.0),
                  colors.background.withValues(alpha: 0.75),
                  colors.background,
                ],
                stops: const [0.3, 0.82, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.pageTitle.copyWith(
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    RatingBadge(rating: item.formattedRating),
                    if (item.year != null) ...[
                      const SizedBox(width: 10),
                      Text(
                        item.year!,
                        style: AppTypography.bodyText.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
