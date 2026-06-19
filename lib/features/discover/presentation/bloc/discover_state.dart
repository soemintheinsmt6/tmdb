import 'package:equatable/equatable.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/shared/domain/media/genre.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

enum DiscoverStatus { initial, loading, loaded, error }

/// Single immutable state for the discover screen. A flat state (rather than
/// subclasses) keeps [genres] and [filter] available across loading/error so
/// the filter sheet always has what it needs. [items] holds movies or TV shows
/// depending on [filter]'s media type — both are [PosterItem]s.
class DiscoverState extends Equatable {
  const DiscoverState({
    this.status = DiscoverStatus.initial,
    this.genres = const [],
    this.filter = const DiscoverFilter(),
    this.items = const [],
    this.page = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.message = '',
  });

  final DiscoverStatus status;

  /// Genre list for the active media type (movie or TV).
  final List<Genre> genres;
  final DiscoverFilter filter;
  final List<PosterItem> items;
  final int page;
  final int totalPages;
  final bool isLoadingMore;
  final String message;

  bool get hasMore => page < totalPages;

  DiscoverState copyWith({
    DiscoverStatus? status,
    List<Genre>? genres,
    DiscoverFilter? filter,
    List<PosterItem>? items,
    int? page,
    int? totalPages,
    bool? isLoadingMore,
    String? message,
  }) {
    return DiscoverState(
      status: status ?? this.status,
      genres: genres ?? this.genres,
      filter: filter ?? this.filter,
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
    genres,
    filter,
    items,
    page,
    totalPages,
    isLoadingMore,
    message,
  ];
}
