import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/movies/domain/entities/movie_collection.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/shared/domain/cast_member.dart';
import 'package:tmdb/shared/domain/genre.dart';
import 'package:tmdb/shared/domain/media_image.dart';
import 'package:tmdb/shared/domain/review.dart';
import 'package:tmdb/shared/domain/video.dart';

/// Reusable builders. Every parameter has a sensible default so tests only
/// override the fields that matter to the assertion.
Movie buildMovie({
  int id = 550,
  String title = 'Fight Club',
  String overview = 'An insomniac office worker forms an underground club.',
  String? posterPath = '/poster.jpg',
  String? backdropPath = '/backdrop.jpg',
  String releaseDate = '1999-10-15',
  double voteAverage = 8.4,
  int voteCount = 27000,
  List<int> genreIds = const [18, 53],
}) {
  return Movie(
    id: id,
    title: title,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    releaseDate: releaseDate,
    voteAverage: voteAverage,
    voteCount: voteCount,
    genreIds: genreIds,
  );
}

PaginatedMovies buildPaginated({
  List<Movie>? movies,
  int page = 1,
  int totalPages = 5,
  int totalResults = 100,
}) {
  return PaginatedMovies(
    movies: movies ?? [buildMovie()],
    page: page,
    totalPages: totalPages,
    totalResults: totalResults,
  );
}

CastMember buildCastMember({
  int id = 1,
  String name = 'Brad Pitt',
  String character = 'Tyler Durden',
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

Genre buildGenre({int id = 18, String name = 'Drama'}) {
  return Genre(id: id, name: name);
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
  String content = 'A taut, surprising thriller.',
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

MediaImage buildImage({
  String filePath = '/backdrop.jpg',
  double aspectRatio = 16 / 9,
  int width = 1920,
  int height = 1080,
}) {
  return MediaImage(
    filePath: filePath,
    aspectRatio: aspectRatio,
    width: width,
    height: height,
  );
}

MovieDetail buildMovieDetail({
  int id = 550,
  String title = 'Fight Club',
  String tagline = 'Mischief. Mayhem. Soap.',
  String overview = 'An insomniac office worker...',
  String? posterPath = '/poster.jpg',
  String? backdropPath = '/backdrop.jpg',
  String releaseDate = '1999-10-15',
  double voteAverage = 8.4,
  int voteCount = 27000,
  int runtime = 139,
  List<Genre>? genres,
  String status = 'Released',
  List<CastMember> cast = const [],
  List<Movie> recommendations = const [],
  List<Video> videos = const [],
  List<Review> reviews = const [],
  List<MediaImage> images = const [],
  String? imdbId = 'tt0137523',
  MovieCollectionRef? collection,
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
    genres: genres ?? const [Genre(id: 18, name: 'Drama')],
    status: status,
    cast: cast,
    recommendations: recommendations,
    videos: videos,
    reviews: reviews,
    images: images,
    imdbId: imdbId,
    collection: collection,
  );
}

MovieCollectionRef buildMovieCollectionRef({
  int id = 2344,
  String name = 'The Matrix Collection',
  String? posterPath = '/collection_poster.jpg',
  String? backdropPath = '/collection_backdrop.jpg',
}) {
  return MovieCollectionRef(
    id: id,
    name: name,
    posterPath: posterPath,
    backdropPath: backdropPath,
  );
}

MovieCollection buildMovieCollection({
  int id = 2344,
  String name = 'The Matrix Collection',
  String overview = 'A series about a simulated reality.',
  String? posterPath = '/collection_poster.jpg',
  String? backdropPath = '/collection_backdrop.jpg',
  List<Movie>? parts,
}) {
  return MovieCollection(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    parts: parts ?? [buildMovie(id: 603), buildMovie(id: 604)],
  );
}
