import 'package:equatable/equatable.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';

abstract class TvSearchState extends Equatable {
  const TvSearchState();

  @override
  List<Object?> get props => [];
}

/// Initial empty state — shows the category tabs underneath.
class TvSearchIdle extends TvSearchState {
  const TvSearchIdle();
}

class TvSearchLoading extends TvSearchState {
  const TvSearchLoading();
}

class TvSearchLoaded extends TvSearchState {
  const TvSearchLoaded({
    required this.query,
    required this.shows,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  final String query;
  final List<TvShow> shows;
  final int page;
  final int totalPages;
  final bool isLoadingMore;

  bool get hasMore => page < totalPages;

  TvSearchLoaded copyWith({
    String? query,
    List<TvShow>? shows,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return TvSearchLoaded(
      query: query ?? this.query,
      shows: shows ?? this.shows,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [query, shows, page, totalPages, isLoadingMore];
}

class TvSearchError extends TvSearchState {
  const TvSearchError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
