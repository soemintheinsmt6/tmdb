import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';
import 'package:tmdb/shared/domain/review.dart';
import 'package:tmdb/shared/domain/video.dart';

import '../../../../helpers/movie_fixtures.dart';

class _MockRemote extends Mock implements MovieRemoteDataSource {}

/// Captures the messages passed to the logging seam so tests can assert that
/// failures are observed rather than swallowed.
class _RecordingLogger implements AppLogger {
  final List<String> warnings = [];

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      warnings.add(message);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

void main() {
  late _MockRemote remote;
  late MovieRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = MovieRepositoryImpl(remote);
    // Videos and reviews joined the parallel detail fetch; default every
    // composition test to empty lists so tests only stub what they assert on.
    when(
      () => remote.getMovieVideos(any()),
    ).thenAnswer((_) async => const <Video>[]);
    when(
      () => remote.getMovieReviews(any()),
    ).thenAnswer((_) async => const <Review>[]);
  });

  group('getMovies', () {
    test('returns Right(PaginatedMovies) on success', () async {
      final paginated = buildPaginated();
      when(
        () => remote.getMovies(category: MovieCategory.popular, page: 1),
      ).thenAnswer((_) async => paginated);

      final result = await repository.getMovies(
        category: MovieCategory.popular,
        page: 1,
      );

      expect(result, Right<Failure, PaginatedMovies>(paginated));
      verify(
        () => remote.getMovies(category: MovieCategory.popular, page: 1),
      ).called(1);
    });
  });

  group('searchMovies', () {
    test('forwards query and page to the remote', () async {
      final paginated = buildPaginated();
      when(
        () => remote.searchMovies(query: 'fight', page: 2),
      ).thenAnswer((_) async => paginated);

      final result = await repository.searchMovies(query: 'fight', page: 2);

      expect(result, Right<Failure, PaginatedMovies>(paginated));
      verify(() => remote.searchMovies(query: 'fight', page: 2)).called(1);
    });
  });

  group('getMovieDetail composition', () {
    test(
      'fetches detail, credits, and recommendations in parallel and merges',
      () async {
        final detailBase = buildMovieDetail();
        final cast = List.generate(25, (i) => buildCastMember(id: i, order: i));
        final recs = buildPaginated(
          movies: [buildMovie(id: 100), buildMovie(id: 101)],
        );
        final videos = [buildVideo(id: 'a'), buildVideo(id: 'b')];
        final reviews = List.generate(15, (i) => buildReview(id: 'r$i'));

        when(
          () => remote.getMovieDetail(550),
        ).thenAnswer((_) async => detailBase);
        when(() => remote.getMovieCredits(550)).thenAnswer((_) async => cast);
        when(
          () => remote.getMovieRecommendations(550),
        ).thenAnswer((_) async => recs);
        when(() => remote.getMovieVideos(550)).thenAnswer((_) async => videos);
        when(
          () => remote.getMovieReviews(550),
        ).thenAnswer((_) async => reviews);

        final result = await repository.getMovieDetail(550);

        final composed = result.getOrElse(() => throw 'expected Right');
        // Composition contract: cast capped at 20, recommendations.movies extracted.
        expect(composed.cast, hasLength(20));
        expect(composed.cast.first.id, 0);
        expect(composed.cast.last.id, 19);
        expect(composed.recommendations.map((m) => m.id), [100, 101]);
        expect(composed.videos.map((v) => v.id), ['a', 'b']);
        // Reviews capped at 10.
        expect(composed.reviews, hasLength(10));
        expect(composed.reviews.first.id, 'r0');
        // Base detail fields preserved via copyWith.
        expect(composed.id, detailBase.id);
        expect(composed.title, detailBase.title);
        expect(composed.runtime, detailBase.runtime);

        verify(() => remote.getMovieDetail(550)).called(1);
        verify(() => remote.getMovieCredits(550)).called(1);
        verify(() => remote.getMovieRecommendations(550)).called(1);
        verify(() => remote.getMovieVideos(550)).called(1);
        verify(() => remote.getMovieReviews(550)).called(1);
      },
    );

    test(
      'passes through cast unchanged when there are 20 or fewer members',
      () async {
        final cast = List.generate(8, (i) => buildCastMember(id: i, order: i));

        when(
          () => remote.getMovieDetail(1),
        ).thenAnswer((_) async => buildMovieDetail());
        when(() => remote.getMovieCredits(1)).thenAnswer((_) async => cast);
        when(
          () => remote.getMovieRecommendations(1),
        ).thenAnswer((_) async => buildPaginated(movies: const []));

        final result = await repository.getMovieDetail(1);

        final composed = result.getOrElse(() => throw 'expected Right');
        expect(composed.cast, hasLength(8));
      },
    );
  });

  group('exception → Failure mapping', () {
    test('UnauthorizedException → ServerFailure(401)', () async {
      when(
        () => remote.getMovies(category: MovieCategory.popular, page: 1),
      ).thenThrow(const UnauthorizedException(message: 'bad token'));

      final result = await repository.getMovies(
        category: MovieCategory.popular,
      );

      expect(
        result,
        const Left<Failure, PaginatedMovies>(
          ServerFailure(message: 'bad token', statusCode: 401),
        ),
      );
    });

    test(
      'ServerException → ServerFailure with the original status code',
      () async {
        when(
          () => remote.searchMovies(query: 'x', page: 1),
        ).thenThrow(const ServerException(message: 'boom', statusCode: 503));

        final result = await repository.searchMovies(query: 'x');

        expect(
          result,
          const Left<Failure, PaginatedMovies>(
            ServerFailure(message: 'boom', statusCode: 503),
          ),
        );
      },
    );

    test('NetworkException → NetworkFailure', () async {
      when(
        () => remote.getMovieDetail(1),
      ).thenThrow(const NetworkException(message: 'offline'));

      final result = await repository.getMovieDetail(1);

      expect(
        result,
        const Left<Failure, MovieDetail>(NetworkFailure(message: 'offline')),
      );
    });

    test(
      'exception thrown anywhere in the parallel detail fetch is mapped',
      () async {
        when(
          () => remote.getMovieDetail(1),
        ).thenAnswer((_) async => buildMovieDetail());
        when(() => remote.getMovieCredits(1)).thenThrow(
          const ServerException(message: 'credits failed', statusCode: 500),
        );
        when(
          () => remote.getMovieRecommendations(1),
        ).thenAnswer((_) async => buildPaginated());

        final result = await repository.getMovieDetail(1);

        expect(
          result,
          const Left<Failure, MovieDetail>(
            ServerFailure(message: 'credits failed', statusCode: 500),
          ),
        );
      },
    );

    test('a credits failure raised asynchronously is mapped to its original '
        'status (not wrapped in ParallelWaitError)', () async {
      when(
        () => remote.getMovieDetail(1),
      ).thenAnswer((_) async => buildMovieDetail());
      when(() => remote.getMovieCredits(1)).thenAnswer(
        (_) async => throw const ServerException(
          message: 'credits failed',
          statusCode: 500,
        ),
      );
      when(
        () => remote.getMovieRecommendations(1),
      ).thenAnswer((_) async => buildPaginated());

      final result = await repository.getMovieDetail(1);

      expect(
        result,
        const Left<Failure, MovieDetail>(
          ServerFailure(message: 'credits failed', statusCode: 500),
        ),
      );
    });

    test('mapped failures are reported through the logging seam', () async {
      final logger = _RecordingLogger();
      final observed = MovieRepositoryImpl(remote, logger: logger);
      when(
        () => remote.getMovies(category: MovieCategory.popular, page: 1),
      ).thenThrow(const ServerException(message: 'boom', statusCode: 503));

      await observed.getMovies(category: MovieCategory.popular);

      expect(logger.warnings, hasLength(1));
      expect(logger.warnings.single, contains('503'));
    });
  });
}
