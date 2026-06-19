import 'package:flutter/material.dart';

import 'package:tmdb/core/theme/app_colors.dart';
import 'package:tmdb/core/theme/app_typography.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/tv/domain/entities/season.dart';
import 'package:tmdb/features/tv/presentation/screens/season/season_screen.dart';
import 'package:tmdb/shared/widgets/poster_image.dart';

/// Horizontal rail of a show's seasons. Tapping a season opens its episode list
/// in a [SeasonScreen]. Seasons with no released episodes are hidden, and the
/// rail renders nothing when none remain.
class TvSeasonsRail extends StatelessWidget {
  const TvSeasonsRail({
    super.key,
    required this.tvShowId,
    required this.seasons,
    this.horizontalPadding = 16,
  });

  final int tvShowId;
  final List<Season> seasons;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final visible = seasons.where((s) => s.episodeCount > 0).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: const Text('Seasons', style: AppTypography.subTitle),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final season = visible[index];
              return SizedBox(
                width: 130,
                child: _SeasonCard(
                  season: season,
                  onTap: () => pushView(
                    context,
                    SeasonScreen(
                      tvShowId: tvShowId,
                      seasonNumber: season.seasonNumber,
                      title: season.name,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.season, required this.onTap});

  final Season season;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final subtitle = [
      if (season.airYear != null) season.airYear,
      if (season.episodeCountLabel.isNotEmpty) season.episodeCountLabel,
    ].join('  ·  ');

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PosterImage(url: season.posterUrl()),
          const SizedBox(height: 6),
          Text(
            season.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.smallText.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(color: colors.textMuted),
            ),
        ],
      ),
    );
  }
}
