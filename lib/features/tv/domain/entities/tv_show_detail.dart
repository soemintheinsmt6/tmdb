import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';
import 'package:tmdb/core/extensions/string_year.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/shared/domain/cast_member.dart';
import 'package:tmdb/shared/domain/genre.dart';

/// Full TV show detail — combines `/tv/{id}` with credits and recommendations
/// into a single domain object. Mirrors `MovieDetail`.
class TvShowDetail extends Equatable {
  const TvShowDetail({
    required this.id,
    required this.name,
    required this.tagline,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.firstAirDate,
    required this.lastAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.episodeRunTime,
    required this.genres,
    required this.status,
    required this.cast,
    required this.recommendations,
  });

  /// Parses the `/tv/{id}` payload. Cast and recommendations come from separate
  /// endpoints, so the repository injects them after the parallel fetch.
  factory TvShowDetail.fromJson(
    Map<String, dynamic> json, {
    List<CastMember> cast = const [],
    List<TvShow> recommendations = const [],
  }) {
    return TvShowDetail(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      firstAirDate: json['first_air_date'] as String? ?? '',
      lastAirDate: json['last_air_date'] as String? ?? '',
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (json['vote_count'] as int?) ?? 0,
      numberOfSeasons: (json['number_of_seasons'] as int?) ?? 0,
      numberOfEpisodes: (json['number_of_episodes'] as int?) ?? 0,
      episodeRunTime: ((json['episode_run_time'] as List?) ?? const [])
          .map((e) => e as int)
          .toList(),
      genres: ((json['genres'] as List?) ?? const [])
          .map((e) => Genre.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: json['status'] as String? ?? '',
      cast: cast,
      recommendations: recommendations,
    );
  }

  TvShowDetail copyWith({
    List<CastMember>? cast,
    List<TvShow>? recommendations,
  }) {
    return TvShowDetail(
      id: id,
      name: name,
      tagline: tagline,
      overview: overview,
      posterPath: posterPath,
      backdropPath: backdropPath,
      firstAirDate: firstAirDate,
      lastAirDate: lastAirDate,
      voteAverage: voteAverage,
      voteCount: voteCount,
      numberOfSeasons: numberOfSeasons,
      numberOfEpisodes: numberOfEpisodes,
      episodeRunTime: episodeRunTime,
      genres: genres,
      status: status,
      cast: cast ?? this.cast,
      recommendations: recommendations ?? this.recommendations,
    );
  }

  final int id;
  final String name;
  final String tagline;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String firstAirDate;
  final String lastAirDate;
  final double voteAverage;
  final int voteCount;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final List<int> episodeRunTime;
  final List<Genre> genres;
  final String status;
  final List<CastMember> cast;
  final List<TvShow> recommendations;

  String posterUrl({String size = 'w500'}) =>
      ApiConstants.posterUrl(posterPath, size: size);

  String backdropUrl({String size = 'original'}) =>
      ApiConstants.backdropUrl(backdropPath, size: size);

  String? get firstAirYear => firstAirDate.year;
  String get formattedRating => voteCount == 0 ? 'NR' : voteAverage.rating;

  /// e.g. `"3 Seasons"` / `"1 Season"`; `""` when unknown.
  String get seasonsLabel => numberOfSeasons <= 0
      ? ''
      : '$numberOfSeasons ${numberOfSeasons == 1 ? 'Season' : 'Seasons'}';

  /// e.g. `"24 Episodes"` / `"1 Episode"`; `""` when unknown.
  String get episodesLabel => numberOfEpisodes <= 0
      ? ''
      : '$numberOfEpisodes ${numberOfEpisodes == 1 ? 'Episode' : 'Episodes'}';

  @override
  List<Object?> get props => [
    id,
    name,
    tagline,
    overview,
    posterPath,
    backdropPath,
    firstAirDate,
    lastAirDate,
    voteAverage,
    voteCount,
    numberOfSeasons,
    numberOfEpisodes,
    episodeRunTime,
    genres,
    status,
    cast,
    recommendations,
  ];
}
