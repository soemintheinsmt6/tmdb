import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/discover/domain/repositories/discover_repository.dart';
import 'package:tmdb/shared/domain/genre.dart';
import 'package:tmdb/shared/domain/poster_item.dart';

import 'discover_event.dart';
import 'discover_state.dart';

/// A page of discover results, normalised across movies and TV.
typedef _Page = ({List<PosterItem> items, int page, int totalPages});

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  DiscoverBloc({required DiscoverRepository repository})
    : _repository = repository,
      super(const DiscoverState()) {
    on<DiscoverStarted>(_onStarted);
    on<DiscoverMediaTypeChanged>(_onMediaTypeChanged);
    on<DiscoverFilterApplied>(_onFilterApplied);
    on<DiscoverLoadMore>(_onLoadMore);
    on<DiscoverRefreshed>(_onRefreshed);
  }

  final DiscoverRepository _repository;

  Future<void> _onStarted(
    DiscoverStarted event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(state.copyWith(status: DiscoverStatus.loading));
    // Genres are best-effort: a failure here just leaves the genre filter empty.
    final genres = (await _genres(
      state.filter.mediaType,
    )).getOrElse(() => state.genres);
    await _loadFirstPage(emit, state.filter, genres: genres);
  }

  Future<void> _onMediaTypeChanged(
    DiscoverMediaTypeChanged event,
    Emitter<DiscoverState> emit,
  ) async {
    if (event.mediaType == state.filter.mediaType) return;
    // Genre ids differ between verticals, so reset the genre selection.
    final filter = state.filter.copyWith(
      mediaType: event.mediaType,
      genreIds: {},
    );
    emit(
      state.copyWith(
        status: DiscoverStatus.loading,
        filter: filter,
        genres: const [],
      ),
    );
    final genres = (await _genres(filter.mediaType)).getOrElse(() => const []);
    await _loadFirstPage(emit, filter, genres: genres);
  }

  Future<void> _onFilterApplied(
    DiscoverFilterApplied event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(state.copyWith(status: DiscoverStatus.loading, filter: event.filter));
    await _loadFirstPage(emit, event.filter);
  }

  Future<void> _onRefreshed(
    DiscoverRefreshed event,
    Emitter<DiscoverState> emit,
  ) async {
    await _loadFirstPage(emit, state.filter);
  }

  /// Loads page 1 for [filter]. [genres] is passed by the events that refresh
  /// the genre list ([DiscoverStarted], [DiscoverMediaTypeChanged]); when null,
  /// the existing genres in state are preserved via copyWith.
  Future<void> _loadFirstPage(
    Emitter<DiscoverState> emit,
    DiscoverFilter filter, {
    List<Genre>? genres,
  }) async {
    final result = await _fetch(filter, 1);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: DiscoverStatus.error,
          message: failure.message,
          genres: genres,
        ),
      ),
      (page) => emit(
        state.copyWith(
          status: DiscoverStatus.loaded,
          genres: genres,
          items: page.items,
          page: page.page,
          totalPages: page.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  Future<void> _onLoadMore(
    DiscoverLoadMore event,
    Emitter<DiscoverState> emit,
  ) async {
    if (state.status != DiscoverStatus.loaded) return;
    if (!state.hasMore || state.isLoadingMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final result = await _fetch(state.filter, state.page + 1);
    result.fold(
      (_) => emit(state.copyWith(isLoadingMore: false)),
      (page) => emit(
        state.copyWith(
          items: [...state.items, ...page.items],
          page: page.page,
          totalPages: page.totalPages,
          isLoadingMore: false,
        ),
      ),
    );
  }

  /// Routes to the movie or TV discover endpoint based on [filter]'s media
  /// type and normalises both into a [_Page].
  ResultFuture<_Page> _fetch(DiscoverFilter filter, int page) async {
    if (filter.mediaType == MediaType.movie) {
      final result = await _repository.discoverMovies(
        filter: filter,
        page: page,
      );
      return result.map<_Page>(
        (p) => (items: p.movies, page: p.page, totalPages: p.totalPages),
      );
    } else {
      final result = await _repository.discoverTv(filter: filter, page: page);
      return result.map<_Page>(
        (p) => (items: p.shows, page: p.page, totalPages: p.totalPages),
      );
    }
  }

  ResultFuture<List<Genre>> _genres(MediaType mediaType) {
    return mediaType == MediaType.movie
        ? _repository.getMovieGenres()
        : _repository.getTvGenres();
  }
}
