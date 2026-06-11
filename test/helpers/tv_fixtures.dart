import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';
import 'package:tmdb/shared/domain/cast_member.dart';
import 'package:tmdb/shared/domain/genre.dart';

/// Reusable builders. Every parameter has a sensible default so tests only
/// override the fields that matter to the assertion.
TvShow buildTvShow({
  int id = 1399,
  String name = 'Game of Thrones',
  String overview = 'Noble families vie for control of the Iron Throne.',
  String? posterPath = '/poster.jpg',
  String? backdropPath = '/backdrop.jpg',
  String firstAirDate = '2011-04-17',
  double voteAverage = 8.4,
  int voteCount = 21000,
  List<int> genreIds = const [10765, 18],
}) {
  return TvShow(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    firstAirDate: firstAirDate,
    voteAverage: voteAverage,
    voteCount: voteCount,
    genreIds: genreIds,
  );
}

PaginatedTvShows buildPaginatedTv({
  List<TvShow>? shows,
  int page = 1,
  int totalPages = 5,
  int totalResults = 100,
}) {
  return PaginatedTvShows(
    shows: shows ?? [buildTvShow()],
    page: page,
    totalPages: totalPages,
    totalResults: totalResults,
  );
}

CastMember buildTvCastMember({
  int id = 1,
  String name = 'Emilia Clarke',
  String character = 'Daenerys Targaryen',
  String? profilePath,
  int order = 0,
}) {
  return CastMember(
    id: id,
    name: name,
    character: character,
    profilePath: profilePath,
    order: order,
  );
}

TvShowDetail buildTvShowDetail({
  int id = 1399,
  String name = 'Game of Thrones',
  String tagline = 'Winter Is Coming.',
  String overview = 'Noble families vie for control of the Iron Throne.',
  String? posterPath = '/poster.jpg',
  String? backdropPath = '/backdrop.jpg',
  String firstAirDate = '2011-04-17',
  String lastAirDate = '2019-05-19',
  double voteAverage = 8.4,
  int voteCount = 21000,
  int numberOfSeasons = 8,
  int numberOfEpisodes = 73,
  List<int> episodeRunTime = const [60],
  List<Genre>? genres,
  String status = 'Ended',
  List<CastMember> cast = const [],
  List<TvShow> recommendations = const [],
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
    genres: genres ?? const [Genre(id: 18, name: 'Drama')],
    status: status,
    cast: cast,
    recommendations: recommendations,
  );
}
