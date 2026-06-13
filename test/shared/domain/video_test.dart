import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/shared/domain/video.dart';

void main() {
  group('Video.fromJson', () {
    test('parses a /videos result row', () {
      final video = Video.fromJson(const <String, dynamic>{
        'id': '5c9294240e0a267cd516835f',
        'key': 'BdJKm16Co6M',
        'name': 'Official Trailer',
        'site': 'YouTube',
        'type': 'Trailer',
        'official': true,
        'published_at': '2019-09-13T20:24:01.000Z',
      });

      expect(video.id, '5c9294240e0a267cd516835f');
      expect(video.key, 'BdJKm16Co6M');
      expect(video.name, 'Official Trailer');
      expect(video.site, 'YouTube');
      expect(video.type, 'Trailer');
      expect(video.official, isTrue);
      expect(video.publishedAt, '2019-09-13T20:24:01.000Z');
    });

    test('defaults missing fields gracefully', () {
      final video = Video.fromJson(const <String, dynamic>{'key': 'abc'});

      expect(video.id, '');
      expect(video.name, '');
      expect(video.site, '');
      expect(video.type, '');
      expect(video.official, isFalse);
      expect(video.publishedAt, '');
    });
  });

  group('Video computed properties', () {
    test('isYouTube is true only for YouTube videos with a key', () {
      expect(_video(site: 'YouTube', key: 'k').isYouTube, isTrue);
      expect(_video(site: 'Vimeo', key: 'k').isYouTube, isFalse);
      expect(_video(site: 'YouTube', key: '').isYouTube, isFalse);
    });

    test('youtubeUrl and thumbnailUrl embed the key for YouTube videos', () {
      final video = _video(site: 'YouTube', key: 'BdJKm16Co6M');

      expect(video.youtubeUrl, 'https://www.youtube.com/watch?v=BdJKm16Co6M');
      expect(
        video.thumbnailUrl,
        'https://img.youtube.com/vi/BdJKm16Co6M/hqdefault.jpg',
      );
    });

    test('youtubeUrl and thumbnailUrl are empty for non-YouTube videos', () {
      final video = _video(site: 'Vimeo', key: 'k');

      expect(video.youtubeUrl, '');
      expect(video.thumbnailUrl, '');
    });
  });

  group('VideoSelection.youTubeVideos', () {
    test('keeps only playable YouTube videos', () {
      final videos = [
        _video(key: 'yt', site: 'YouTube'),
        _video(key: 'vm', site: 'Vimeo'),
        _video(key: '', site: 'YouTube'),
      ];

      expect(videos.youTubeVideos.map((v) => v.key), ['yt']);
    });

    test('orders trailers before teasers before clips', () {
      final videos = [
        _video(key: 'clip', type: 'Clip'),
        _video(key: 'teaser', type: 'Teaser'),
        _video(key: 'trailer', type: 'Trailer'),
      ];

      expect(videos.youTubeVideos.map((v) => v.key), [
        'trailer',
        'teaser',
        'clip',
      ]);
    });

    test('prefers official uploads within the same type', () {
      final videos = [
        _video(key: 'fan', type: 'Trailer', official: false),
        _video(key: 'official', type: 'Trailer', official: true),
      ];

      expect(videos.youTubeVideos.first.key, 'official');
    });

    test('breaks ties by newest published date', () {
      final videos = [
        _video(key: 'old', type: 'Trailer', publishedAt: '2020-01-01'),
        _video(key: 'new', type: 'Trailer', publishedAt: '2023-01-01'),
      ];

      expect(videos.youTubeVideos.first.key, 'new');
    });
  });

  group('VideoSelection.bestTrailer', () {
    test('returns the top-ranked YouTube video', () {
      final videos = [
        _video(key: 'clip', type: 'Clip'),
        _video(key: 'trailer', type: 'Trailer'),
      ];

      expect(videos.bestTrailer?.key, 'trailer');
    });

    test('returns null when there are no YouTube videos', () {
      final videos = [_video(key: 'vm', site: 'Vimeo')];

      expect(videos.bestTrailer, isNull);
    });
  });
}

Video _video({
  String key = 'k',
  String site = 'YouTube',
  String type = 'Trailer',
  bool official = true,
  String publishedAt = '2024-01-01',
}) {
  return Video(
    id: key,
    key: key,
    name: type,
    site: site,
    type: type,
    official: official,
    publishedAt: publishedAt,
  );
}
