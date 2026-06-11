import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/shared/widgets/detail_cards.dart';

/// TV-specific summary: composes the shared [DetailSummary] with a meta row of
/// first-air year + season count + episode count.
class TvDetailSummary extends StatelessWidget {
  const TvDetailSummary({super.key, required this.detail});

  final TvShowDetail detail;

  @override
  Widget build(BuildContext context) {
    return DetailSummary(
      posterUrl: detail.posterUrl(),
      title: detail.name,
      tagline: detail.tagline,
      rating: detail.formattedRating,
      genres: detail.genres,
      metaChips: [
        DetailMetaChip(
          icon: IconsaxPlusLinear.calendar_1,
          label: detail.firstAirYear ?? '—',
        ),
        if (detail.seasonsLabel.isNotEmpty)
          DetailMetaChip(
            icon: IconsaxPlusLinear.layer,
            label: detail.seasonsLabel,
          ),
        if (detail.episodesLabel.isNotEmpty)
          DetailMetaChip(
            icon: IconsaxPlusLinear.video_play,
            label: detail.episodesLabel,
          ),
      ],
    );
  }
}

/// "Similar Shows" rail that routes to another [TvDetailScreen].
class TvRecommendations extends StatelessWidget {
  const TvRecommendations({
    super.key,
    required this.shows,
    this.horizontalPadding = 16,
  });

  final List<TvShow> shows;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return DetailPosterRail(
      title: 'Similar Shows',
      items: shows,
      horizontalPadding: horizontalPadding,
      onTap: (item) => pushView(
        context,
        TvDetailScreen(tvShowId: item.id, title: item.title),
      ),
    );
  }
}
