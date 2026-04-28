/// TMDB API endpoints and base URLs.
///
/// Auth is handled by [ApiClient] using a v4 Read Access Token (preferred,
/// passed as `Bearer` header) or a v3 API key (passed as `api_key` query).
/// Provide one via `--dart-define`:
///
/// ```sh
/// flutter run \
///   --dart-define=TMDB_BEARER_TOKEN=eyJhbGciOi...   # v4 read access token
///   # or
///   --dart-define=TMDB_API_KEY=abc123def456...      # v3 api key
/// ```
class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// Base URL for poster / backdrop images. Append a size and the
  /// `poster_path` / `backdrop_path` returned by the API.
  ///
  /// Common sizes:
  ///   posters:   w92, w154, w185, w342, w500, w780, original
  ///   backdrops: w300, w780, w1280, original
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  /// Read from `--dart-define`. Empty string when not provided.
  static const String bearerToken =
      String.fromEnvironment('TMDB_BEARER_TOKEN');
  static const String apiKey = String.fromEnvironment('TMDB_API_KEY');

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
