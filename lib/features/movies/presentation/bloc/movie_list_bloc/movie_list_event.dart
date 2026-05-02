import 'package:equatable/equatable.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';

abstract class MovieListEvent extends Equatable {
  const MovieListEvent();

  @override
  List<Object?> get props => [];
}

/// Fetch (or refresh) a category's first page.
class MovieListCategoryChanged extends MovieListEvent {
  const MovieListCategoryChanged(this.category);
  final MovieCategory category;

  @override
  List<Object?> get props => [category];
}

/// Append the next page for the active category.
class MovieListLoadMore extends MovieListEvent {
  const MovieListLoadMore();
}

/// Pull-to-refresh on the active category.
class MovieListRefreshed extends MovieListEvent {
  const MovieListRefreshed();
}
