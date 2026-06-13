import 'package:dartz/dartz.dart';

import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/search/data/datasources/search_remote_data_source.dart';
import 'package:tmdb/features/search/domain/entities/paginated_search_results.dart';
import 'package:tmdb/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._remote, {AppLogger? logger})
    : _logger = logger;

  final SearchRemoteDataSource _remote;
  final AppLogger? _logger;

  @override
  ResultFuture<PaginatedSearchResults> searchMulti({
    required String query,
    int page = 1,
  }) {
    return _guard(() => _remote.searchMulti(query: query, page: page));
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
