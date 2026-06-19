import 'package:equatable/equatable.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/extensions/double_rating.dart';

/// One episode within a [SeasonDetail], from `/tv/{id}/season/{n}`.
class Episode extends Equatable {
  const Episode({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.airDate,
    required this.voteAverage,
    required this.voteCount,
    required this.runtime,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: (json['id'] as int?) ?? 0,
      episodeNumber: (json['episode_number'] as int?) ?? 0,
      seasonNumber: (json['season_number'] as int?) ?? 0,
      name: json['name'] as String? ?? '',
      overview: json['overview'] as String? ?? '',
      stillPath: json['still_path'] as String?,
      airDate: json['air_date'] as String? ?? '',
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      voteCount: (json['vote_count'] as int?) ?? 0,
      runtime: json['runtime'] as int?,
    );
  }

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String overview;
  final String? stillPath;
  final String airDate;
  final double voteAverage;
  final int voteCount;
  final int? runtime;

  /// 16:9 still frame; reuses the backdrop image base (same size buckets).
  String stillUrl({String size = 'w300'}) =>
      ApiConstants.backdropUrl(stillPath, size: size);

  String get formattedRating => voteCount == 0 ? 'NR' : voteAverage.rating;

  /// e.g. `"48 min"`; `""` when unknown.
  String get runtimeLabel =>
      (runtime == null || runtime! <= 0) ? '' : '$runtime min';

  @override
  List<Object?> get props => [
    id,
    episodeNumber,
    seasonNumber,
    name,
    overview,
    stillPath,
    airDate,
    voteAverage,
    voteCount,
    runtime,
  ];
}
