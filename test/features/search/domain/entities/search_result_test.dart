import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/search/domain/entities/paginated_search_results.dart';
import 'package:tmdb/features/search/domain/entities/search_result.dart';

void main() {
  group('SearchResult.tryFromJson', () {
    test('parses a movie row (title / poster_path / release_date)', () {
      final result = SearchResult.tryFromJson({
        'id': 603,
        'media_type': 'movie',
        'title': 'The Matrix',
        'poster_path': '/matrix.jpg',
        'release_date': '1999-03-31',
        'vote_average': 8.2,
        'vote_count': 24000,
      });

      expect(result, isNotNull);
      expect(result!.mediaType, SearchMediaType.movie);
      expect(result.title, 'The Matrix');
      expect(result.imagePath, '/matrix.jpg');
      expect(result.year, '1999');
      expect(result.formattedRating, '8.2');
      expect(result.mediaTypeLabel, 'Movie');
    });

    test('parses a tv row using name / first_air_date', () {
      final result = SearchResult.tryFromJson({
        'id': 1396,
        'media_type': 'tv',
        'name': 'Breaking Bad',
        'poster_path': '/bb.jpg',
        'first_air_date': '2008-01-20',
        'vote_average': 8.9,
        'vote_count': 12000,
      });

      expect(result!.mediaType, SearchMediaType.tv);
      expect(result.title, 'Breaking Bad');
      expect(result.year, '2008');
      expect(result.mediaTypeLabel, 'TV');
    });

    test('parses a person row using name / profile_path', () {
      final result = SearchResult.tryFromJson({
        'id': 6384,
        'media_type': 'person',
        'name': 'Keanu Reeves',
        'profile_path': '/keanu.jpg',
        'known_for_department': 'Acting',
      });

      expect(result!.mediaType, SearchMediaType.person);
      expect(result.title, 'Keanu Reeves');
      expect(result.imagePath, '/keanu.jpg');
      expect(result.knownForDepartment, 'Acting');
      // People have neither a rating nor a year.
      expect(result.year, isNull);
      expect(result.formattedRating, isNull);
      expect(result.mediaTypeLabel, 'Person');
    });

    test('returns null for an unsupported media type', () {
      final result = SearchResult.tryFromJson({
        'id': 10,
        'media_type': 'collection',
        'name': 'The Matrix Collection',
      });

      expect(result, isNull);
    });

    test('returns null when the id is missing or not an int', () {
      expect(
        SearchResult.tryFromJson({'media_type': 'movie', 'title': 'X'}),
        isNull,
      );
      expect(
        SearchResult.tryFromJson({
          'id': '603',
          'media_type': 'movie',
          'title': 'X',
        }),
        isNull,
      );
    });

    test('formattedRating is null for an unrated title (vote_count 0)', () {
      final result = SearchResult.tryFromJson({
        'id': 1,
        'media_type': 'movie',
        'title': 'Unrated',
        'vote_average': 0,
        'vote_count': 0,
      });

      expect(result!.formattedRating, isNull);
    });
  });

  group('imageUrl', () {
    test('uses the poster path for titles', () {
      final movie = SearchResult.tryFromJson({
        'id': 1,
        'media_type': 'movie',
        'poster_path': '/m.jpg',
      })!;

      expect(movie.imageUrl(), 'https://image.tmdb.org/t/p/w185/m.jpg');
    });

    test('uses the profile path for people', () {
      final person = SearchResult.tryFromJson({
        'id': 1,
        'media_type': 'person',
        'profile_path': '/p.jpg',
      })!;

      expect(person.imageUrl(), 'https://image.tmdb.org/t/p/w185/p.jpg');
    });

    test('returns an empty string when there is no image', () {
      final movie = SearchResult.tryFromJson({'id': 1, 'media_type': 'movie'})!;

      expect(movie.imageUrl(), '');
    });
  });

  group('PaginatedSearchResults.fromJson', () {
    test('maps page metadata and keeps only renderable rows', () {
      final paginated = PaginatedSearchResults.fromJson(const {
        'page': 2,
        'results': [
          {'id': 1, 'media_type': 'movie', 'title': 'A'},
          {'id': 2, 'media_type': 'tv', 'name': 'B'},
          {'id': 3, 'media_type': 'person', 'name': 'C'},
          // Dropped: unsupported media type.
          {'id': 4, 'media_type': 'collection', 'name': 'D'},
          // Dropped: missing id.
          {'media_type': 'movie', 'title': 'E'},
        ],
        'total_pages': 5,
        'total_results': 100,
      });

      expect(paginated.page, 2);
      expect(paginated.totalPages, 5);
      expect(paginated.totalResults, 100);
      expect(paginated.results.map((r) => r.id), [1, 2, 3]);
      expect(paginated.hasMore, isTrue);
    });

    test('defaults gracefully when results are missing', () {
      final paginated = PaginatedSearchResults.fromJson(const {'page': 1});

      expect(paginated.results, isEmpty);
      expect(paginated.totalResults, 0);
      expect(paginated.hasMore, isFalse);
    });
  });
}
