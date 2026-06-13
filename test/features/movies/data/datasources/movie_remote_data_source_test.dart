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
        when(
          () => apiClient.get(any(), query: any(named: 'query')),
        ).thenAnswer((_) async => emptyPage());

        await dataSource.getMovies(category: entry.key, page: 3);

        verify(
          () => apiClient.get(
            entry.value,
            query: {'page': '3', 'language': 'en-US'},
          ),
        ).called(1);
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

      final result = await dataSource.getMovies(
        category: MovieCategory.popular,
      );

      expect(result.page, 2);
      expect(result.totalPages, 5);
      expect(result.movies.map((m) => m.id), [1, 2]);
    });
  });

  group('searchMovies', () {
    test('hits /search/movie with include_adult=false', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => emptyPage());

      await dataSource.searchMovies(query: 'fight club', page: 4);

      verify(
        () => apiClient.get(
          ApiConstants.searchMovies,
          query: {
            'query': 'fight club',
            'page': '4',
            'language': 'en-US',
            'include_adult': 'false',
          },
        ),
      ).called(1);
    });
  });

  group('getMovieDetail', () {
    test('hits /movie/{id} with language', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{'id': 550, 'title': 'Fight Club'},
      );

      final detail = await dataSource.getMovieDetail(550);

      verify(
        () => apiClient.get(
          ApiConstants.movieDetail(550),
          query: {'language': 'en-US'},
        ),
      ).called(1);
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

      verify(
        () => apiClient.get(
          ApiConstants.movieCredits(550),
          query: {'language': 'en-US'},
        ),
      ).called(1);
      expect(cast.map((c) => c.id), [1, 2, 3]);
    });

    test('returns an empty list when cast key is missing', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      final cast = await dataSource.getMovieCredits(1);

      expect(cast, isEmpty);
    });
  });

  group('getMovieRecommendations', () {
    test('hits /movie/{id}/recommendations with page and language', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => emptyPage());

      await dataSource.getMovieRecommendations(550, page: 2);

      verify(
        () => apiClient.get(
          ApiConstants.movieRecommendations(550),
          query: {'language': 'en-US', 'page': '2'},
        ),
      ).called(1);
    });
  });

  group('getMovieVideos', () {
    test('hits /movie/{id}/videos and parses the results list', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'results': [
            {'id': 'a', 'key': 'k1', 'site': 'YouTube', 'type': 'Trailer'},
            {'id': 'b', 'key': 'k2', 'site': 'YouTube', 'type': 'Teaser'},
          ],
        },
      );

      final videos = await dataSource.getMovieVideos(550);

      verify(
        () => apiClient.get(
          ApiConstants.movieVideos(550),
          query: {'language': 'en-US'},
        ),
      ).called(1);
      expect(videos.map((v) => v.key), ['k1', 'k2']);
    });

    test('returns an empty list when results key is missing', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      final videos = await dataSource.getMovieVideos(1);

      expect(videos, isEmpty);
    });
  });

  group('getMovieReviews', () {
    test('hits /movie/{id}/reviews with page and parses results', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'results': [
            {
              'id': 'r1',
              'author': 'Ann',
              'author_details': {'username': 'ann', 'rating': 9.0},
              'content': 'Great.',
            },
            {
              'id': 'r2',
              'author': 'Bob',
              'author_details': {'username': 'bob'},
              'content': 'Meh.',
            },
          ],
        },
      );

      final reviews = await dataSource.getMovieReviews(550, page: 2);

      verify(
        () => apiClient.get(
          ApiConstants.movieReviews(550),
          query: {'language': 'en-US', 'page': '2'},
        ),
      ).called(1);
      expect(reviews.map((r) => r.id), ['r1', 'r2']);
      expect(reviews.first.rating, 9.0);
    });

    test('returns an empty list when results key is missing', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      final reviews = await dataSource.getMovieReviews(1);

      expect(reviews, isEmpty);
    });
  });

  group('getMovieImages', () {
    test(
      'hits /movie/{id}/images (no language) and parses backdrops',
      () async {
        when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
          (_) async => <String, dynamic>{
            'backdrops': [
              {'file_path': '/a.jpg', 'aspect_ratio': 1.778},
              {'file_path': '/b.jpg', 'aspect_ratio': 1.778},
            ],
            'posters': [
              {'file_path': '/poster.jpg', 'aspect_ratio': 0.667},
            ],
          },
        );

        final images = await dataSource.getMovieImages(550);

        verify(() => apiClient.get(ApiConstants.movieImages(550))).called(1);
        // Only backdrops are surfaced, in order.
        expect(images.map((i) => i.filePath), ['/a.jpg', '/b.jpg']);
      },
    );

    test('returns an empty list when backdrops key is missing', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      final images = await dataSource.getMovieImages(1);

      expect(images, isEmpty);
    });
  });
}
