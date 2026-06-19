import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/features/search/data/datasources/search_remote_data_source.dart';
import 'package:tmdb/features/search/data/repositories/search_repository_impl.dart';
import 'package:tmdb/features/search/domain/entities/paginated_search_results.dart';
import 'package:tmdb/features/search/domain/entities/search_filter.dart';

import '../../../../helpers/search_fixtures.dart';

class _MockRemote extends Mock implements SearchRemoteDataSource {}

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
  late SearchRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = SearchRepositoryImpl(remote);
  });

  group('search', () {
    test('returns Right and forwards query and page on success', () async {
      final paginated = buildPaginatedSearch();
      when(
        () => remote.search(query: 'matrix', filter: SearchFilter.all, page: 2),
      ).thenAnswer((_) async => paginated);

      final result = await repository.search(
        query: 'matrix',
        filter: SearchFilter.all,
        page: 2,
      );

      expect(result, Right<Failure, PaginatedSearchResults>(paginated));
      verify(
        () => remote.search(query: 'matrix', filter: SearchFilter.all, page: 2),
      ).called(1);
    });
  });

  group('exception → Failure mapping', () {
    test('UnauthorizedException → ServerFailure(401)', () async {
      when(
        () => remote.search(query: 'x', filter: SearchFilter.all, page: 1),
      ).thenThrow(const UnauthorizedException(message: 'bad token'));

      final result = await repository.search(
        query: 'x',
        filter: SearchFilter.all,
      );

      expect(
        result,
        const Left<Failure, PaginatedSearchResults>(
          ServerFailure(message: 'bad token', statusCode: 401),
        ),
      );
    });

    test('ServerException → ServerFailure with the original status', () async {
      when(
        () => remote.search(query: 'x', filter: SearchFilter.all, page: 1),
      ).thenThrow(const ServerException(message: 'boom', statusCode: 503));

      final result = await repository.search(
        query: 'x',
        filter: SearchFilter.all,
      );

      expect(
        result,
        const Left<Failure, PaginatedSearchResults>(
          ServerFailure(message: 'boom', statusCode: 503),
        ),
      );
    });

    test('NetworkException → NetworkFailure', () async {
      when(
        () => remote.search(query: 'x', filter: SearchFilter.all, page: 1),
      ).thenThrow(const NetworkException(message: 'offline'));

      final result = await repository.search(
        query: 'x',
        filter: SearchFilter.all,
      );

      expect(
        result,
        const Left<Failure, PaginatedSearchResults>(
          NetworkFailure(message: 'offline'),
        ),
      );
    });

    test('mapped failures are reported through the logging seam', () async {
      final logger = _RecordingLogger();
      final observed = SearchRepositoryImpl(remote, logger: logger);
      when(
        () => remote.search(query: 'x', filter: SearchFilter.all, page: 1),
      ).thenThrow(const ServerException(message: 'boom', statusCode: 503));

      await observed.search(query: 'x', filter: SearchFilter.all);

      expect(logger.warnings, hasLength(1));
      expect(logger.warnings.single, contains('503'));
    });
  });
}
