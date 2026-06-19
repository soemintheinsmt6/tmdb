import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/search/data/datasources/search_remote_data_source.dart';
import 'package:tmdb/features/search/domain/entities/search_filter.dart';
import 'package:tmdb/features/search/domain/entities/search_result.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, String>{});
  });

  late _MockApiClient apiClient;
  late SearchRemoteDataSource dataSource;

  setUp(() {
    apiClient = _MockApiClient();
    dataSource = SearchRemoteDataSource(apiClient);
  });

  void stubEmpty() {
    when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
      (_) async => <String, dynamic>{
        'page': 1,
        'results': const <dynamic>[],
        'total_pages': 1,
        'total_results': 0,
      },
    );
  }

  test('all filter hits /search/multi with include_adult=false', () async {
    stubEmpty();

    await dataSource.search(query: 'matrix', filter: SearchFilter.all, page: 4);

    verify(
      () => apiClient.get(
        ApiConstants.searchMulti,
        query: {
          'query': 'matrix',
          'page': '4',
          'language': 'en-US',
          'include_adult': 'false',
        },
      ),
    ).called(1);
  });

  test('each filter targets its type-specific endpoint', () async {
    stubEmpty();

    await dataSource.search(query: 'q', filter: SearchFilter.movie);
    await dataSource.search(query: 'q', filter: SearchFilter.tv);
    await dataSource.search(query: 'q', filter: SearchFilter.person);

    verify(
      () =>
          apiClient.get(ApiConstants.searchMovies, query: any(named: 'query')),
    ).called(1);
    verify(
      () => apiClient.get(ApiConstants.searchTv, query: any(named: 'query')),
    ).called(1);
    verify(
      () =>
          apiClient.get(ApiConstants.searchPerson, query: any(named: 'query')),
    ).called(1);
  });

  test(
    'all filter parses the mixed response, dropping unsupported rows',
    () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'page': 1,
          'results': [
            {'id': 603, 'media_type': 'movie', 'title': 'The Matrix'},
            {'id': 1396, 'media_type': 'tv', 'name': 'Breaking Bad'},
            {'id': 6384, 'media_type': 'person', 'name': 'Keanu Reeves'},
            {'id': 9, 'media_type': 'collection', 'name': 'Matrix Collection'},
          ],
          'total_pages': 3,
          'total_results': 50,
        },
      );

      final result = await dataSource.search(
        query: 'matrix',
        filter: SearchFilter.all,
      );

      expect(result.page, 1);
      expect(result.totalPages, 3);
      expect(result.results.map((r) => r.mediaType), [
        SearchMediaType.movie,
        SearchMediaType.tv,
        SearchMediaType.person,
      ]);
    },
  );

  test('person filter tags rows that lack a media_type', () async {
    when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
      (_) async => <String, dynamic>{
        'page': 1,
        // `/search/person` rows have no `media_type` discriminator.
        'results': [
          {'id': 6384, 'name': 'Keanu Reeves', 'profile_path': '/k.jpg'},
        ],
        'total_pages': 1,
        'total_results': 1,
      },
    );

    final result = await dataSource.search(
      query: 'keanu',
      filter: SearchFilter.person,
    );

    expect(result.results, hasLength(1));
    expect(result.results.single.mediaType, SearchMediaType.person);
    expect(result.results.single.title, 'Keanu Reeves');
  });
}
