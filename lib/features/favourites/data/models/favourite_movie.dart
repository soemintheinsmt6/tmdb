import 'package:objectbox/objectbox.dart';
import 'package:tmdb/features/movies/data/models/movie.dart';

@Entity()
class FavouriteMovie {
  FavouriteMovie({
    this.id = 0,
    required this.movieId,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    required this.releaseDate,
    required this.voteAverage,
    required this.voteCount,
    required this.savedAt,
  });

  @Id()
  int id;

  @Index(type: IndexType.value)
  @Unique()
  int movieId;

  String title;
  String overview;
  String? posterPath;
  String? backdropPath;
  String releaseDate;
  double voteAverage;
  int voteCount;

  @Property(type: PropertyType.date)
  DateTime savedAt;

  factory FavouriteMovie.fromMovie(Movie m) => FavouriteMovie(
        movieId: m.id,
        title: m.title,
        overview: m.overview,
        posterPath: m.posterPath,
        backdropPath: m.backdropPath,
        releaseDate: m.releaseDate,
        voteAverage: m.voteAverage,
        voteCount: m.voteCount,
        savedAt: DateTime.now(),
      );

  Movie toMovie() => Movie(
        id: movieId,
        title: title,
        overview: overview,
        posterPath: posterPath,
        backdropPath: backdropPath,
        releaseDate: releaseDate,
        voteAverage: voteAverage,
        voteCount: voteCount,
        genreIds: const [],
      );
}
