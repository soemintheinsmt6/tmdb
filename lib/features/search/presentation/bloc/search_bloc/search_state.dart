import 'package:equatable/equatable.dart';
import 'package:tmdb/features/search/domain/entities/search_result.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

/// No active query — shows the idle prompt.
class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  const SearchLoaded({
    required this.query,
    required this.results,
    required this.page,
    required this.totalPages,
    this.isLoadingMore = false,
  });

  final String query;
  final List<SearchResult> results;
  final int page;
  final int totalPages;
  final bool isLoadingMore;

  bool get hasMore => page < totalPages;

  SearchLoaded copyWith({
    String? query,
    List<SearchResult>? results,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return SearchLoaded(
      query: query ?? this.query,
      results: results ?? this.results,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [query, results, page, totalPages, isLoadingMore];
}

class SearchError extends SearchState {
  const SearchError({required this.message});
  final String message;

  @override
  List<Object?> get props => [message];
}
