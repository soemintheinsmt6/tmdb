import 'package:equatable/equatable.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';

class PaginatedTvShows extends Equatable {
  const PaginatedTvShows({
    required this.shows,
    required this.page,
    required this.totalPages,
    required this.totalResults,
  });

  factory PaginatedTvShows.fromJson(Map<String, dynamic> json) {
    final list = ((json['results'] as List?) ?? const [])
        .map((e) => TvShow.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedTvShows(
      shows: list,
      page: (json['page'] as int?) ?? 1,
      totalPages: (json['total_pages'] as int?) ?? 1,
      totalResults: (json['total_results'] as int?) ?? list.length,
    );
  }

  final List<TvShow> shows;
  final int page;
  final int totalPages;
  final int totalResults;

  bool get hasMore => page < totalPages;

  @override
  List<Object?> get props => [shows, page, totalPages, totalResults];
}
