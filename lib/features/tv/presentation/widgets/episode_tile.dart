import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import 'package:tmdb/core/extensions/string_date.dart';
import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/features/tv/domain/entities/episode.dart';
import 'package:tmdb/shared/widgets/rating_badge.dart';

/// A single episode row in the season screen: a still on the left that fills the
/// card's height, then the numbered title, air date / runtime, and a clamped
/// overview. The still stretches to the text height so cards never show an empty
/// gap below a short thumbnail.
class EpisodeTile extends StatelessWidget {
  const EpisodeTile({super.key, required this.episode});

  final Episode episode;

  static const double _stillWidth = 116;
  static const double _minHeight = 96;
  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final still = episode.stillUrl();
    final meta = [
      if (episode.airDate.mediumDate != null) episode.airDate.mediumDate!,
      if (episode.runtimeLabel.isNotEmpty) episode.runtimeLabel,
    ].join('  ·  ');

    Widget fallback() => Container(
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(
        IconsaxPlusLinear.video_slash,
        color: colors.textMuted,
        size: 22,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Fills the row height (driven by the text column) — no dead space.
            // Clip its own left corners so they follow the card radius even
            // though it paints edge-to-edge under the card's border.
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(_radius),
              ),
              child: SizedBox(
                width: _stillWidth,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: _minHeight),
                  child: still.isEmpty
                      ? fallback()
                      : CachedNetworkImage(
                          imageUrl: still,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: colors.surfaceMuted),
                          errorWidget: (_, __, ___) => fallback(),
                        ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${episode.episodeNumber}. ',
                                  style: AppTypography.bodyText.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.cyan,
                                  ),
                                ),
                                TextSpan(
                                  text: episode.name,
                                  style: AppTypography.bodyText.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (episode.voteCount > 0) ...[
                          const SizedBox(width: 8),
                          RatingBadge(
                            rating: episode.formattedRating,
                            compact: true,
                          ),
                        ],
                      ],
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        meta,
                        style: AppTypography.labelSmall.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ],
                    if (episode.overview.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        episode.overview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.smallText.copyWith(
                          color: colors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
