import 'package:dartz/dartz.dart';

import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/people/data/datasources/person_remote_data_source.dart';
import 'package:tmdb/features/people/domain/entities/person.dart';
import 'package:tmdb/features/people/domain/entities/person_credit.dart';
import 'package:tmdb/features/people/domain/repositories/person_repository.dart';

class PersonRepositoryImpl implements PersonRepository {
  const PersonRepositoryImpl(this._remote, {AppLogger? logger})
    : _logger = logger;

  final PersonRemoteDataSource _remote;
  final AppLogger? _logger;

  @override
  ResultFuture<Person> getPersonDetail(int id) {
    return _guard(() async {
      // List `Future.wait` (not the record `.wait`) is deliberate: it rethrows
      // the original exception so `_guard` can map it, whereas the record form
      // wraps a partial async failure in a `ParallelWaitError` that escapes the
      // typed-exception clauses below.
      final results = await Future.wait([
        _remote.getPersonDetail(id),
        _remote.getCombinedCredits(id),
      ]);
      final detail = results[0] as Person;
      final credits = results[1] as List<PersonCredit>;

      return detail.copyWith(filmography: credits.take(30).toList());
    });
  }

  /// Runs [body] and converts the layered exceptions into typed failures so
  /// every endpoint shares one error-mapping path.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on UnauthorizedException catch (e, s) {
      return Left(
        _fail(ServerFailure(message: e.message, statusCode: 401), e, s),
      );
    } on ServerException catch (e, s) {
      return Left(
        _fail(
          ServerFailure(message: e.message, statusCode: e.statusCode),
          e,
          s,
        ),
      );
    } on NetworkException catch (e, s) {
      return Left(_fail(NetworkFailure(message: e.message), e, s));
    }
  }

  /// Records the mapped [failure] through the logging seam, then returns it so
  /// no failure leaves the data layer unobserved.
  Failure _fail(Failure failure, Object error, StackTrace stackTrace) {
    _logger?.warning('$failure', error: error, stackTrace: stackTrace);
    return failure;
  }
}
