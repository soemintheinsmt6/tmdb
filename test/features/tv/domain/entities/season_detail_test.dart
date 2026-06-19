import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/features/tv/domain/entities/season_detail.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show_detail.dart';

void main() {
  group('Season (parsed from TvShowDetail)', () {
    test('TvShowDetail.fromJson parses the seasons array', () {
      final json = <String, dynamic>{
        'id': 1399,
        'name': 'Game of Thrones',
        'seasons': [
          {
            'id': 3624,
            'season_number': 1,
            'name': 'Season 1',
            'overview': 'The first season.',
            'poster_path': '/s1.jpg',
            'air_date': '2011-04-17',
            'episode_count': 10,
            'vote_average': 8.3,
          },
          {
            'id': 3625,
            'season_number': 0,
            'name': 'Specials',
            'episode_count': 0,
          },
        ],
      };

      final detail = TvShowDetail.fromJson(json);

      expect(detail.seasons, hasLength(2));
      final first = detail.seasons.first;
      expect(first.seasonNumber, 1);
      expect(first.episodeCount, 10);
      expect(first.episodeCountLabel, '10 Episodes');
      expect(first.airYear, '2011');
      expect(first.posterUrl(), contains('/s1.jpg'));
    });

    test('TvShowDetail.fromJson defaults seasons to empty when absent', () {
      final json = <String, dynamic>{'id': 1, 'name': 'No Seasons'};
      final detail = TvShowDetail.fromJson(json);
      expect(detail.seasons, isEmpty);
    });
  });

  group('SeasonDetail.fromJson', () {
    test('parses season metadata and its episodes', () {
      final json = <String, dynamic>{
        'id': 3624,
        'season_number': 1,
        'name': 'Season 1',
        'overview': 'The first season.',
        'air_date': '2011-04-17',
        'episodes': [
          {
            'id': 63056,
            'episode_number': 1,
            'season_number': 1,
            'name': 'Winter Is Coming',
            'overview': 'Lord Stark is troubled.',
            'still_path': '/still.jpg',
            'air_date': '2011-04-17',
            'vote_average': 8.0,
            'vote_count': 350,
            'runtime': 62,
          },
        ],
      };

      final season = SeasonDetail.fromJson(json);

      expect(season.seasonNumber, 1);
      expect(season.episodes, hasLength(1));
      final episode = season.episodes.first;
      expect(episode.episodeNumber, 1);
      expect(episode.name, 'Winter Is Coming');
      expect(episode.runtimeLabel, '62 min');
      expect(episode.formattedRating, '8.0');
      expect(episode.stillUrl(), contains('/still.jpg'));
    });

    test('tolerates a missing episodes list', () {
      final json = <String, dynamic>{
        'id': 1,
        'season_number': 2,
        'name': 'Season 2',
      };
      final season = SeasonDetail.fromJson(json);
      expect(season.episodes, isEmpty);
    });
  });
}
