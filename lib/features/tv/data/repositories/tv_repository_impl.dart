import 'package:dartz/dartz.dart';

import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/tv/data/datasources/tv_remote_data_source.dart';
import 'package:tmdb/features/tv/domain/entities/paginated_tv_shows.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

class TvRepositoryImpl implements TvRepository {
  const TvRepositoryImpl(this._remote, {AppLogger? logger}) : _logger = logger;

  final TvRemoteDataSource _remote;
  final AppLogger? _logger;

  @override
  ResultFuture<PaginatedTvShows> getTvShows({
    required TvCategory category,
    int page = 1,
  }) {
    return _guard(() => _remote.getTvShows(category: category, page: page));
  }

  @override
  ResultFuture<PaginatedTvShows> searchTvShows({
    required String query,
    int page = 1,
  }) {
    return _guard(() => _remote.searchTvShows(query: query, page: page));
  }

  @override
  ResultFuture<TvShowDetail> getTvShowDetail(int id) {
    return _guard(() async {
      final (detail, cast, recommendations) = await (
        _remote.getTvShowDetail(id),
        _remote.getTvCredits(id),
        _remote.getTvRecommendations(id),
      ).wait;

      return detail.copyWith(
        cast: cast.take(20).toList(),
        recommendations: recommendations.shows,
      );
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
