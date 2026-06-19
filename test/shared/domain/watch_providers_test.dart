import 'package:flutter_test/flutter_test.dart';
import 'package:tmdb/shared/domain/media/watch_providers.dart';

void main() {
  group('WatchProviders.fromJson', () {
    test('parses flatrate/rent/buy, sorts by priority, keeps the region', () {
      final json = <String, dynamic>{
        'link': 'https://themoviedb.org/watch',
        'flatrate': [
          {
            'provider_id': 8,
            'provider_name': 'Netflix',
            'logo_path': '/n.jpg',
            'display_priority': 2,
          },
          {
            'provider_id': 9,
            'provider_name': 'Prime Video',
            'logo_path': '/p.jpg',
            'display_priority': 0,
          },
        ],
        'rent': [
          {
            'provider_id': 2,
            'provider_name': 'Apple TV',
            'logo_path': '/a.jpg',
            'display_priority': 0,
          },
        ],
      };

      final providers = WatchProviders.fromJson(json, region: 'US');

      expect(providers.region, 'US');
      expect(providers.link, 'https://themoviedb.org/watch');
      // flatrate → stream, reordered by display priority (0 before 2).
      expect(providers.stream.map((e) => e.name), ['Prime Video', 'Netflix']);
      expect(providers.rent.single.name, 'Apple TV');
      expect(providers.buy, isEmpty);
      expect(providers.isNotEmpty, isTrue);
      expect(providers.stream.first.logoUrl(), contains('/p.jpg'));
    });

    test('isEmpty when the region has no offerings', () {
      final json = <String, dynamic>{'link': 'x'};
      final providers = WatchProviders.fromJson(json, region: 'GB');
      expect(providers.isEmpty, isTrue);
    });
  });

  group('parseWatchProviders region fallback', () {
    test('uses the device region when it is present', () {
      final json = <String, dynamic>{
        'results': {
          'US': {'link': 'u'},
          'GB': {
            'link': 'g',
            'flatrate': [
              {'provider_id': 1, 'provider_name': 'BBC'},
            ],
          },
        },
      };

      final providers = parseWatchProviders(json, region: 'GB');

      expect(providers, isNotNull);
      expect(providers!.region, 'GB');
      expect(providers.stream.single.name, 'BBC');
    });

    test('falls back to US when the device region is missing', () {
      final json = <String, dynamic>{
        'results': {
          'US': {
            'link': 'u',
            'flatrate': [
              {'provider_id': 8, 'provider_name': 'Netflix'},
            ],
          },
        },
      };

      // Myanmar (MM) isn't covered by TMDB — should surface US instead.
      final providers = parseWatchProviders(json, region: 'MM');

      expect(providers, isNotNull);
      expect(providers!.region, 'US');
      expect(providers.stream.single.name, 'Netflix');
    });

    test('returns null when neither the region nor US is present', () {
      final json = <String, dynamic>{
        'results': {
          'GB': {'link': 'g'},
        },
      };
      expect(parseWatchProviders(json, region: 'MM'), isNull);
    });

    test('returns null when results is empty or absent', () {
      final empty = <String, dynamic>{'results': <String, dynamic>{}};
      final none = <String, dynamic>{'id': 1};
      expect(parseWatchProviders(empty, region: 'US'), isNull);
      expect(parseWatchProviders(none, region: 'US'), isNull);
    });
  });
}
