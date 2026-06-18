import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/features/discover/data/datasources/discover_remote_data_source.dart';
import 'package:tmdb/features/discover/data/repositories/discover_repository_impl.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/shared/domain/genre.dart';

import '../../../../helpers/movie_fixtures.dart';
import '../../../../helpers/tv_fixtures.dart' show buildPaginatedTv;

class _MockRemote extends Mock implements DiscoverRemoteDataSource {}

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
  setUpAll(() => registerFallbackValue(const DiscoverFilter()));

  late _MockRemote remote;
  late DiscoverRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = DiscoverRepositoryImpl(remote);
  });

  group('discoverMovies', () {
    test('returns Right(PaginatedMovies) on success', () async {
      final paginated = buildPaginated();
      when(
        () => remote.discoverMovies(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => paginated);

      final result = await repository.discoverMovies(
        filter: const DiscoverFilter(),
        page: 2,
      );

      expect(result, Right<Failure, PaginatedMovies>(paginated));
      verify(
        () => remote.discoverMovies(filter: const DiscoverFilter(), page: 2),
      ).called(1);
    });

    test(
      'maps ServerException to ServerFailure with the status code',
      () async {
        when(
          () => remote.discoverMovies(
            filter: any(named: 'filter'),
            page: any(named: 'page'),
          ),
        ).thenThrow(const ServerException(message: 'boom', statusCode: 503));

        final result = await repository.discoverMovies(
          filter: const DiscoverFilter(),
        );

        expect(
          result,
          const Left<Failure, PaginatedMovies>(
            ServerFailure(message: 'boom', statusCode: 503),
          ),
        );
      },
    );

    test('maps NetworkException to NetworkFailure', () async {
      when(
        () => remote.discoverMovies(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
        ),
      ).thenThrow(const NetworkException(message: 'offline'));

      final result = await repository.discoverMovies(
        filter: const DiscoverFilter(),
      );

      expect(
        result,
        const Left<Failure, PaginatedMovies>(
          NetworkFailure(message: 'offline'),
        ),
      );
    });

    test('reports mapped failures through the logging seam', () async {
      final logger = _RecordingLogger();
      final observed = DiscoverRepositoryImpl(remote, logger: logger);
      when(
        () => remote.discoverMovies(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
        ),
      ).thenThrow(const ServerException(message: 'boom', statusCode: 500));

      await observed.discoverMovies(filter: const DiscoverFilter());

      expect(logger.warnings, hasLength(1));
      expect(logger.warnings.single, contains('500'));
    });
  });

  group('getMovieGenres', () {
    test('returns Right(genres) on success', () async {
      const genres = [Genre(id: 28, name: 'Action')];
      when(() => remote.getMovieGenres()).thenAnswer((_) async => genres);

      final result = await repository.getMovieGenres();

      expect(result, const Right<Failure, List<Genre>>(genres));
    });

    test('maps UnauthorizedException to ServerFailure(401)', () async {
      when(
        () => remote.getMovieGenres(),
      ).thenThrow(const UnauthorizedException(message: 'bad token'));

      final result = await repository.getMovieGenres();

      expect(
        result,
        const Left<Failure, List<Genre>>(
          ServerFailure(message: 'bad token', statusCode: 401),
        ),
      );
    });
  });

  group('discoverTv', () {
    test('returns Right(PaginatedTvShows) on success', () async {
      final paginated = buildPaginatedTv();
      when(
        () => remote.discoverTv(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
        ),
      ).thenAnswer((_) async => paginated);

      final result = await repository.discoverTv(
        filter: const DiscoverFilter(mediaType: MediaType.tv),
        page: 2,
      );

      expect(result, Right<Failure, PaginatedTvShows>(paginated));
    });

    test('maps NetworkException to NetworkFailure', () async {
      when(
        () => remote.discoverTv(
          filter: any(named: 'filter'),
          page: any(named: 'page'),
        ),
      ).thenThrow(const NetworkException(message: 'offline'));

      final result = await repository.discoverTv(
        filter: const DiscoverFilter(mediaType: MediaType.tv),
      );

      expect(
        result,
        const Left<Failure, PaginatedTvShows>(
          NetworkFailure(message: 'offline'),
        ),
      );
    });
  });

  group('getTvGenres', () {
    test('returns Right(genres) on success', () async {
      const tvGenres = [Genre(id: 10765, name: 'Sci-Fi & Fantasy')];
      when(() => remote.getTvGenres()).thenAnswer((_) async => tvGenres);

      final result = await repository.getTvGenres();

      expect(result, const Right<Failure, List<Genre>>(tvGenres));
    });
  });
}
