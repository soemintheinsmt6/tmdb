import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/features/movies/domain/entities/movie.dart';
import 'package:tmdb/features/tv/domain/entities/tv_show.dart';
import 'package:tmdb/shared/domain/media/poster_item.dart';

/// Network-only client for trending content. Throws the exceptions defined in
/// `core/error/exceptions.dart`; the repository converts them to `Failure`s.
class TrendingRemoteDataSource {
  const TrendingRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  /// Mixed movie + TV trending titles from `/trending/all/{window}`. People
  /// rows (and any other kinds) are skipped — see [_parseMixed].
  Future<List<PosterItem>> getTrending({String window = 'day'}) async {
    final response = await _apiClient.get(
      ApiConstants.trendingAll(window: window),
      query: {'language': 'en-US'},
    );
    final json = response as Map<String, dynamic>;
    return _parseMixed((json['results'] as List?) ?? const []);
  }

  /// Trending TV shows only, from `/trending/tv/{window}`.
  Future<List<TvShow>> getTrendingTv({String window = 'day'}) async {
    final response = await _apiClient.get(
      ApiConstants.trendingTv(window: window),
      query: {'language': 'en-US'},
    );
    final json = response as Map<String, dynamic>;
    return ((json['results'] as List?) ?? const [])
        .map((e) => TvShow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Maps mixed `/trending/all` rows to [Movie] / [TvShow] by their
  /// `media_type`, dropping people (and any kind the app cannot render).
  List<PosterItem> _parseMixed(List<dynamic> results) {
    final items = <PosterItem>[];
    for (final raw in results) {
      final json = raw as Map<String, dynamic>;
      switch (json['media_type']) {
        case 'movie':
          items.add(Movie.fromJson(json));
        case 'tv':
          items.add(TvShow.fromJson(json));
      }
    }
    return items;
  }
}
