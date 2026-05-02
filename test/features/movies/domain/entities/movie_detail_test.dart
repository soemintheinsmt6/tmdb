import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/movies/domain/entities/cast_member.dart';
import 'package:tmdb/features/movies/domain/entities/genre.dart';
import 'package:tmdb/features/movies/domain/entities/movie_detail.dart';

import '../../../../helpers/movie_fixtures.dart';

void main() {
  group('Genre.fromJson', () {
    test('parses id and name', () {
      final genre = Genre.fromJson(<String, dynamic>{'id': 18, 'name': 'Drama'});

      expect(genre.id, 18);
      expect(genre.name, 'Drama');
    });

    test('defaults name to empty string when missing', () {
      final genre = Genre.fromJson(<String, dynamic>{'id': 1});

      expect(genre.name, '');
    });
  });

  group('CastMember.fromJson', () {
    test('parses a credits row', () {
      final cast = CastMember.fromJson(<String, dynamic>{
        'id': 287,
        'name': 'Brad Pitt',
        'character': 'Tyler Durden',
        'profile_path': '/brad.jpg',
        'order': 1,
      });

      expect(cast.id, 287);
      expect(cast.name, 'Brad Pitt');
      expect(cast.character, 'Tyler Durden');
      expect(cast.profilePath, '/brad.jpg');
      expect(cast.order, 1);
    });

    test('defaults missing fields gracefully', () {
      final cast = CastMember.fromJson(<String, dynamic>{'id': 1});

      expect(cast.name, '');
      expect(cast.character, '');
      expect(cast.profilePath, isNull);
      expect(cast.order, 0);
    });
  });

  group('MovieDetail.fromJson', () {
    test('parses the full /movie/{id} payload', () {
      final json = <String, dynamic>{
        'id': 550,
        'title': 'Fight Club',
        'tagline': 'Mischief. Mayhem. Soap.',
        'overview': 'An insomniac office worker...',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'release_date': '1999-10-15',
        'vote_average': 8.4,
        'vote_count': 27000,
        'runtime': 139,
        'genres': [
          {'id': 18, 'name': 'Drama'},
          {'id': 53, 'name': 'Thriller'},
        ],
        'status': 'Released',
      };

      final detail = MovieDetail.fromJson(json);

      expect(detail.id, 550);
      expect(detail.tagline, 'Mischief. Mayhem. Soap.');
      expect(detail.runtime, 139);
      expect(detail.genres, [
        const Genre(id: 18, name: 'Drama'),
        const Genre(id: 53, name: 'Thriller'),
      ]);
      expect(detail.status, 'Released');
      // Cast and recommendations aren't part of this endpoint — default empty.
      expect(detail.cast, isEmpty);
      expect(detail.recommendations, isEmpty);
    });

    test('attaches injected cast and recommendations', () {
      final cast = [buildCastMember(id: 1)];
      final recs = [buildMovie(id: 999, title: 'Recommended')];

      final detail = MovieDetail.fromJson(
        <String, dynamic>{'id': 550, 'title': 'Fight Club'},
        cast: cast,
        recommendations: recs,
      );

      expect(detail.cast, cast);
      expect(detail.recommendations, recs);
    });
  });

  group('MovieDetail.copyWith', () {
    test('replaces cast and recommendations only', () {
      final original = buildMovieDetail();
      final newCast = [buildCastMember(id: 7)];
      final newRecs = [buildMovie(id: 8)];

      final copy = original.copyWith(cast: newCast, recommendations: newRecs);

      expect(copy.cast, newCast);
      expect(copy.recommendations, newRecs);
      // Everything else is preserved.
      expect(copy.id, original.id);
      expect(copy.title, original.title);
      expect(copy.tagline, original.tagline);
      expect(copy.runtime, original.runtime);
      expect(copy.genres, original.genres);
    });

    test('preserves existing values when arguments are omitted', () {
      final cast = [buildCastMember()];
      final original = buildMovieDetail(cast: cast);

      final copy = original.copyWith();

      expect(copy.cast, cast);
      expect(copy.recommendations, original.recommendations);
    });
  });

  group('MovieDetail computed properties', () {
    test('formattedRating returns "NR" when voteCount is zero', () {
      final detail = buildMovieDetail(voteCount: 0);

      expect(detail.formattedRating, 'NR');
    });

    test('toMovie projects the detail back to a list-row Movie', () {
      final detail = buildMovieDetail(
        genres: const [Genre(id: 18, name: 'Drama'), Genre(id: 53, name: 'Thriller')],
      );

      final movie = detail.toMovie();

      expect(movie.id, detail.id);
      expect(movie.title, detail.title);
      expect(movie.genreIds, [18, 53]);
    });
  });
}
