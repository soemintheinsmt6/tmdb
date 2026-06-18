import 'package:flutter/widgets.dart';

import 'package:tmdb/core/utils/navigation.dart';
import 'package:tmdb/features/movies/presentation/screens/movie_detail/movie_detail_screen.dart';
import 'package:tmdb/features/tv/presentation/screens/tv_detail/tv_detail_screen.dart';
import 'package:tmdb/features/watchlist/domain/entities/watchlist_item.dart';

/// Opens the movie or TV detail screen for a saved [item], based on its media
/// type. Shared by the watchlist hero card and the watchlist grid.
Future<void> openWatchlistDetail(
  BuildContext context,
  WatchlistItem item, {
  Object? heroTag,
}) async {
  switch (item.mediaType) {
    case MediaType.movie:
      await pushView(
        context,
        MovieDetailScreen(
          movieId: item.id,
          title: item.title,
          backdropPath: item.backdropPath,
          heroTag: heroTag,
        ),
      );
    case MediaType.tv:
      await pushView(
        context,
        TvDetailScreen(
          tvShowId: item.id,
          title: item.title,
          backdropPath: item.backdropPath,
          heroTag: heroTag,
        ),
      );
  }
}
