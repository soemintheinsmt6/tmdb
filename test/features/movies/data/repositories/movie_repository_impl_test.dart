import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';

import '../../../../helpers/movie_fixtures.dart';

class _MockRemote extends Mock implements MovieRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late MovieRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = MovieRepositoryImpl(remote);
  });

  group('getMovies', () {
    test('returns Right(PaginatedMovies) on success', () async {
      final paginated = buildPaginated();
      when(() => remote.getMovies(category: MovieCategory.popular, page: 1))
          .thenAnswer((_) async => paginated);

      final result = await repository.getMovies(
        category: MovieCategory.popular,
        page: 1,
      );

      expect(result, Right<Failure, PaginatedMovies>(paginated));
      verify(() => remote.getMovies(category: MovieCategory.popular, page: 1))
          .called(1);
    });
  });

  group('searchMovies', () {
    test('forwards query and page to the remote', () async {
      final paginated = buildPaginated();
      when(() => remote.searchMovies(query: 'fight', page: 2))
          .thenAnswer((_) async => paginated);

      final result = await repository.searchMovies(query: 'fight', page: 2);

      expect(result, Right<Failure, PaginatedMovies>(paginated));
      verify(() => remote.searchMovies(query: 'fight', page: 2)).called(1);
    });
  });

  group('getMovieDetail composition', () {
    test('fetches detail, credits, and recommendations in parallel and merges',
        () async {
      final detailBase = buildMovieDetail();
      final cast = List.generate(25, (i) => buildCastMember(id: i, order: i));
      final recs = buildPaginated(
        movies: [buildMovie(id: 100), buildMovie(id: 101)],
      );

      when(() => remote.getMovieDetail(550))
          .thenAnswer((_) async => detailBase);
      when(() => remote.getMovieCredits(550))
          .thenAnswer((_) async => cast);
      when(() => remote.getMovieRecommendations(550))
          .thenAnswer((_) async => recs);

      final result = await repository.getMovieDetail(550);

      final composed = result.getOrElse(() => throw 'expected Right');
      // Composition contract: cast capped at 20, recommendations.movies extracted.
      expect(composed.cast, hasLength(20));
      expect(composed.cast.first.id, 0);
      expect(composed.cast.last.id, 19);
      expect(composed.recommendations.map((m) => m.id), [100, 101]);
      // Base detail fields preserved via copyWith.
      expect(composed.id, detailBase.id);
      expect(composed.title, detailBase.title);
      expect(composed.runtime, detailBase.runtime);

      verify(() => remote.getMovieDetail(550)).called(1);
      verify(() => remote.getMovieCredits(550)).called(1);
      verify(() => remote.getMovieRecommendations(550)).called(1);
    });

    test('passes through cast unchanged when there are 20 or fewer members',
        () async {
      final cast = List.generate(8, (i) => buildCastMember(id: i, order: i));

      when(() => remote.getMovieDetail(1))
          .thenAnswer((_) async => buildMovieDetail());
      when(() => remote.getMovieCredits(1)).thenAnswer((_) async => cast);
      when(() => remote.getMovieRecommendations(1))
          .thenAnswer((_) async => buildPaginated(movies: const []));

      final result = await repository.getMovieDetail(1);

      final composed = result.getOrElse(() => throw 'expected Right');
      expect(composed.cast, hasLength(8));
    });
  });

  group('exception → Failure mapping', () {
    test('UnauthorizedException → ServerFailure(401)', () async {
      when(() => remote.getMovies(category: MovieCategory.popular, page: 1))
          .thenThrow(const UnauthorizedException(message: 'bad token'));

      final result = await repository.getMovies(
        category: MovieCategory.popular,
      );

      expect(
        result,
        Left<Failure, PaginatedMovies>(
          const ServerFailure(message: 'bad token', statusCode: 401),
        ),
      );
    });

    test('ServerException → ServerFailure with the original status code',
        () async {
      when(() => remote.searchMovies(query: 'x', page: 1)).thenThrow(
        const ServerException(message: 'boom', statusCode: 503),
      );

      final result = await repository.searchMovies(query: 'x');

      expect(
        result,
        Left<Failure, PaginatedMovies>(
          const ServerFailure(message: 'boom', statusCode: 503),
        ),
      );
    });

    test('NetworkException → NetworkFailure', () async {
      when(() => remote.getMovieDetail(1)).thenThrow(
        const NetworkException(message: 'offline'),
      );

      final result = await repository.getMovieDetail(1);

      expect(
        result,
        Left<Failure, MovieDetail>(
          const NetworkFailure(message: 'offline'),
        ),
      );
    });

    test('exception thrown anywhere in the parallel detail fetch is mapped',
        () async {
      when(() => remote.getMovieDetail(1))
          .thenAnswer((_) async => buildMovieDetail());
      when(() => remote.getMovieCredits(1)).thenThrow(
        const ServerException(message: 'credits failed', statusCode: 500),
      );
      when(() => remote.getMovieRecommendations(1))
          .thenAnswer((_) async => buildPaginated());

      final result = await repository.getMovieDetail(1);

      expect(
        result,
        Left<Failure, MovieDetail>(
          const ServerFailure(message: 'credits failed', statusCode: 500),
        ),
      );
    });
  });
}
