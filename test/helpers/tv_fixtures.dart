import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';
import 'package:tmdb/shared/domain/cast_member.dart';
import 'package:tmdb/shared/domain/genre.dart';
import 'package:tmdb/shared/domain/review.dart';
import 'package:tmdb/shared/domain/video.dart';

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
  List<Video> videos = const [],
  List<Review> reviews = const [],
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
    videos: videos,
    reviews: reviews,
  );
}

Video buildVideo({
  String id = 'v1',
  String key = 'abc123',
  String name = 'Official Trailer',
  String site = 'YouTube',
  String type = 'Trailer',
  bool official = true,
  String publishedAt = '2024-01-01T00:00:00.000Z',
}) {
  return Video(
    id: id,
    key: key,
    name: name,
    site: site,
    type: type,
    official: official,
    publishedAt: publishedAt,
  );
}

Review buildReview({
  String id = 'r1',
  String author = 'Roger Ebert',
  String username = 'rebert',
  String? avatarPath = '/avatar.jpg',
  double? rating = 8.0,
  String content = 'Gripping from start to finish.',
  String createdAt = '2021-06-23T12:00:00.000Z',
}) {
  return Review(
    id: id,
    author: author,
    username: username,
    avatarPath: avatarPath,
    rating: rating,
    content: content,
    createdAt: createdAt,
  );
}
