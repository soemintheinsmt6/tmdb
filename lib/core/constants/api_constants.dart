import 'package:tmdb/core/config/env.dart';

/// TMDB API endpoints and image helpers.
///
/// `baseUrl` and `apiKey` come from the environment loaded by [Env].
class ApiConstants {
  ApiConstants._();

  static String get baseUrl => Env.baseUrl;
  static String get apiKey => Env.apiKey;

  /// Base URL for poster / backdrop images. Append a size and the
  /// `poster_path` / `backdrop_path` returned by the API.
  ///
  /// Common sizes:
  ///   posters:   w92, w154, w185, w342, w500, w780, original
  ///   backdrops: w300, w780, w1280, original
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  // ── Movies ────────────────────────────────────────────
  static const String popularMovies = '/movie/popular';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static String movieDetail(int id) => '/movie/$id';
  static String movieCredits(int id) => '/movie/$id/credits';
  static String movieRecommendations(int id) => '/movie/$id/recommendations';
  static String movieVideos(int id) => '/movie/$id/videos';

  // ── Search ────────────────────────────────────────────
  static const String searchMovies = '/search/movie';

  // ── Genres ────────────────────────────────────────────
  static const String movieGenres = '/genre/movie/list';

  // ── Image helpers ─────────────────────────────────────
  static String posterUrl(String? path, {String size = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static String backdropUrl(String? path, {String size = 'w1280'}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }

  static String profileUrl(String? path, {String size = 'w185'}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl/$size$path';
  }
}
