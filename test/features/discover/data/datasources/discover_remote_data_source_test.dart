import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/discover/data/datasources/discover_remote_data_source.dart';
import 'package:tmdb/features/discover/domain/entities/discover_filter.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, String>{});
  });

  late _MockApiClient apiClient;
  late DiscoverRemoteDataSource dataSource;

  setUp(() {
    apiClient = _MockApiClient();
    dataSource = DiscoverRemoteDataSource(apiClient);
  });

  group('discoverMovies', () {
    test('hits /discover/movie with the filter query, language, and page', () {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'page': 1,
          'results': const <dynamic>[],
          'total_pages': 1,
          'total_results': 0,
        },
      );

      const filter = DiscoverFilter(genreIds: {28}, minRating: 7);

      return dataSource.discoverMovies(filter: filter, page: 2).then((_) {
        verify(
          () => apiClient.get(
            ApiConstants.discoverMovie,
            query: {
              'sort_by': 'popularity.desc',
              'include_adult': 'false',
              'with_genres': '28',
              'vote_average.gte': '7.0',
              'language': 'en-US',
              'page': '2',
            },
          ),
        ).called(1);
      });
    });

    test('parses the response into PaginatedMovies', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'page': 1,
          'results': [
            {'id': 1, 'title': 'A'},
            {'id': 2, 'title': 'B'},
          ],
          'total_pages': 4,
          'total_results': 80,
        },
      );

      final result = await dataSource.discoverMovies(
        filter: const DiscoverFilter(),
      );

      expect(result.movies.map((m) => m.id), [1, 2]);
      expect(result.totalPages, 4);
    });
  });

  group('getMovieGenres', () {
    test('hits /genre/movie/list and parses the genres list', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'genres': [
            {'id': 28, 'name': 'Action'},
            {'id': 12, 'name': 'Adventure'},
          ],
        },
      );

      final genres = await dataSource.getMovieGenres();

      verify(
        () => apiClient.get(
          ApiConstants.movieGenres,
          query: {'language': 'en-US'},
        ),
      ).called(1);
      expect(genres.map((g) => g.name), ['Action', 'Adventure']);
    });

    test('returns an empty list when genres key is missing', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      final genres = await dataSource.getMovieGenres();

      expect(genres, isEmpty);
    });
  });
}
