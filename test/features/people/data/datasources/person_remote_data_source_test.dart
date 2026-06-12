import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/people/data/datasources/person_remote_data_source.dart';
import 'package:tmdb/features/people/domain/entities/person_credit.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, String>{});
  });

  late _MockApiClient apiClient;
  late PersonRemoteDataSource dataSource;

  setUp(() {
    apiClient = _MockApiClient();
    dataSource = PersonRemoteDataSource(apiClient);
  });

  group('getPersonDetail', () {
    test('hits /person/{id} with language and parses the person', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{'id': 287, 'name': 'Brad Pitt'},
      );

      final person = await dataSource.getPersonDetail(287);

      verify(
        () => apiClient.get(
          ApiConstants.personDetail(287),
          query: {'language': 'en-US'},
        ),
      ).called(1);
      expect(person.id, 287);
      expect(person.name, 'Brad Pitt');
      expect(person.filmography, isEmpty);
    });
  });

  group('getCombinedCredits', () {
    test('hits /person/{id}/combined_credits with language', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{'cast': const []});

      await dataSource.getCombinedCredits(287);

      verify(
        () => apiClient.get(
          ApiConstants.personCombinedCredits(287),
          query: {'language': 'en-US'},
        ),
      ).called(1);
    });

    test('drops non-movie/tv entries, dedupes by (mediaType, id), sorts by '
        'popularity desc', () async {
      when(() => apiClient.get(any(), query: any(named: 'query'))).thenAnswer(
        (_) async => <String, dynamic>{
          'cast': [
            {'id': 1, 'media_type': 'movie', 'popularity': 5.0},
            {'id': 2, 'media_type': 'tv', 'popularity': 50.0},
            // 'person' entries are not routable → dropped.
            {'id': 3, 'media_type': 'person', 'popularity': 99.0},
            // Same (movie, 1) again → deduped away.
            {'id': 1, 'media_type': 'movie', 'popularity': 5.0},
            // Same id but a different media type → kept.
            {'id': 1, 'media_type': 'tv', 'popularity': 30.0},
          ],
        },
      );

      final credits = await dataSource.getCombinedCredits(287);

      expect(credits, hasLength(3));
      expect(credits.map((c) => c.id), [2, 1, 1]);
      expect(credits.map((c) => c.mediaType), [
        CreditMediaType.tv,
        CreditMediaType.tv,
        CreditMediaType.movie,
      ]);
      // Strictly descending popularity.
      expect(credits[0].popularity, 50.0);
      expect(credits[1].popularity, 30.0);
      expect(credits[2].popularity, 5.0);
    });

    test('returns an empty list when the cast key is missing', () async {
      when(
        () => apiClient.get(any(), query: any(named: 'query')),
      ).thenAnswer((_) async => <String, dynamic>{});

      expect(await dataSource.getCombinedCredits(1), isEmpty);
    });
  });
}
