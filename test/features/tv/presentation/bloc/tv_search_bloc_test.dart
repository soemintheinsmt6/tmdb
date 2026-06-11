import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_bloc.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_event.dart';
import 'package:tmdb/features/tv/presentation/bloc/tv_search_bloc/tv_search_state.dart';

import '../../../../helpers/tv_fixtures.dart';

class _MockTvRepository extends Mock implements TvRepository {}

void main() {
  late _MockTvRepository repository;

  setUp(() {
    repository = _MockTvRepository();
  });

  group('TvSearchQueryChanged', () {
    blocTest<TvSearchBloc, TvSearchState>(
      'emits Idle when the query is empty (no repo call)',
      build: () => TvSearchBloc(repository: repository),
      act: (bloc) => bloc.add(const TvSearchQueryChanged('   ')),
      expect: () => const [TvSearchIdle()],
      verify: (_) {
        verifyNever(
          () => repository.searchTvShows(
            query: any(named: 'query'),
            page: any(named: 'page'),
          ),
        );
      },
    );

    blocTest<TvSearchBloc, TvSearchState>(
      'emits Loading then Loaded when the query has results',
      setUp: () {
        when(
          () => repository.searchTvShows(query: 'thrones', page: 1),
        ).thenAnswer(
          (_) async => Right(
            buildPaginatedTv(
              page: 1,
              totalPages: 2,
              shows: [buildTvShow(id: 1399, name: 'Game of Thrones')],
            ),
          ),
        );
      },
      build: () => TvSearchBloc(repository: repository),
      act: (bloc) => bloc.add(const TvSearchQueryChanged('thrones')),
      expect: () => [
        const TvSearchLoading(),
        isA<TvSearchLoaded>()
            .having((s) => s.query, 'query', 'thrones')
            .having((s) => s.shows.first.id, 'first show id', 1399)
            .having((s) => s.totalPages, 'totalPages', 2),
      ],
    );

    blocTest<TvSearchBloc, TvSearchState>(
      'emits Loading then Error on a failed query',
      setUp: () {
        when(() => repository.searchTvShows(query: 'x', page: 1)).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'offline')),
        );
      },
      build: () => TvSearchBloc(repository: repository),
      act: (bloc) => bloc.add(const TvSearchQueryChanged('x')),
      expect: () => const [
        TvSearchLoading(),
        TvSearchError(message: 'offline'),
      ],
    );
  });

  group('TvSearchLoadMore', () {
    blocTest<TvSearchBloc, TvSearchState>(
      'appends the next page',
      setUp: () {
        when(
          () => repository.searchTvShows(query: 'thrones', page: 1),
        ).thenAnswer(
          (_) async => Right(
            buildPaginatedTv(
              page: 1,
              totalPages: 3,
              shows: [buildTvShow(id: 1)],
            ),
          ),
        );
        when(
          () => repository.searchTvShows(query: 'thrones', page: 2),
        ).thenAnswer(
          (_) async => Right(
            buildPaginatedTv(
              page: 2,
              totalPages: 3,
              shows: [buildTvShow(id: 2)],
            ),
          ),
        );
      },
      build: () => TvSearchBloc(repository: repository),
      act: (bloc) async {
        bloc.add(const TvSearchQueryChanged('thrones'));
        // Wait for the first query to settle into Loaded before paginating.
        await bloc.stream.firstWhere((s) => s is TvSearchLoaded);
        bloc.add(const TvSearchLoadMore());
      },
      skip: 2, // Loading + first Loaded
      expect: () => [
        isA<TvSearchLoaded>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          true,
        ),
        isA<TvSearchLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.shows.map((m) => m.id).toList(), 'show ids', [
              1,
              2,
            ])
            .having((s) => s.page, 'page', 2),
      ],
    );

    blocTest<TvSearchBloc, TvSearchState>(
      'is a no-op when not in a Loaded state',
      build: () => TvSearchBloc(repository: repository),
      act: (bloc) => bloc.add(const TvSearchLoadMore()),
      expect: () => const <TvSearchState>[],
      verify: (_) {
        verifyNever(
          () => repository.searchTvShows(
            query: any(named: 'query'),
            page: any(named: 'page'),
          ),
        );
      },
    );
  });

  blocTest<TvSearchBloc, TvSearchState>(
    'TvSearchCleared resets to Idle',
    setUp: () {
      when(() => repository.searchTvShows(query: 'x', page: 1)).thenAnswer(
        (_) async => Right(buildPaginatedTv(shows: [buildTvShow()])),
      );
    },
    build: () => TvSearchBloc(repository: repository),
    act: (bloc) async {
      bloc.add(const TvSearchQueryChanged('x'));
      await bloc.stream.firstWhere((s) => s is TvSearchLoaded);
      bloc.add(const TvSearchCleared());
    },
    skip: 2,
    expect: () => const [TvSearchIdle()],
  );
}
