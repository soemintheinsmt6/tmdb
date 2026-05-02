import 'package:equatable/equatable.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';

class PaginatedMovies extends Equatable {
  const PaginatedMovies({
    required this.movies,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  factory PaginatedMovies.fromJson(Map<String, dynamic> json) {
    final list = ((json['results'] as List?) ?? const [])
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedMovies(
      movies: list,
      page: (json['page'] as int?) ?? 1,
      totalPages: (json['total_pages'] as int?) ?? 1,
      totalResults: (json['total_results'] as int?) ?? list.length,
    );
  }

  final List<Movie> movies;
  final int page;
  final int totalPages;
  final int totalResults;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [movies, page, totalPages, totalResults];
}
