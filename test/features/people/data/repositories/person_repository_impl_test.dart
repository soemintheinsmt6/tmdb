import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/features/people/data/datasources/person_remote_data_source.dart';
import 'package:tmdb/features/people/data/repositories/person_repository_impl.dart';
import 'package:tmdb/features/people/domain/entities/person.dart';
import 'package:tmdb/features/people/domain/entities/person_credit.dart';

import '../../../../helpers/people_fixtures.dart';

class _MockRemote extends Mock implements PersonRemoteDataSource {}

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
  late PersonRepositoryImpl repository;

  setUp(() {
    remote = _MockRemote();
    repository = PersonRepositoryImpl(remote);
  });

  group('getPersonDetail composition', () {
    test('fetches detail + credits in parallel and caps the filmography at '
        '30', () async {
      final credits = List.generate(
        35,
        (i) => buildPersonCredit(id: i, popularity: (35 - i).toDouble()),
      );
      when(
        () => remote.getPersonDetail(287),
      ).thenAnswer((_) async => buildPerson());
      when(
        () => remote.getCombinedCredits(287),
      ).thenAnswer((_) async => credits);

      final result = await repository.getPersonDetail(287);

      final person = result.getOrElse(() => throw 'expected Right');
      expect(person.filmography, hasLength(30));
      // The first 30 (already ordered by the data source) are preserved.
      expect(person.filmography.first.id, 0);
      expect(person.filmography.last.id, 29);
      expect(person.id, 287);

      verify(() => remote.getPersonDetail(287)).called(1);
      verify(() => remote.getCombinedCredits(287)).called(1);
    });

    test('passes the filmography through when there are 30 or fewer', () async {
      when(
        () => remote.getPersonDetail(1),
      ).thenAnswer((_) async => buildPerson());
      when(() => remote.getCombinedCredits(1)).thenAnswer(
        (_) async => [buildPersonCredit(id: 1), buildPersonCredit(id: 2)],
      );

      final result = await repository.getPersonDetail(1);

      final person = result.getOrElse(() => throw 'expected Right');
      expect(person.filmography, hasLength(2));
    });
  });

  group('exception → Failure mapping', () {
    test('UnauthorizedException → ServerFailure(401)', () async {
      when(() => remote.getPersonDetail(1)).thenAnswer(
        (_) async => throw const UnauthorizedException(message: 'bad token'),
      );
      when(
        () => remote.getCombinedCredits(1),
      ).thenAnswer((_) async => const <PersonCredit>[]);

      final result = await repository.getPersonDetail(1);

      expect(
        result,
        const Left<Failure, Person>(
          ServerFailure(message: 'bad token', statusCode: 401),
        ),
      );
    });

    test(
      'a ServerException raised asynchronously in the parallel fetch is '
      'mapped to its original status (not wrapped in ParallelWaitError)',
      () async {
        when(
          () => remote.getPersonDetail(1),
        ).thenAnswer((_) async => buildPerson());
        when(() => remote.getCombinedCredits(1)).thenAnswer(
          (_) async => throw const ServerException(
            message: 'credits failed',
            statusCode: 503,
          ),
        );

        final result = await repository.getPersonDetail(1);

        expect(
          result,
          const Left<Failure, Person>(
            ServerFailure(message: 'credits failed', statusCode: 503),
          ),
        );
      },
    );

    test('NetworkException → NetworkFailure', () async {
      when(() => remote.getPersonDetail(1)).thenAnswer(
        (_) async => throw const NetworkException(message: 'offline'),
      );
      when(
        () => remote.getCombinedCredits(1),
      ).thenAnswer((_) async => const <PersonCredit>[]);

      final result = await repository.getPersonDetail(1);

      expect(
        result,
        const Left<Failure, Person>(NetworkFailure(message: 'offline')),
      );
    });

    test('mapped failures are reported through the logging seam', () async {
      final logger = _RecordingLogger();
      final observed = PersonRepositoryImpl(remote, logger: logger);
      when(() => remote.getPersonDetail(1)).thenAnswer(
        (_) async =>
            throw const ServerException(message: 'boom', statusCode: 503),
      );
      when(
        () => remote.getCombinedCredits(1),
      ).thenAnswer((_) async => const <PersonCredit>[]);

      await observed.getPersonDetail(1);

      expect(logger.warnings, hasLength(1));
      expect(logger.warnings.single, contains('503'));
    });
  });
}
