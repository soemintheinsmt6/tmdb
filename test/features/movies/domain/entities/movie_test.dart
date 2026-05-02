import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/movies/domain/entities/paginated_movies.dart';

void main() {
  group('Movie.fromJson', () {
    test('parses a complete TMDB movie payload', () {
      final json = <String, dynamic>{
        'id': 550,
        'title': 'Fight Club',
        'overview': 'An insomniac office worker...',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'release_date': '1999-10-15',
        'vote_average': 8.4,
        'vote_count': 27000,
        'genre_ids': [18, 53],
      };

      final movie = Movie.fromJson(json);

      expect(movie.id, 550);
      expect(movie.title, 'Fight Club');
      expect(movie.posterPath, '/poster.jpg');
      expect(movie.voteAverage, 8.4);
      expect(movie.voteCount, 27000);
      expect(movie.genreIds, [18, 53]);
    });

    test('falls back to TV-shaped keys (name / first_air_date)', () {
      final json = <String, dynamic>{
        'id': 1,
        'name': 'Breaking Bad',
        'first_air_date': '2008-01-20',
      };

      final movie = Movie.fromJson(json);

      expect(movie.title, 'Breaking Bad');
      expect(movie.releaseDate, '2008-01-20');
    });

    test('uses safe defaults when optional fields are missing', () {
      final movie = Movie.fromJson(<String, dynamic>{'id': 1});

      expect(movie.title, '');
      expect(movie.overview, '');
      expect(movie.posterPath, isNull);
      expect(movie.backdropPath, isNull);
      expect(movie.releaseDate, '');
      expect(movie.voteAverage, 0.0);
      expect(movie.voteCount, 0);
      expect(movie.genreIds, isEmpty);
    });

    test('coerces integer vote_average to double', () {
      // TMDB occasionally returns whole numbers without decimals.
      final movie = Movie.fromJson(<String, dynamic>{'id': 1, 'vote_average': 7});

      expect(movie.voteAverage, 7.0);
      expect(movie.voteAverage, isA<double>());
    });
  });

  group('Movie computed properties', () {
    test('formattedRating returns "NR" when voteCount is zero', () {
      final movie = Movie.fromJson(<String, dynamic>{
        'id': 1,
        'vote_average': 9.9,
        'vote_count': 0,
      });

      expect(movie.formattedRating, 'NR');
    });

    test('formattedRating uses the rating extension when there are votes', () {
      final movie = Movie.fromJson(<String, dynamic>{
        'id': 1,
        'vote_average': 8.456,
        'vote_count': 100,
      });

      // The double_rating extension is one decimal.
      expect(movie.formattedRating, '8.5');
    });

    test('releaseYear extracts the year from the date string', () {
      final movie = Movie.fromJson(<String, dynamic>{
        'id': 1,
        'release_date': '1999-10-15',
      });

      expect(movie.releaseYear, '1999');
    });

    test('releaseYear is null when releaseDate is empty', () {
      final movie = Movie.fromJson(<String, dynamic>{'id': 1});

      expect(movie.releaseYear, isNull);
    });

    test('posterUrl is empty when posterPath is null', () {
      final movie = Movie.fromJson(<String, dynamic>{'id': 1});

      expect(movie.posterUrl(), '');
    });
  });

  group('PaginatedMovies.fromJson', () {
    test('parses a list of movies and pagination metadata', () {
      final json = <String, dynamic>{
        'page': 2,
        'results': [
          {'id': 1, 'title': 'A'},
          {'id': 2, 'title': 'B'},
        ],
        'total_pages': 10,
        'total_results': 200,
      };

      final paginated = PaginatedMovies.fromJson(json);

      expect(paginated.page, 2);
      expect(paginated.totalPages, 10);
      expect(paginated.totalResults, 200);
      expect(paginated.movies.map((m) => m.id), [1, 2]);
    });

    test('hasMore is true when page < totalPages', () {
      final paginated = PaginatedMovies.fromJson(<String, dynamic>{
        'page': 2,
        'results': [],
        'total_pages': 5,
      });

      expect(paginated.hasMore, isTrue);
    });

    test('hasMore is false on the last page', () {
      final paginated = PaginatedMovies.fromJson(<String, dynamic>{
        'page': 5,
        'results': [],
        'total_pages': 5,
      });

      expect(paginated.hasMore, isFalse);
    });

    test('defaults total_results to the result count when missing', () {
      final paginated = PaginatedMovies.fromJson(<String, dynamic>{
        'page': 1,
        'results': [
          {'id': 1},
          {'id': 2},
          {'id': 3},
        ],
        'total_pages': 1,
      });

      expect(paginated.totalResults, 3);
    });
  });
}
