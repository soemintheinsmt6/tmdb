import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/extensions/int_runtime.dart';
import 'package:tmdb/core/extensions/string_year.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/shared/domain/cast_member.dart';
import 'package:tmdb/shared/domain/genre.dart';
import 'package:tmdb/shared/domain/media_image.dart';
import 'package:tmdb/shared/domain/review.dart';
import 'package:tmdb/shared/domain/video.dart';
import 'package:tmdb/shared/domain/watch_providers.dart';

/// Full movie detail entity — combines `/movie/{id}` with credits and
/// recommendations into a single domain object.
class MovieDetail extends Equatable {
  const MovieDetail({
    required this.id,
    required this.title,
    required this.tagline,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.runtime,
    required this.genres,
    required this.status,
    required this.cast,
    required this.recommendations,
    required this.videos,
    required this.reviews,
    required this.images,
    this.watchProviders,
  });

  /// Parses the `/movie/{id}` payload. Cast, recommendations, videos, reviews,
  /// and images come from separate endpoints, so the repository injects them
  /// after the parallel fetch.
  factory MovieDetail.fromJson(
    Map<String, dynamic> json, {
    List<CastMember> cast = const [],
    List<Movie> recommendations = const [],
    List<Video> videos = const [],
    List<Review> reviews = const [],
    List<MediaImage> images = const [],
  }) {
    return MovieDetail(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: json['release_date'] as String? ?? '',
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (json['vote_count'] as int?) ?? 0,
      runtime: (json['runtime'] as int?) ?? 0,
      genres: ((json['genres'] as List?) ?? const [])
          .map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? '',
      cast: cast,
      recommendations: recommendations,
      videos: videos,
      reviews: reviews,
      images: images,
    );
  }

  MovieDetail copyWith({
    List<CastMember>? cast,
    List<Movie>? recommendations,
    List<Video>? videos,
    List<Review>? reviews,
    List<MediaImage>? images,
    WatchProviders? watchProviders,
  }) {
    return MovieDetail(
      id: id,
      title: title,
      tagline: tagline,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      releaseDate: releaseDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      runtime: runtime,
      genres: genres,
      status: status,
      cast: cast ?? this.cast,
      recommendations: recommendations ?? this.recommendations,
      videos: videos ?? this.videos,
      reviews: reviews ?? this.reviews,
      images: images ?? this.images,
      watchProviders: watchProviders ?? this.watchProviders,
    );
  }

  final int id;
  final String title;
  final String tagline;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final int voteCount;
  final int runtime;
  final List<Genre> genres;
  final String status;
  final List<CastMember> cast;
  final List<Movie> recommendations;
  final List<Video> videos;
  final List<Review> reviews;
  final List<MediaImage> images;

  /// Where-to-watch options for the device region; `null` until injected by the
  /// repository (or when TMDB has none for that region).
  final WatchProviders? watchProviders;

  String posterUrl({String size = 'w500'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  String backdropUrl({String size = 'original'}) =>
      ApiConstants.backdropUrl(backdropPath, size: size);

  String? get releaseYear => releaseDate.year;
  String get formattedRuntime => runtime.runtime;
  String get formattedRating => voteCount == 0 ? 'NR' : voteAverage.rating;

  Movie toMovie() => Movie(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    releaseDate: releaseDate,
    voteAverage: voteAverage,
    voteCount: voteCount,
    genreIds: genres.map((g) => g.id).toList(),
  );

  @override
  List<Object?> get props => [
    id,
    title,
    tagline,
    overview,
    posterPath,
    backdropPath,
    releaseDate,
    voteAverage,
    voteCount,
    runtime,
    genres,
    status,
    cast,
    recommendations,
    videos,
    reviews,
    images,
    watchProviders,
  ];
}
