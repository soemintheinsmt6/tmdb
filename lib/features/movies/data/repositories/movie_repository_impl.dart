import 'package:dartz/dartz.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/error/failures.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/core/utils/typedef.dart';
import 'package:tmdb/features/movies/data/models/cast_member.dart';
import 'package:tmdb/features/movies/data/models/movie.dart';
import 'package:tmdb/features/movies/data/models/movie_detail.dart';
import 'package:tmdb/features/movies/data/models/paginated_movies.dart';
import 'package:tmdb/features/movies/data/repositories/movie_repository.dart';

class MovieRepositoryImpl implements MovieRepository {
  const MovieRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  String _endpointFor(MovieCategory category) {
    return switch (category) {
      MovieCategory.popular => ApiConstants.popularMovies,
      MovieCategory.nowPlaying => ApiConstants.nowPlayingMovies,
      MovieCategory.topRated => ApiConstants.topRatedMovies,
      MovieCategory.upcoming => ApiConstants.upcomingMovies,
    };
  }

  @override
  ResultFuture<PaginatedMovies> getMovies({
    required MovieCategory category,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        _endpointFor(category),
        query: {'page': '$page', 'language': 'en-US'},
      );
      return Right(PaginatedMovies.fromJson(response as Map<String, dynamic>));
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 401));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }

  @override
  ResultFuture<PaginatedMovies> searchMovies({
    required String query,
    int page = 1,
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.searchMovies,
        query: {
          'query': query,
          'page': '$page',
          'language': 'en-US',
          'include_adult': 'false',
        },
      );
      return Right(PaginatedMovies.fromJson(response as Map<String, dynamic>));
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 401));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }

  @override
  ResultFuture<MovieDetail> getMovieDetail(int id) async {
    try {
      final results = await Future.wait([
        _apiClient.get(ApiConstants.movieDetail(id), query: {'language': 'en-US'}),
        _apiClient.get(ApiConstants.movieCredits(id), query: {'language': 'en-US'}),
        _apiClient.get(
          ApiConstants.movieRecommendations(id),
          query: {'language': 'en-US', 'page': '1'},
        ),
      ]);

      final detailJson = results[0] as Map<String, dynamic>;
      final creditsJson = results[1] as Map<String, dynamic>;
      final recommendationsJson = results[2] as Map<String, dynamic>;

      final cast = ((creditsJson['cast'] as List?) ?? const [])
          .map((e) => CastMember.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));

      final recommendations =
          ((recommendationsJson['results'] as List?) ?? const [])
              .map((e) => Movie.fromJson(e as Map<String, dynamic>))
              .toList();

      return Right(
        MovieDetail.fromJson(
          detailJson,
          cast: cast.take(20).toList(),
          recommendations: recommendations,
        ),
      );
    } on UnauthorizedException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: 401));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    }
  }
}
