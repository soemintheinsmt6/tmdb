import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

void main() {
  group('TvShow.fromJson', () {
    test('parses TV fields including name and first_air_date', () {
      final show = TvShow.fromJson(const {
        'id': 1399,
        'name': 'Game of Thrones',
        'overview': 'x',
        'poster_path': '/p.jpg',
        'backdrop_path': '/b.jpg',
        'first_air_date': '2011-04-17',
        'vote_average': 8.4,
        'vote_count': 21000,
        'genre_ids': [18, 10765],
      });

      expect(show.id, 1399);
      expect(show.name, 'Game of Thrones');
      expect(show.firstAirDate, '2011-04-17');
      expect(show.posterPath, '/p.jpg');
      expect(show.genreIds, [18, 10765]);
    });

    test('falls back to title / release_date when TV keys are absent', () {
      final show = TvShow.fromJson(const {
        'id': 1,
        'title': 'Movie-ish',
        'release_date': '2020-01-01',
      });

      expect(show.name, 'Movie-ish');
      expect(show.firstAirDate, '2020-01-01');
    });

    test('tolerates missing optional fields', () {
      final show = TvShow.fromJson(const {'id': 7});

      expect(show.name, '');
      expect(show.overview, '');
      expect(show.posterPath, isNull);
      expect(show.firstAirDate, '');
      expect(show.voteAverage, 0);
      expect(show.voteCount, 0);
      expect(show.genreIds, isEmpty);
    });
  });

  group('PosterItem contract', () {
    test('is a PosterItem; title maps to name and year to first-air year', () {
      final show = TvShow.fromJson(const {
        'id': 1,
        'name': 'Show',
        'first_air_date': '2018-09-01',
        'vote_average': 7.0,
        'vote_count': 10,
      });

      expect(show, isA<PosterItem>());
      expect(show.title, 'Show');
      expect(show.year, '2018');
    });

    test('formattedRating is NR with no votes, else one decimal', () {
      expect(buildShow(voteCount: 0).formattedRating, 'NR');
      expect(buildShow(voteAverage: 8.4, voteCount: 5).formattedRating, '8.4');
    });

    test('posterUrl is empty when posterPath is null', () {
      expect(buildShow(posterPath: null).posterUrl(), '');
    });

    test('posterUrl joins the TMDB image base and size', () {
      expect(
        buildShow(posterPath: '/p.jpg').posterUrl(size: 'w185'),
        'https://image.tmdb.org/t/p/w185/p.jpg',
      );
    });
  });
}

TvShow buildShow({
  String? posterPath = '/p.jpg',
  double voteAverage = 7.0,
  int voteCount = 10,
}) {
  return TvShow(
    id: 1,
    name: 'Show',
    overview: '',
    posterPath: posterPath,
    backdropPath: null,
    firstAirDate: '2018-09-01',
    voteAverage: voteAverage,
    voteCount: voteCount,
    genreIds: const [],
  );
}
