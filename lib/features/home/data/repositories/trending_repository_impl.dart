import 'package:dartz/dartz.dart';

import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/home/data/datasources/trending_remote_data_source.dart';
import 'package:tmdb/features/home/domain/repositories/trending_repository.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/shared/domain/poster_item.dart';

class TrendingRepositoryImpl implements TrendingRepository {
  const TrendingRepositoryImpl(this._remote, {AppLogger? logger})
    : _logger = logger;

  final TrendingRemoteDataSource _remote;
  final AppLogger? _logger;

  @override
  ResultFuture<List<PosterItem>> getTrending({String window = 'day'}) {
    return _guard(() => _remote.getTrending(window: window));
  }

  @override
  ResultFuture<List<TvShow>> getTrendingTv({String window = 'day'}) {
    return _guard(() => _remote.getTrendingTv(window: window));
  }

  /// Runs [body] and converts the layered exceptions into typed failures so
  /// every endpoint shares one error-mapping path. Mirrors the other feature
  /// repositories.
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

  Failure _fail(Failure failure, Object error, StackTrace stackTrace) {
    _logger?.warning('$failure', error: error, stackTrace: stackTrace);
    return failure;
  }
}
