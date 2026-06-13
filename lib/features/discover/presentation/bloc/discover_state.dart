import 'package:equatable/equatable.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/shared/domain/genre.dart';

enum DiscoverStatus { initial, loading, loaded, error }

/// Single immutable state for the discover screen. A flat state (rather than
/// subclasses) keeps [genres] and [filter] available across loading/error so
/// the filter sheet always has what it needs.
class DiscoverState extends Equatable {
  const DiscoverState({
    this.status = DiscoverStatus.initial,
    this.genres = const [],
    this.filter = const DiscoverFilter(),
    this.movies = const [],
    this.page = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.message = '',
  });

  final DiscoverStatus status;
  final List<Genre> genres;
  final DiscoverFilter filter;
  final List<Movie> movies;
  final int page;
  final int totalPages;
  final bool isLoadingMore;
  final String message;

  bool get hasMore => page < totalPages;

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<Genre>? genres,
    DiscoverFilter? filter,
    List<Movie>? movies,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
    String? message,
  }) {
    return DiscoverState(
      status: status ?? this.status,
      genres: genres ?? this.genres,
      filter: filter ?? this.filter,
      movies: movies ?? this.movies,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    genres,
    filter,
    movies,
    page,
    totalPages,
    isLoadingMore,
    message,
  ];
}
