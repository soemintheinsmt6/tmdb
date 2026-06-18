import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/extensions/string_year.dart';
import 'package:tmdb/shared/domain/poster_item.dart';

class Movie extends Equatable implements PosterItem {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.genreIds,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? json['name']) as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate:
          (json['release_date'] ?? json['first_air_date']) as String? ?? '',
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (json['vote_count'] as int?) ?? 0,
      genreIds: ((json['genre_ids'] as List?) ?? const [])
          .map((e) => e as int)
          .toList(),
    );
  }

  @override
  final int id;
  @override
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final List<int> genreIds;

  @override
  String posterUrl({String size = 'w500'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  @override
  String backdropUrl({String size = 'w1280'}) =>
      ApiConstants.backdropUrl(backdropPath, size: size);

  /// `"2024"` or `null` when no parseable year.
  String? get releaseYear => releaseDate.year;

  /// [PosterItem] year — the release year for movies.
  @override
  String? get year => releaseYear;

  /// One-decimal score, e.g. `"7.5"`. `"NR"` when unrated.
  @override
  String get formattedRating => voteCount == 0 ? 'NR' : voteAverage.rating;

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    releaseDate,
    voteAverage,
    voteCount,
    genreIds,
  ];
}
