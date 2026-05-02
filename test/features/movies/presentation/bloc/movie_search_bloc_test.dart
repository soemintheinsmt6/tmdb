import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_search_bloc/movie_search_state.dart';

import '../../../../helpers/movie_fixtures.dart';

class _MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late _MockMovieRepository repository;

  setUp(() {
    repository = _MockMovieRepository();
  });

  group('MovieSearchQueryChanged', () {
    blocTest<MovieSearchBloc, MovieSearchState>(
      'emits Idle when the query is empty (no repo call)',
      build: () => MovieSearchBloc(repository: repository),
      act: (bloc) => bloc.add(const MovieSearchQueryChanged('   ')),
      expect: () => const [MovieSearchIdle()],
      verify: (_) {
        verifyNever(() => repository.searchMovies(
              query: any(named: 'query'),
              page: any(named: 'page'),
            ));
      },
    );

    blocTest<MovieSearchBloc, MovieSearchState>(
      'emits Loading then Loaded when the query has results',
      setUp: () {
        when(() => repository.searchMovies(query: 'inception', page: 1))
            .thenAnswer(
          (_) async => Right(
            buildPaginated(
              page: 1,
              totalPages: 2,
              movies: [buildMovie(id: 27205, title: 'Inception')],
            ),
          ),
        );
      },
      build: () => MovieSearchBloc(repository: repository),
      act: (bloc) => bloc.add(const MovieSearchQueryChanged('inception')),
      expect: () => [
        const MovieSearchLoading(),
        isA<MovieSearchLoaded>()
            .having((s) => s.query, 'query', 'inception')
            .having((s) => s.movies.first.id, 'first movie id', 27205)
            .having((s) => s.totalPages, 'totalPages', 2),
      ],
    );

    blocTest<MovieSearchBloc, MovieSearchState>(
      'emits Loading then Error on a failed query',
      setUp: () {
        when(() => repository.searchMovies(query: 'x', page: 1)).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'offline')),
        );
      },
      build: () => MovieSearchBloc(repository: repository),
      act: (bloc) => bloc.add(const MovieSearchQueryChanged('x')),
      expect: () => const [
        MovieSearchLoading(),
        MovieSearchError(message: 'offline'),
      ],
    );
  });

  group('MovieSearchLoadMore', () {
    blocTest<MovieSearchBloc, MovieSearchState>(
      'appends the next page',
      setUp: () {
        when(() => repository.searchMovies(query: 'fight', page: 1))
            .thenAnswer(
          (_) async => Right(
            buildPaginated(
              page: 1,
              totalPages: 3,
              movies: [buildMovie(id: 1)],
            ),
          ),
        );
        when(() => repository.searchMovies(query: 'fight', page: 2))
            .thenAnswer(
          (_) async => Right(
            buildPaginated(
              page: 2,
              totalPages: 3,
              movies: [buildMovie(id: 2)],
            ),
          ),
        );
      },
      build: () => MovieSearchBloc(repository: repository),
      act: (bloc) async {
        bloc.add(const MovieSearchQueryChanged('fight'));
        // Wait for the first query to settle into Loaded before paginating.
        await bloc.stream.firstWhere((s) => s is MovieSearchLoaded);
        bloc.add(const MovieSearchLoadMore());
      },
      skip: 2, // Loading + first Loaded
      expect: () => [
        isA<MovieSearchLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<MovieSearchLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.movies.map((m) => m.id).toList(),
                'movie ids', [1, 2])
            .having((s) => s.page, 'page', 2),
      ],
    );

    blocTest<MovieSearchBloc, MovieSearchState>(
      'is a no-op when not in a Loaded state',
      build: () => MovieSearchBloc(repository: repository),
      act: (bloc) => bloc.add(const MovieSearchLoadMore()),
      expect: () => const <MovieSearchState>[],
      verify: (_) {
        verifyNever(() => repository.searchMovies(
              query: any(named: 'query'),
              page: any(named: 'page'),
            ));
      },
    );
  });

  blocTest<MovieSearchBloc, MovieSearchState>(
    'MovieSearchCleared resets to Idle',
    setUp: () {
      when(() => repository.searchMovies(query: 'x', page: 1)).thenAnswer(
        (_) async => Right(buildPaginated(movies: [buildMovie()])),
      );
    },
    build: () => MovieSearchBloc(repository: repository),
    act: (bloc) async {
      bloc.add(const MovieSearchQueryChanged('x'));
      await bloc.stream.firstWhere((s) => s is MovieSearchLoaded);
      bloc.add(const MovieSearchCleared());
    },
    skip: 2,
    expect: () => const [MovieSearchIdle()],
  );
}
