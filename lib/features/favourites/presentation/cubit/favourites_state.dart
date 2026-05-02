import 'package:equatable/equatable.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

class FavouritesState extends Equatable {
  const FavouritesState({this.movies = const [], this.ids = const {}});

  factory FavouritesState.fromMovies(List<Movie> movies) {
    return FavouritesState(
      movies: movies,
      ids: movies.map((m) => m.id).toSet(),
    );
  }

  final List<Movie> movies;
  final Set<int> ids;

  bool contains(int movieId) => ids.contains(movieId);

  @override
  List<Object?> get props => [movies, ids];
}
