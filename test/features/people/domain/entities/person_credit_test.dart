import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/people/domain/entities/person_credit.dart';

void main() {
  group('PersonCredit.fromJson', () {
    test('parses a movie credit (title / release_date / character)', () {
      final credit = PersonCredit.fromJson(const {
        'id': 550,
        'media_type': 'movie',
        'title': 'Fight Club',
        'release_date': '1999-10-15',
        'character': 'Tyler Durden',
        'poster_path': '/p.jpg',
        'vote_average': 8.4,
        'vote_count': 27000,
        'popularity': 61.4,
      });

      expect(credit.id, 550);
      expect(credit.mediaType, CreditMediaType.movie);
      expect(credit.title, 'Fight Club');
      expect(credit.releaseDate, '1999-10-15');
      expect(credit.role, 'Tyler Durden');
      expect(credit.popularity, 61.4);
    });

    test('parses a tv credit (name / first_air_date fallbacks)', () {
      final credit = PersonCredit.fromJson(const {
        'id': 1399,
        'media_type': 'tv',
        'name': 'Game of Thrones',
        'first_air_date': '2011-04-17',
        'character': 'Eddard Stark',
      });

      expect(credit.mediaType, CreditMediaType.tv);
      expect(credit.title, 'Game of Thrones');
      expect(credit.releaseDate, '2011-04-17');
      expect(credit.role, 'Eddard Stark');
    });

    test('falls back to the crew job when there is no character', () {
      final credit = PersonCredit.fromJson(const {
        'id': 1,
        'media_type': 'movie',
        'title': 'Some Film',
        'job': 'Director',
      });

      expect(credit.role, 'Director');
    });

    test('maps an unknown media_type to null (non-routable)', () {
      final credit = PersonCredit.fromJson(const {
        'id': 1,
        'media_type': 'person',
        'name': 'Self',
      });

      expect(credit.mediaType, isNull);
    });
  });

  group('PosterItem contract', () {
    test('year is the 4-digit release year', () {
      expect(
        PersonCredit.fromJson(const {
          'id': 1,
          'media_type': 'movie',
          'release_date': '1999-10-15',
        }).year,
        '1999',
      );
    });

    test('formattedRating is one decimal, or NR when unrated', () {
      final rated = PersonCredit.fromJson(const {
        'id': 1,
        'media_type': 'movie',
        'vote_average': 7.4567,
        'vote_count': 100,
      });
      final unrated = PersonCredit.fromJson(const {
        'id': 2,
        'media_type': 'movie',
        'vote_average': 0,
        'vote_count': 0,
      });

      expect(rated.formattedRating, '7.5');
      expect(unrated.formattedRating, 'NR');
    });

    test('posterUrl builds an image URL, empty when no poster', () {
      final withPoster = PersonCredit.fromJson(const {
        'id': 1,
        'media_type': 'movie',
        'poster_path': '/abc.jpg',
      });
      final withoutPoster = PersonCredit.fromJson(const {
        'id': 2,
        'media_type': 'movie',
      });

      expect(withPoster.posterUrl(), endsWith('/w500/abc.jpg'));
      expect(withoutPoster.posterUrl(), '');
    });
  });
}
