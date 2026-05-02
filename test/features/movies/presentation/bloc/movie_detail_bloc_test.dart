import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_bloc.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_event.dart';
import 'package:tmdb/features/movies/presentation/bloc/movie_detail_bloc/movie_detail_state.dart';

import '../../../../helpers/movie_fixtures.dart';

class _MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late _MockMovieRepository repository;

  setUp(() {
    repository = _MockMovieRepository();
  });

  blocTest<MovieDetailBloc, MovieDetailState>(
    'emits Loading then Loaded on a successful fetch',
    setUp: () {
      when(() => repository.getMovieDetail(550)).thenAnswer(
        (_) async => Right<Failure, MovieDetail>(buildMovieDetail()),
      );
    },
    build: () => MovieDetailBloc(repository: repository),
    act: (bloc) => bloc.add(const MovieDetailFetched(550)),
    expect: () => [
      const MovieDetailLoading(),
      MovieDetailLoaded(detail: buildMovieDetail()),
    ],
  );

  blocTest<MovieDetailBloc, MovieDetailState>(
    'emits Loading then Error when the repo returns a Failure',
    setUp: () {
      when(() => repository.getMovieDetail(any())).thenAnswer(
        (_) async => const Left(
          NetworkFailure(message: 'no internet'),
        ),
      );
    },
    build: () => MovieDetailBloc(repository: repository),
    act: (bloc) => bloc.add(const MovieDetailFetched(1)),
    expect: () => const [
      MovieDetailLoading(),
      MovieDetailError(message: 'no internet'),
    ],
  );
}
