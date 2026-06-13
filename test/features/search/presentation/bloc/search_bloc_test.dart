import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/search/domain/repositories/search_repository.dart';
import 'package:tmdb/features/search/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:tmdb/features/search/presentation/bloc/search_bloc/search_event.dart';
import 'package:tmdb/features/search/presentation/bloc/search_bloc/search_state.dart';

import '../../../../helpers/search_fixtures.dart';

class _MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  late _MockSearchRepository repository;

  setUp(() {
    repository = _MockSearchRepository();
  });

  group('SearchQueryChanged', () {
    blocTest<SearchBloc, SearchState>(
      'emits Idle when the query is empty (no repo call)',
      build: () => SearchBloc(repository: repository),
      act: (bloc) => bloc.add(const SearchQueryChanged('   ')),
      expect: () => const [SearchIdle()],
      verify: (_) {
        verifyNever(
          () => repository.searchMulti(
            query: any(named: 'query'),
            page: any(named: 'page'),
          ),
        );
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits Loading then Loaded when the query has results',
      setUp: () {
        when(
          () => repository.searchMulti(query: 'matrix', page: 1),
        ).thenAnswer(
          (_) async => Right(
            buildPaginatedSearch(
              page: 1,
              totalPages: 2,
              results: [buildSearchResult(id: 603, title: 'The Matrix')],
            ),
          ),
        );
      },
      build: () => SearchBloc(repository: repository),
      act: (bloc) => bloc.add(const SearchQueryChanged('matrix')),
      expect: () => [
        const SearchLoading(),
        isA<SearchLoaded>()
            .having((s) => s.query, 'query', 'matrix')
            .having((s) => s.results.first.id, 'first result id', 603)
            .having((s) => s.totalPages, 'totalPages', 2),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits Loading then Error on a failed query',
      setUp: () {
        when(() => repository.searchMulti(query: 'x', page: 1)).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'offline')),
        );
      },
      build: () => SearchBloc(repository: repository),
      act: (bloc) => bloc.add(const SearchQueryChanged('x')),
      expect: () => const [
        SearchLoading(),
        SearchError(message: 'offline'),
      ],
    );
  });

  group('SearchLoadMore', () {
    blocTest<SearchBloc, SearchState>(
      'appends the next page',
      setUp: () {
        when(() => repository.searchMulti(query: 'matrix', page: 1)).thenAnswer(
          (_) async => Right(
            buildPaginatedSearch(
              page: 1,
              totalPages: 3,
              results: [buildSearchResult(id: 1)],
            ),
          ),
        );
        when(() => repository.searchMulti(query: 'matrix', page: 2)).thenAnswer(
          (_) async => Right(
            buildPaginatedSearch(
              page: 2,
              totalPages: 3,
              results: [buildSearchResult(id: 2)],
            ),
          ),
        );
      },
      build: () => SearchBloc(repository: repository),
      act: (bloc) async {
        bloc.add(const SearchQueryChanged('matrix'));
        // Wait for the first query to settle into Loaded before paginating.
        await bloc.stream.firstWhere((s) => s is SearchLoaded);
        bloc.add(const SearchLoadMore());
      },
      skip: 2, // Loading + first Loaded
      expect: () => [
        isA<SearchLoaded>().having(
          (s) => s.isLoadingMore,
          'isLoadingMore',
          true,
        ),
        isA<SearchLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.results.map((r) => r.id).toList(), 'result ids', [
              1,
              2,
            ])
            .having((s) => s.page, 'page', 2),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'is a no-op when not in a Loaded state',
      build: () => SearchBloc(repository: repository),
      act: (bloc) => bloc.add(const SearchLoadMore()),
      expect: () => const <SearchState>[],
      verify: (_) {
        verifyNever(
          () => repository.searchMulti(
            query: any(named: 'query'),
            page: any(named: 'page'),
          ),
        );
      },
    );
  });

  blocTest<SearchBloc, SearchState>(
    'SearchCleared resets to Idle',
    setUp: () {
      when(() => repository.searchMulti(query: 'x', page: 1)).thenAnswer(
        (_) async => Right(buildPaginatedSearch(results: [buildSearchResult()])),
      );
    },
    build: () => SearchBloc(repository: repository),
    act: (bloc) async {
      bloc.add(const SearchQueryChanged('x'));
      await bloc.stream.firstWhere((s) => s is SearchLoaded);
      bloc.add(const SearchCleared());
    },
    skip: 2,
    expect: () => const [SearchIdle()],
  );
}
