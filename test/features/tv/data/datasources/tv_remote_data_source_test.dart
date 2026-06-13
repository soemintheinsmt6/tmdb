import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/tv/data/datasources/tv_remote_data_source.dart';
import 'package:tmdb/features/tv/domain/repositories/tv_repository.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, String>{});
  });

  late _MockApiClient apiClient;
  late TvRemoteDataSource dataSource;

  setUp(() {
    apiClient = _MockApiClient();
    dataSource = TvRemoteDataSource(apiClient);
  });

  Map<String, dynamic> emptyPage() => <String, dynamic>{
    'page': 1,
    'results': const <dynamic>[],
    'total_pages': 1,
    'total_results': 0,
  };

  group('getTvShows endpoint mapping', () {
    final cases = <TvCategory, String>{
      TvCategory.popular: ApiConstants.popularTv,
      TvCategory.topRated: ApiConstants.topRatedTv,
      TvCategory.onTheAir: ApiConstants.onTheAirTv,
      TvCategory.airingToday: ApiConstants.airingTodayTv,
    };

    for (final entry in cases.entries) {
      test('${entry.key.name} → ${entry.value}', () async {
        when(
          () => apiClient.get(any(), query: any(named: 'query')),
        ).thenAnswer((_) async => emptyPage());

        await dataSource.getTvShows(category: entry.key, page: 3);

        verify(
          () => apiClient.get(
            entry.value,
            query: {'page': '3', 'language': 'en-US'},
          ),
        ).called(1);
      });
    }

    test('parses the response into PaginatedTvShows', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'page': 2,
          'results': [
            {'id': 1, 'name': 'A'},
            {'id': 2, 'name': 'B'},
          ],
          'total_pages': 5,
          'total_results': 100,
        },
      );

      final result = await dataSource.getTvShows(category: TvCategory.popular);

      expect(result.page, 2);
      expect(result.totalPages, 5);
      expect(result.shows.map((s) => s.id), [1, 2]);
    });
  });

  group('searchTvShows', () {
    test('hits /search/tv with include_adult=false', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => emptyPage());

      await dataSource.searchTvShows(query: 'thrones', page: 4);

      verify(
        () => apiClient.get(
          ApiConstants.searchTv,
          query: {
            'query': 'thrones',
            'page': '4',
            'language': 'en-US',
            'include_adult': 'false',
          },
        ),
      ).called(1);
    });
  });

  group('getTvShowDetail', () {
    test('hits /tv/{id} with language', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{'id': 1399, 'name': 'Game of Thrones'},
      );

      final detail = await dataSource.getTvShowDetail(1399);

      verify(
        () => apiClient.get(
          ApiConstants.tvDetail(1399),
          query: {'language': 'en-US'},
        ),
      ).called(1);
      expect(detail.id, 1399);
      expect(detail.cast, isEmpty);
      expect(detail.recommendations, isEmpty);
    });
  });

  group('getTvCredits', () {
    test('hits /tv/{id}/credits and sorts cast by order', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'cast': [
            {'id': 3, 'name': 'C', 'order': 5},
            {'id': 1, 'name': 'A', 'order': 0},
            {'id': 2, 'name': 'B', 'order': 1},
          ],
        },
      );

      final cast = await dataSource.getTvCredits(1399);

      verify(
        () => apiClient.get(
          ApiConstants.tvCredits(1399),
          query: {'language': 'en-US'},
        ),
      ).called(1);
      expect(cast.map((c) => c.id), [1, 2, 3]);
    });

    test('returns an empty list when cast key is missing', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      final cast = await dataSource.getTvCredits(1);

      expect(cast, isEmpty);
    });
  });

  group('getTvRecommendations', () {
    test('hits /tv/{id}/recommendations with page and language', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => emptyPage());

      await dataSource.getTvRecommendations(1399, page: 2);

      verify(
        () => apiClient.get(
          ApiConstants.tvRecommendations(1399),
          query: {'language': 'en-US', 'page': '2'},
        ),
      ).called(1);
    });
  });

  group('getTvVideos', () {
    test('hits /tv/{id}/videos and parses the results list', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'results': [
            {'id': 'a', 'key': 'k1', 'site': 'YouTube', 'type': 'Trailer'},
            {'id': 'b', 'key': 'k2', 'site': 'YouTube', 'type': 'Teaser'},
          ],
        },
      );

      final videos = await dataSource.getTvVideos(1399);

      verify(
        () => apiClient.get(
          ApiConstants.tvVideos(1399),
          query: {'language': 'en-US'},
        ),
      ).called(1);
      expect(videos.map((v) => v.key), ['k1', 'k2']);
    });

    test('returns an empty list when results key is missing', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      final videos = await dataSource.getTvVideos(1);

      expect(videos, isEmpty);
    });
  });
}
