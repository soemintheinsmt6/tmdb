import 'package:equatable/equatable.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

abstract class MovieSearchState extends Equatable {
  const MovieSearchState();

  @override
  List<Object?> get props => [];
}

/// Initial empty state — shows trending tabs underneath.
class MovieSearchIdle extends MovieSearchState {
  const MovieSearchIdle();
}

class MovieSearchLoading extends MovieSearchState {
  const MovieSearchLoading();
}

class MovieSearchLoaded extends MovieSearchState {
  const MovieSearchLoaded({
    required this.query,
    required this.movies,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  final String query;
  final List<Movie> movies;
  final int page;
  final int totalPages;
  final bool isLoadingMore;

  bool get hasMore => page < totalPages;

  MovieSearchLoaded copyWith({
    String? query,
    List<Movie>? movies,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return MovieSearchLoaded(
      query: query ?? this.query,
      movies: movies ?? this.movies,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [query, movies, page, totalPages, isLoadingMore];
}

class MovieSearchError extends MovieSearchState {
  const MovieSearchError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
