import 'package:equatable/equatable.dart';
import 'package:tmdb/shared/domain/watch_provider.dart';

/// Parses a `/watch/providers` response, preferring [region] and falling back
/// to [fallbackRegion] when TMDB has no data for the user's country (many
/// countries — e.g. Myanmar — aren't covered at all). Returns `null` when
/// neither region is present.
WatchProviders? parseWatchProviders(
  Map<String, dynamic> json, {
  required String region,
  String fallbackRegion = 'US',
}) {
  final results = json['results'] as Map<String, dynamic>?;
  if (results == null || results.isEmpty) return null;
  final code = results.containsKey(region)
      ? region
      : (results.containsKey(fallbackRegion) ? fallbackRegion : null);
  if (code == null) return null;
  final regionJson = results[code];
  if (regionJson is! Map<String, dynamic>) return null;
  return WatchProviders.fromJson(regionJson, region: code);
}

/// Where a title can be watched in one region, from `/watch/providers`. TMDB
/// sources this data from JustWatch (attribution required), so the UI shows a
/// JustWatch credit and links to [link] for the full, up-to-date offering.
class WatchProviders extends Equatable {
  const WatchProviders({
    required this.region,
    required this.link,
    required this.stream,
    required this.rent,
    required this.buy,
  });

  /// Parses one region entry from the `results` map (e.g. `results['US']`).
  /// [region] is the ISO-3166 code that entry was keyed under.
  factory WatchProviders.fromJson(
    Map<String, dynamic> json, {
    required String region,
  }) {
    List<WatchProvider> parse(String key) =>
        ((json[key] as List?) ?? const [])
            .map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.displayPriority.compareTo(b.displayPriority));

    return WatchProviders(
      region: region,
      link: json['link'] as String? ?? '',
      stream: parse('flatrate'),
      rent: parse('rent'),
      buy: parse('buy'),
    );
  }

  /// ISO-3166 region these offerings apply to (e.g. `"US"`). Surfaced in the UI
  /// so a fallback region is never shown as if it were the user's own.
  final String region;

  /// TMDB watch page for this title in this region.
  final String link;

  /// Subscription / included-with-service providers (`flatrate`).
  final List<WatchProvider> stream;
  final List<WatchProvider> rent;
  final List<WatchProvider> buy;

  bool get isEmpty => stream.isEmpty && rent.isEmpty && buy.isEmpty;
  bool get isNotEmpty => !isEmpty;

  @override
  List<Object?> get props => [region, link, stream, rent, buy];
}
