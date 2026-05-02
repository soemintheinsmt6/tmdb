import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tmdb/app.dart';
import 'package:tmdb/core/config/env.dart';
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/network/api_client.dart';
import 'package:tmdb/injection_container.dart' as di;
import 'package:tmdb/injection_container.dart';

/// End-to-end smoke test that boots the real `App`, replaces `ApiClient`
/// with a deterministic fake, and drives a full user journey:
/// home → switch tabs → open detail → favourite → see it on the favourites
/// tab. ObjectBox runs for real (favourites are persisted via the native
/// lib that ships with `objectbox_flutter_libs`), so this must execute on
/// a device or simulator — it cannot run via `flutter test`.
///
/// Run on a connected iOS simulator / Android emulator / macOS desktop:
///
///     flutter devices              # list available devices
///     flutter test integration_test/app_smoke_test.dart -d <device-id>
///
/// To run against the real TMDB API instead of the fake, comment out the
/// `_swapApiClient()` line below.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Env.init();
    await di.init();
    _swapApiClient();
  });

  testWidgets(
      'home loads → switch category → open detail → favourite → '
      'appears on favourites tab', (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // 1. Home renders the popular list from the fake.
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('Tenet'), findsOneWidget);

    // 2. Switching to the Top Rated tab refetches and replaces the grid.
    await tester.tap(find.text('Top Rated'));
    await tester.pumpAndSettle();
    expect(find.text('The Godfather'), findsOneWidget);
    expect(find.text('Inception'), findsNothing);

    // 3. Tap the movie → push the detail screen, which loads detail +
    // credits + recommendations in parallel.
    await tester.tap(find.text('The Godfather'));
    await tester.pumpAndSettle();
    expect(find.text('An offer you can\'t refuse.'), findsOneWidget);

    // 4. Tap the heart → favourite the movie (persisted via real ObjectBox).
    await tester.tap(find.byTooltip('Add to favourites'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Remove from favourites'), findsOneWidget);

    // 5. Pop back to home, then switch to the Favourites bottom-nav tab.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Favourites'));
    await tester.pumpAndSettle();

    // 6. The favourited movie shows up there — ObjectBox round-tripped it
    // and the cubit's stream pushed the new state across tabs.
    expect(find.text('The Godfather'), findsOneWidget);
  });
}

void _swapApiClient() {
  // Lazy singletons defer creation, so swapping `ApiClient` here — after
  // `di.init()` registers it but before any consumer resolves it — wires
  // the fake all the way down: MovieRepository → MovieRemoteDataSource →
  // ApiClient (fake).
  sl.unregister<ApiClient>();
  sl.registerLazySingleton<ApiClient>(() => _FakeApiClient());
}

/// Returns canned TMDB-shaped JSON for every endpoint the smoke test hits.
/// Throws on anything else so unexpected calls fail loudly.
class _FakeApiClient implements ApiClient {
  @override
  Future<dynamic> get(String endpoint, {Map<String, String>? query}) async {
    if (endpoint == ApiConstants.popularMovies) {
      return _page([
        {'id': 27205, 'title': 'Inception'},
        {'id': 577922, 'title': 'Tenet'},
      ]);
    }
    if (endpoint == ApiConstants.topRatedMovies) {
      return _page([
        {'id': 238, 'title': 'The Godfather'},
      ]);
    }
    if (endpoint == ApiConstants.nowPlayingMovies ||
        endpoint == ApiConstants.upcomingMovies ||
        endpoint == ApiConstants.searchMovies) {
      return _page(const []);
    }
    final detailMatch = RegExp(r'^/movie/(\d+)$').firstMatch(endpoint);
    if (detailMatch != null) {
      final id = int.parse(detailMatch.group(1)!);
      return <String, dynamic>{
        'id': id,
        'title': id == 238 ? 'The Godfather' : 'Movie $id',
        'tagline': "An offer you can't refuse.",
        'overview': 'The aging patriarch of an organised-crime dynasty…',
        'release_date': '1972-03-24',
        'vote_average': 8.7,
        'vote_count': 18000,
        'runtime': 175,
        'genres': [
          {'id': 18, 'name': 'Drama'},
          {'id': 80, 'name': 'Crime'},
        ],
        'status': 'Released',
      };
    }
    if (endpoint.endsWith('/credits')) {
      return <String, dynamic>{
        'cast': [
          {
            'id': 1,
            'name': 'Marlon Brando',
            'character': 'Don Vito Corleone',
            'order': 0,
          },
        ],
      };
    }
    if (endpoint.endsWith('/recommendations')) {
      return _page(const []);
    }
    throw UnimplementedError('FakeApiClient: unhandled endpoint "$endpoint"');
  }

  Map<String, dynamic> _page(List<Map<String, dynamic>> movies) {
    return <String, dynamic>{
      'page': 1,
      'results': movies,
      'total_pages': 1,
      'total_results': movies.length,
    };
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
