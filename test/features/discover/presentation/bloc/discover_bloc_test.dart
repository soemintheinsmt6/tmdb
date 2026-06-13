import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/discover/domain/repositories/discover_repository.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_bloc.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_event.dart';
import 'package:tmdb/features/discover/presentation/bloc/discover_state.dart';
import 'package:tmdb/shared/domain/genre.dart';

import '../../../../helpers/movie_fixtures.dart';

class _MockDiscoverRepository extends Mock implements DiscoverRepository {}

void main() {
  setUpAll(() => registerFallbackValue(const DiscoverFilter()));

  late _MockDiscoverRepository repository;

  setUp(() => repository = _MockDiscoverRepository());

  const genres = [Genre(id: 28, name: 'Action')];
  final page1 = buildPaginated(
    page: 1,
    totalPages: 3,
    movies: [buildMovie(id: 1)],
  );
  final page2 = buildPaginated(
    page: 2,
    totalPages: 3,
    movies: [buildMovie(id: 2)],
  );

  group('DiscoverStarted', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'loads genres then the first page',
      setUp: () {
        when(
          () => repository.getMovieGenres(),
        ).thenAnswer((_) async => const Right(genres));
        when(
          () =>
              repository.discoverMovies(filter: any(named: 'filter'), page: 1),
        ).thenAnswer((_) async => Right(page1));
      },
      build: () => DiscoverBloc(repository: repository),
      act: (bloc) => bloc.add(const DiscoverStarted()),
      expect: () => [
        const DiscoverState(status: DiscoverStatus.loading),
        DiscoverState(
          status: DiscoverStatus.loaded,
          genres: genres,
          movies: page1.movies,
          page: 1,
          totalPages: 3,
        ),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'still loads results when the genre fetch fails (best-effort)',
      setUp: () {
        when(() => repository.getMovieGenres()).thenAnswer(
          (_) async => const Left(NetworkFailure(message: 'offline')),
        );
        when(
          () =>
              repository.discoverMovies(filter: any(named: 'filter'), page: 1),
        ).thenAnswer((_) async => Right(page1));
      },
      build: () => DiscoverBloc(repository: repository),
      act: (bloc) => bloc.add(const DiscoverStarted()),
      expect: () => [
        const DiscoverState(status: DiscoverStatus.loading),
        DiscoverState(
          status: DiscoverStatus.loaded,
          movies: page1.movies,
          page: 1,
          totalPages: 3,
        ),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'emits error when the first page fails',
      setUp: () {
        when(
          () => repository.getMovieGenres(),
        ).thenAnswer((_) async => const Right(genres));
        when(
          () =>
              repository.discoverMovies(filter: any(named: 'filter'), page: 1),
        ).thenAnswer(
          (_) async =>
              const Left(ServerFailure(message: 'boom', statusCode: 500)),
        );
      },
      build: () => DiscoverBloc(repository: repository),
      act: (bloc) => bloc.add(const DiscoverStarted()),
      expect: () => [
        const DiscoverState(status: DiscoverStatus.loading),
        const DiscoverState(
          status: DiscoverStatus.error,
          genres: genres,
          message: 'boom',
        ),
      ],
    );
  });

  group('DiscoverFilterApplied', () {
    const filter = DiscoverFilter(genreIds: {28});
    blocTest<DiscoverBloc, DiscoverState>(
      'reloads page 1 with the new filter',
      setUp: () {
        when(
          () => repository.discoverMovies(filter: filter, page: 1),
        ).thenAnswer((_) async => Right(page1));
      },
      build: () => DiscoverBloc(repository: repository),
      seed: () => const DiscoverState(
        status: DiscoverStatus.loaded,
        genres: genres,
        movies: [],
      ),
      act: (bloc) => bloc.add(const DiscoverFilterApplied(filter)),
      expect: () => [
        const DiscoverState(
          status: DiscoverStatus.loading,
          genres: genres,
          filter: filter,
        ),
        DiscoverState(
          status: DiscoverStatus.loaded,
          genres: genres,
          filter: filter,
          movies: page1.movies,
          page: 1,
          totalPages: 3,
        ),
      ],
    );
  });

  group('DiscoverLoadMore', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'appends the next page',
      setUp: () {
        when(
          () =>
              repository.discoverMovies(filter: any(named: 'filter'), page: 2),
        ).thenAnswer((_) async => Right(page2));
      },
      build: () => DiscoverBloc(repository: repository),
      seed: () => DiscoverState(
        status: DiscoverStatus.loaded,
        movies: page1.movies,
        page: 1,
        totalPages: 3,
      ),
      act: (bloc) => bloc.add(const DiscoverLoadMore()),
      expect: () => [
        DiscoverState(
          status: DiscoverStatus.loaded,
          movies: page1.movies,
          page: 1,
          totalPages: 3,
          isLoadingMore: true,
        ),
        DiscoverState(
          status: DiscoverStatus.loaded,
          movies: [...page1.movies, ...page2.movies],
          page: 2,
          totalPages: 3,
        ),
      ],
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'does nothing on the last page',
      build: () => DiscoverBloc(repository: repository),
      seed: () => DiscoverState(
        status: DiscoverStatus.loaded,
        movies: page1.movies,
        page: 3,
        totalPages: 3,
      ),
      act: (bloc) => bloc.add(const DiscoverLoadMore()),
      expect: () => const <DiscoverState>[],
    );
  });
}
