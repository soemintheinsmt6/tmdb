import 'package:equatable/equatable.dart';
import 'package:tmdb/features/movies/data/models/movie.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository.dart';

abstract class MovieListState extends Equatable {
  const MovieListState({required this.category});
  final MovieCategory category;

  @override
  List<Object?> get props => [category];
}

class MovieListInitial extends MovieListState {
  const MovieListInitial({required super.category});
}

class MovieListLoading extends MovieListState {
  const MovieListLoading({required super.category});
}

class MovieListLoaded extends MovieListState {
  const MovieListLoaded({
    required super.category,
    required this.movies,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  final List<Movie> movies;
  final int page;
  final int totalPages;
  final bool isLoadingMore;

  bool get hasMore => page < totalPages;

  MovieListLoaded copyWith({
    MovieCategory? category,
    List<Movie>? movies,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return MovieListLoaded(
      category: category ?? this.category,
      movies: movies ?? this.movies,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    category,
    movies,
    page,
    totalPages,
    isLoadingMore,
  ];
}

class MovieListError extends MovieListState {
  const MovieListError({required super.category, required this.message});
  final String message;

  @override
  List<Object?> get props => [category, message];
}
