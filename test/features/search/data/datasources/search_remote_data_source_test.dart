import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/search/data/datasources/search_remote_data_source.dart';
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

  test('hits /search/multi with include_adult=false', () async {
    when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
      (_) async => <String, dynamic>{
        'page': 1,
        'results': const <dynamic>[],
        'total_pages': 1,
        'total_results': 0,
      },
    );

    await dataSource.searchMulti(query: 'matrix', page: 4);

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

  test('parses the mixed response, dropping unsupported rows', () async {
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

    final result = await dataSource.searchMulti(query: 'matrix');

    expect(result.page, 1);
    expect(result.totalPages, 3);
    expect(result.results.map((r) => r.mediaType), [
      SearchMediaType.movie,
      SearchMediaType.tv,
      SearchMediaType.person,
    ]);
  });
}
