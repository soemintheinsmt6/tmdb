import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/extensions/string_year.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/shared/domain/media_type.dart';
import 'package:tmdb/shared/domain/poster_item.dart';

export 'package:tmdb/shared/domain/media_type.dart';

/// A favourited title — a movie or a TV show. Carries a [mediaType]
/// discriminator (favourites span both verticals) and implements [PosterItem]
/// so it renders through the shared poster widgets. Structurally parallel to
/// the watchlist's saved item.
class FavouriteItem extends Equatable implements PosterItem {
  const FavouriteItem({
    required this.mediaType,
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.date,
    required this.voteAverage,
    required this.voteCount,
    required this.savedAt,
  });

  factory FavouriteItem.fromMovie(Movie m) => FavouriteItem(
    mediaType: MediaType.movie,
    id: m.id,
    title: m.title,
    overview: m.overview,
    posterPath: m.posterPath,
    backdropPath: m.backdropPath,
    date: m.releaseDate,
    voteAverage: m.voteAverage,
    voteCount: m.voteCount,
    savedAt: DateTime.now(),
  );

  factory FavouriteItem.fromTvShow(TvShow s) => FavouriteItem(
    mediaType: MediaType.tv,
    id: s.id,
    title: s.name,
    overview: s.overview,
    posterPath: s.posterPath,
    backdropPath: s.backdropPath,
    date: s.firstAirDate,
    voteAverage: s.voteAverage,
    voteCount: s.voteCount,
    savedAt: DateTime.now(),
  );

  final MediaType mediaType;
  @override
  final int id;
  @override
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;

  /// Release date (movies) or first-air date (TV), `YYYY-MM-DD`.
  final String date;
  final double voteAverage;
  final int voteCount;
  final DateTime savedAt;

  /// Stable, collision-free in-memory key: `"movie:550"` / `"tv:1399"`.
  String get storageKey => keyFor(mediaType, id);

  /// Builds the same key from a (type, id) pair without an instance.
  static String keyFor(MediaType type, int id) => '${type.name}:$id';

  @override
  String posterUrl({String size = 'w500'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  String backdropUrl({String size = 'w1280'}) =>
      ApiConstants.backdropUrl(backdropPath, size: size);

  /// [PosterItem] year — parsed from [date].
  @override
  String? get year => date.year;

  @override
  String get formattedRating => voteCount == 0 ? 'NR' : voteAverage.rating;

  // [savedAt] is intentionally excluded: equality keys on the title and its
  // display data, not the instant it was saved (list order still reflects
  // save time via the repository's sort).
  @override
  List<Object?> get props => [
    mediaType,
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    date,
    voteAverage,
    voteCount,
  ];
}
