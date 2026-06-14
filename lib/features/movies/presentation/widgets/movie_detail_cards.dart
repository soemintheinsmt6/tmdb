import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/shared/widgets/detail_cards.dart';

/// Movie-specific summary: composes the shared [DetailSummary] with a meta row
/// of release year + runtime.
class MovieDetailSummary extends StatelessWidget {
  const MovieDetailSummary({super.key, required this.detail});

  final MovieDetail detail;

  @override
  Widget build(BuildContext context) {
    return DetailSummary(
      posterUrl: detail.posterUrl(),
      title: detail.title,
      tagline: detail.tagline,
      voteAverage: detail.voteAverage,
      voteCount: detail.voteCount,
      genres: detail.genres,
      metaChips: [
        DetailMetaChip(
          icon: IconsaxPlusLinear.calendar_1,
          label: detail.releaseYear ?? '—',
        ),
        DetailMetaChip(
          icon: IconsaxPlusLinear.clock_1,
          label: detail.formattedRuntime,
        ),
      ],
    );
  }
}

/// "Similar Movies" rail that routes to another [MovieDetailScreen].
class MovieRecommendations extends StatelessWidget {
  const MovieRecommendations({
    super.key,
    required this.movies,
    this.horizontalPadding = 16,
  });

  final List<Movie> movies;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return DetailPosterRail(
      title: 'Similar Movies',
      items: movies,
      horizontalPadding: horizontalPadding,
      onTap: (item) => pushView(
        context,
        MovieDetailScreen(movieId: item.id, title: item.title),
      ),
    );
  }
}
