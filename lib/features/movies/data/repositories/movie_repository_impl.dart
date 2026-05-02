import 'package:dartz/dartz.dart';

import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:tmdb/features/movies/domain/entities/cast_member.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._remote);

  final MovieRemoteDataSource _remote;

  @override
  ResultFuture<PaginatedMovies> getMovies({
    required MovieCategory category,
    int page = 1,
  }) {
    return _guard(() => _remote.getMovies(category: category, page: page));
  }

  @override
  ResultFuture<PaginatedMovies> searchMovies({
    required String query,
    int page = 1,
  }) {
    return _guard(() => _remote.searchMovies(query: query, page: page));
  }

  @override
  ResultFuture<MovieDetail> getMovieDetail(int id) {
    return _guard(() async {
      final results = await Future.wait([
        _remote.getMovieDetail(id),
        _remote.getMovieCredits(id),
        _remote.getMovieRecommendations(id),
      ]);

      final detail = results[0] as MovieDetail;
      final cast = results[1] as List<CastMember>;
      final recommendations = results[2] as PaginatedMovies;

      return detail.copyWith(
        cast: cast.take(20).toList(),
        recommendations: recommendations.movies,
      );
    });
  }

  /// Runs [body] and converts the layered exceptions into typed failures so
  /// every endpoint shares one error-mapping path.
  Future<Either<Failure, T>> _guard<T>(Future<T> Function() body) async {
    try {
      return Right(await body());
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 401));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }
}
