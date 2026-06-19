import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

/// Lightweight reference to the franchise a movie belongs to, parsed from the
/// `belongs_to_collection` field of `/movie/{id}`. The full film list is
/// fetched separately as a [MovieCollection] via `/collection/{id}`.
class MovieCollectionRef extends Equatable {
  const MovieCollectionRef({
    required this.id,
    required this.name,
    required this.posterPath,
    required this.backdropPath,
  });

  /// Parses `belongs_to_collection`, or returns `null` when the movie isn't
  /// part of a collection (field absent) or the entry lacks a usable id.
  static MovieCollectionRef? tryFromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    final id = json['id'];
    if (id is! int) return null;
    return MovieCollectionRef(
      id: id,
      name: json['name'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
    );
  }

  final int id;
  final String name;
  final String? posterPath;
  final String? backdropPath;

  String backdropUrl({String size = 'w780'}) =>
      ApiConstants.backdropUrl(backdropPath, size: size);

  String posterUrl({String size = 'w342'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  @override
  List<Object?> get props => [id, name, posterPath, backdropPath];
}

/// Full movie collection (franchise) from `/collection/{id}` — metadata plus
/// its film [parts], ordered chronologically by release date.
class MovieCollection extends Equatable {
  const MovieCollection({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.parts,
  });

  factory MovieCollection.fromJson(Map<String, dynamic> json) {
    final parts =
        ((json['parts'] as List?) ?? const [])
            .map((e) => Movie.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.releaseDate.compareTo(b.releaseDate));
    return MovieCollection(
      id: (json['id'] as int?) ?? 0,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      parts: parts,
    );
  }

  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final List<Movie> parts;

  String backdropUrl({String size = 'original'}) =>
      ApiConstants.backdropUrl(backdropPath, size: size);

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    posterPath,
    backdropPath,
    parts,
  ];
}
