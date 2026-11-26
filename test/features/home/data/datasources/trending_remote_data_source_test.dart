import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/home/data/datasources/trending_remote_data_source.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  late _MockApiClient apiClient;
  late TrendingRemoteDataSource dataSource;

  setUp(() {
    apiClient = _MockApiClient();
    dataSource = TrendingRemoteDataSource(apiClient);
  });

  test('getTrendingPage requests the given page of /trending/all', () async {
    when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
      (_) async => <String, dynamic>{
        'page': 2,
        'total_pages': 500,
        'results': const <dynamic>[],
      },
    );

    await dataSource.getTrendingPage(page: 2);

    verify(
      () => apiClient.get(
        ApiConstants.trendingAll(),
        query: {'language': 'en-US', 'page': '2'},
      ),
    ).called(1);
  });

  test(
    'getTrendingPage maps movies and TV, skips people, keeps paging',
    () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'page': 2,
          'total_pages': 500,
          'results': <dynamic>[
            {'media_type': 'movie', 'id': 1, 'title': 'Dune'},
            {'media_type': 'person', 'id': 2, 'name': 'Zendaya'},
            {'media_type': 'tv', 'id': 3, 'name': 'Severance'},
          ],
        },
      );

      final result = await dataSource.getTrendingPage(page: 2);

      expect(result.page, 2);
      expect(result.totalPages, 500);
      expect(result.items.map((e) => e.id), [1, 3]);
      expect(result.items[0], isA<Movie>());
      expect(result.items[1], isA<TvShow>());
    },
  );
}
