import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/extensions/string_year.dart';
import 'package:tmdb/shared/domain/poster_item.dart';

/// A TV show list item. Implements [PosterItem] so it renders through the
/// shared poster widgets exactly like a `Movie`.
class TvShow extends Equatable implements PosterItem {
  const TvShow({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.firstAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
  });

  factory TvShow.fromJson(Map<String, dynamic> json) {
    return TvShow(
      id: json['id'] as int,
      // `/search/tv` and list endpoints use `name`; tolerate `title` too.
      name: (json['name'] ?? json['title']) as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      firstAirDate:
          (json['first_air_date'] ?? json['release_date']) as String? ?? '',
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (json['vote_count'] as int?) ?? 0,
      genreIds: ((json['genre_ids'] as List?) ?? const [])
          .map((e) => e as int)
          .toList(),
    );
  }

  @override
  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String firstAirDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;

  /// [PosterItem] title — a show's `name`.
  @override
  String get title => name;

  @override
  String posterUrl({String size = 'w500'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  @override
  String backdropUrl({String size = 'w1280'}) =>
      ApiConstants.backdropUrl(backdropPath, size: size);

  /// `"2024"` or `null` when no parseable year.
  String? get firstAirYear => firstAirDate.year;

  /// [PosterItem] year — the first-air year for TV shows.
  @override
  String? get year => firstAirYear;

  /// One-decimal score, e.g. `"7.5"`. `"NR"` when unrated.
  @override
  String get formattedRating => voteCount == 0 ? 'NR' : voteAverage.rating;

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    posterPath,
    backdropPath,
    firstAirDate,
    voteAverage,
    voteCount,
    genreIds,
  ];
}
