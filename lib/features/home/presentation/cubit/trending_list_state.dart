import 'package:equatable/equatable.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

enum TrendingListStatus { initial, loading, loaded, error }

/// State of the paged trending grid.
class TrendingListState extends Equatable {
  const TrendingListState({
    this.status = TrendingListStatus.initial,
    this.items = const [],
    this.page = 0,
    this.totalPages = 0,
    this.isLoadingMore = false,
    this.message = '',
  });

  final TrendingListStatus status;
  final List<PosterItem> items;
  final int page;
  final int totalPages;
  final bool isLoadingMore;
  final String message;

  bool get hasMore => page < totalPages;

  TrendingListState copyWith({
    TrendingListStatus? status,
    List<PosterItem>? items,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
    String? message,
  }) {
    return TrendingListState(
      status: status ?? this.status,
      items: items ?? this.items,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    items,
    page,
    totalPages,
    isLoadingMore,
    message,
  ];
}
