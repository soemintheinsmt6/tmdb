import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_list_bloc/movie_list_state.dart';

import '../../../../helpers/movie_fixtures.dart';

class _MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late _MockMovieRepository repository;

  setUp(() {
    repository = _MockMovieRepository();
  });

  // The bloc fires MovieListCategoryChanged(initialCategory) in its
  // constructor, so every test sees [Loading, Loaded] before the action
  // under test. Tests that exercise other behaviour use `skip: 2`.
  final initialPage = buildPaginated(
    page: 1,
    totalPages: 3,
    movies: [buildMovie(id: 1)],
  );

  void stubInitial({
    MovieCategory category = MovieCategory.popular,
    PaginatedMovies? page,
  }) {
    when(() => repository.getMovies(category: category, page: 1))
        .thenAnswer((_) async => Right(page ?? initialPage));
  }

  group('initial category fetch', () {
    blocTest<MovieListBloc, MovieListState>(
      'emits Loading then Loaded for the initial category',
      setUp: stubInitial,
      build: () => MovieListBloc(repository: repository),
      expect: () => [
        const MovieListLoading(category: MovieCategory.popular),
        MovieListLoaded(
          category: MovieCategory.popular,
          movies: initialPage.movies,
          page: 1,
          totalPages: 3,
        ),
      ],
    );

    blocTest<MovieListBloc, MovieListState>(
      'emits Loading then Error when the initial fetch fails',
      setUp: () {
        when(() =>
                repository.getMovies(category: MovieCategory.popular, page: 1))
            .thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'oops', statusCode: 500),
          ),
        );
      },
      build: () => MovieListBloc(repository: repository),
      expect: () => const [
        MovieListLoading(category: MovieCategory.popular),
        MovieListError(category: MovieCategory.popular, message: 'oops'),
      ],
    );
  });

  group('MovieListLoadMore', () {
    blocTest<MovieListBloc, MovieListState>(
      'appends the next page and clears the loading flag',
      setUp: () {
        stubInitial();
        when(() =>
                repository.getMovies(category: MovieCategory.popular, page: 2))
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
      build: () => MovieListBloc(repository: repository),
      act: (bloc) => bloc.add(const MovieListLoadMore()),
      skip: 2, // initial Loading + Loaded
      expect: () => [
        isA<MovieListLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true)
            .having((s) => s.movies.length, 'movies.length', 1),
        isA<MovieListLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.page, 'page', 2)
            .having((s) => s.movies.map((m) => m.id).toList(),
                'movie ids', [1, 2]),
      ],
    );

    blocTest<MovieListBloc, MovieListState>(
      'is a no-op when already on the last page',
      setUp: () => stubInitial(
        page: buildPaginated(
          page: 1,
          totalPages: 1,
          movies: [buildMovie(id: 1)],
        ),
      ),
      build: () => MovieListBloc(repository: repository),
      act: (bloc) => bloc.add(const MovieListLoadMore()),
      skip: 2,
      expect: () => const <MovieListState>[],
      verify: (_) {
        // Only the initial fetch — never page 2.
        verify(() =>
                repository.getMovies(category: MovieCategory.popular, page: 1))
            .called(1);
        verifyNever(() =>
            repository.getMovies(category: MovieCategory.popular, page: 2));
      },
    );

    blocTest<MovieListBloc, MovieListState>(
      'reverts the loading flag when the next page errors',
      setUp: () {
        stubInitial();
        when(() =>
                repository.getMovies(category: MovieCategory.popular, page: 2))
            .thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'nope', statusCode: 500),
          ),
        );
      },
      build: () => MovieListBloc(repository: repository),
      act: (bloc) => bloc.add(const MovieListLoadMore()),
      skip: 2,
      expect: () => [
        isA<MovieListLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', true),
        isA<MovieListLoaded>()
            .having((s) => s.isLoadingMore, 'isLoadingMore', false)
            .having((s) => s.movies.length, 'movies.length', 1),
      ],
    );
  });

  group('MovieListCategoryChanged', () {
    blocTest<MovieListBloc, MovieListState>(
      'switches category and refetches',
      setUp: () {
        stubInitial();
        when(() =>
                repository.getMovies(category: MovieCategory.topRated, page: 1))
            .thenAnswer(
          (_) async => Right(
            buildPaginated(movies: [buildMovie(id: 99)]),
          ),
        );
      },
      build: () => MovieListBloc(repository: repository),
      act: (bloc) =>
          bloc.add(const MovieListCategoryChanged(MovieCategory.topRated)),
      skip: 2,
      expect: () => [
        const MovieListLoading(category: MovieCategory.topRated),
        isA<MovieListLoaded>()
            .having((s) => s.category, 'category', MovieCategory.topRated)
            .having((s) => s.movies.first.id, 'first movie id', 99),
      ],
    );
  });
}
