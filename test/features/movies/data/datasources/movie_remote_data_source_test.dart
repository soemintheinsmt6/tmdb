import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:tmdb/features/movies/domain/repositories/movie_repository.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, String>{});
  });

  late _MockApiClient apiClient;
  late MovieRemoteDataSource dataSource;

  setUp(() {
    apiClient = _MockApiClient();
    dataSource = MovieRemoteDataSource(apiClient);
  });

  Map<String, dynamic> emptyPage() => <String, dynamic>{
        'page': 1,
        'results': const <dynamic>[],
        'total_pages': 1,
        'total_results': 0,
      };

  group('getMovies endpoint mapping', () {
    final cases = <MovieCategory, String>{
      MovieCategory.popular: ApiConstants.popularMovies,
      MovieCategory.nowPlaying: ApiConstants.nowPlayingMovies,
      MovieCategory.topRated: ApiConstants.topRatedMovies,
      MovieCategory.upcoming: ApiConstants.upcomingMovies,
    };

    for (final entry in cases.entries) {
      test('${entry.key.name} → ${entry.value}', () async {
        when(() => apiClient.get(any(), query: any(named: 'query')))
            .thenAnswer((_) async => emptyPage());

        await dataSource.getMovies(category: entry.key, page: 3);

        verify(() => apiClient.get(
              entry.value,
              query: {'page': '3', 'language': 'en-US'},
            )).called(1);
      });
    }

    test('parses the response into PaginatedMovies', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'page': 2,
          'results': [
            {'id': 1, 'title': 'A'},
            {'id': 2, 'title': 'B'},
          ],
          'total_pages': 5,
          'total_results': 100,
        },
      );

      final result = await dataSource.getMovies(category: MovieCategory.popular);

      expect(result.page, 2);
      expect(result.totalPages, 5);
      expect(result.movies.map((m) => m.id), [1, 2]);
    });
  });

  group('searchMovies', () {
    test('hits /search/movie with include_adult=false', () async {
      when(() => apiClient.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => emptyPage());

      await dataSource.searchMovies(query: 'fight club', page: 4);

      verify(() => apiClient.get(
            ApiConstants.searchMovies,
            query: {
              'query': 'fight club',
              'page': '4',
              'language': 'en-US',
              'include_adult': 'false',
            },
          )).called(1);
    });
  });

  group('getMovieDetail', () {
    test('hits /movie/{id} with language', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'id': 550,
          'title': 'Fight Club',
        },
      );

      final detail = await dataSource.getMovieDetail(550);

      verify(() => apiClient.get(
            ApiConstants.movieDetail(550),
            query: {'language': 'en-US'},
          )).called(1);
      expect(detail.id, 550);
      expect(detail.cast, isEmpty);
      expect(detail.recommendations, isEmpty);
    });
  });

  group('getMovieCredits', () {
    test('hits /movie/{id}/credits and sorts cast by order', () async {
      // Deliberately out of order in the JSON.
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'cast': [
            {'id': 3, 'name': 'C', 'order': 5},
            {'id': 1, 'name': 'A', 'order': 0},
            {'id': 2, 'name': 'B', 'order': 1},
          ],
        },
      );

      final cast = await dataSource.getMovieCredits(550);

      verify(() => apiClient.get(
            ApiConstants.movieCredits(550),
            query: {'language': 'en-US'},
          )).called(1);
      expect(cast.map((c) => c.id), [1, 2, 3]);
    });

    test('returns an empty list when cast key is missing', () async {
      when(() => apiClient.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => <String, dynamic>{});

      final cast = await dataSource.getMovieCredits(1);

      expect(cast, isEmpty);
    });
  });

  group('getMovieRecommendations', () {
    test('hits /movie/{id}/recommendations with page and language', () async {
      when(() => apiClient.get(any(), query: any(named: 'query')))
          .thenAnswer((_) async => emptyPage());

      await dataSource.getMovieRecommendations(550, page: 2);

      verify(() => apiClient.get(
            ApiConstants.movieRecommendations(550),
            query: {'language': 'en-US', 'page': '2'},
          )).called(1);
    });
  });
}
