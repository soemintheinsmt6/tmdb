import 'package:tmdb/features/movies/domain/entities/cast_member.dart';
import 'package:tmdb/features/movies/domain/entities/genre.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';

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
  );
}
