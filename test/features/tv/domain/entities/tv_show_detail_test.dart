import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';

import '../../../../helpers/tv_fixtures.dart';

void main() {
  group('TvShowDetail.fromJson', () {
    test('parses seasons, episodes, genres, status, and dates', () {
      final detail = TvShowDetail.fromJson(const {
        'id': 1399,
        'name': 'Game of Thrones',
        'tagline': 'Winter Is Coming.',
        'overview': 'x',
        'poster_path': '/p.jpg',
        'backdrop_path': '/b.jpg',
        'first_air_date': '2011-04-17',
        'last_air_date': '2019-05-19',
        'vote_average': 8.4,
        'vote_count': 21000,
        'number_of_seasons': 8,
        'number_of_episodes': 73,
        'episode_run_time': [60],
        'genres': [
          {'id': 18, 'name': 'Drama'},
        ],
        'status': 'Ended',
      });

      expect(detail.id, 1399);
      expect(detail.numberOfSeasons, 8);
      expect(detail.numberOfEpisodes, 73);
      expect(detail.episodeRunTime, [60]);
      expect(detail.genres.single.name, 'Drama');
      expect(detail.status, 'Ended');
      expect(detail.firstAirYear, '2011');
      // Cast and recommendations come from separate endpoints.
      expect(detail.cast, isEmpty);
      expect(detail.recommendations, isEmpty);
    });

    test('defaults numeric and list fields when missing', () {
      final detail = TvShowDetail.fromJson(const {'id': 1});

      expect(detail.numberOfSeasons, 0);
      expect(detail.numberOfEpisodes, 0);
      expect(detail.episodeRunTime, isEmpty);
      expect(detail.genres, isEmpty);
      expect(detail.formattedRating, 'NR');
    });
  });

  group('copyWith', () {
    test('injects cast and recommendations, preserving base fields', () {
      final base = buildTvShowDetail();
      final updated = base.copyWith(
        cast: [buildTvCastMember()],
        recommendations: [buildTvShow(id: 100)],
      );

      expect(updated.cast, hasLength(1));
      expect(updated.recommendations.single.id, 100);
      expect(updated.id, base.id);
      expect(updated.numberOfSeasons, base.numberOfSeasons);
      expect(updated.name, base.name);
    });
  });

  group('season / episode labels', () {
    test('pluralise correctly', () {
      expect(buildTvShowDetail(numberOfSeasons: 8).seasonsLabel, '8 Seasons');
      expect(buildTvShowDetail(numberOfSeasons: 1).seasonsLabel, '1 Season');
      expect(
        buildTvShowDetail(numberOfEpisodes: 73).episodesLabel,
        '73 Episodes',
      );
      expect(buildTvShowDetail(numberOfEpisodes: 1).episodesLabel, '1 Episode');
    });

    test('are empty when the counts are unknown', () {
      expect(buildTvShowDetail(numberOfSeasons: 0).seasonsLabel, '');
      expect(buildTvShowDetail(numberOfEpisodes: 0).episodesLabel, '');
    });
  });
}
