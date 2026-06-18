# tmdb

A movie & TV browser built on top of [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs/getting-started).

## Tech stack

- **Flutter** (Material 3, light + dark themes that follow the system setting)
- **flutter_bloc** for state management (BLoCs for movies, TV & discover, Cubits for favourites & watchlist)
- **dartz** `Either<Failure, T>` for error handling
- **equatable** for value objects
- **get_it** for dependency injection
- **http** for networking (wrapped by `core/network/api_client.dart`)
- **hive** for local persistence of favourites & watchlist
- **cached_network_image**, **shimmer**, **iconsax_plus**, **google_fonts** for UI
- **youtube_player_flutter** (in-app trailers) · **url_launcher** ("Watch on YouTube" fallback) · **saver_gallery** (save backdrops to the device gallery)
- **bloc_test**, **mocktail**, **integration_test** for tests
- **GitHub Actions** CI (format + analyze + test + coverage), curated lints on top of **flutter_lints**, and ADRs in `docs/adr/`

## Architecture

Feature-first with a thin Clean-Architecture split. Each feature owns its `data/`, `domain/`, and `presentation/` layers; abstractions are kept only where they earn their keep (test seams, error mapping, persistence isolation). Use cases were intentionally collapsed — BLoCs depend on the `*Repository` abstract directly.

```
lib/
├── core/
│   ├── config/             # Env (loads .env via rootBundle)
│   ├── constants/          # api_constants.dart (TMDB endpoints + image URLs)
│   ├── error/              # exceptions.dart, failures.dart
│   ├── extensions/         # rating, runtime, year helpers
│   ├── logging/            # AppLogger seam + ConsoleLogger + global error handlers
│   ├── network/            # api_client.dart (api_key auth, retry/backoff, exception mapping)
│   ├── responsive/         # breakpoints + ResponsiveBuilder
│   ├── storage/            # Hive wrapper (favourites + watchlist boxes)
│   ├── theme/              # AppColors, AppTypography, AppTheme, AppDecoration
│   └── utils/              # navigation.dart, typedef.dart
├── features/
│   ├── movies/
│   │   ├── data/
│   │   │   ├── datasources/    # MovieRemoteDataSource (concrete, wraps ApiClient)
│   │   │   └── repositories/   # MovieRepositoryImpl (composition + Failure mapping)
│   │   ├── domain/
│   │   │   ├── entities/       # Movie (implements PosterItem), MovieDetail, PaginatedMovies
│   │   │   │                   # — entities own their fromJson; no separate Model class
│   │   │   └── repositories/   # MovieRepository (abstract — test seam)
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── movie_list_bloc/    # Popular / Now Playing / Top Rated / Upcoming
│   │       │   ├── movie_search_bloc/  # debounced search
│   │       │   └── movie_detail_bloc/  # /movie/{id} + credits + recs + videos + reviews + images
│   │       │                           #   (one parallel fetch, merged via copyWith)
│   │       ├── screens/
│   │       │   ├── home/{home_screen.dart, layouts/}
│   │       │   └── movie_detail/{movie_detail_screen.dart, layouts/}
│   │       └── widgets/        # home_content + movie_detail_cards (compose the shared kernel)
│   ├── tv/                     # Same shape as movies: TvShow (implements PosterItem),
│   │                           # TvShowDetail, TvRepository, remote data source,
│   │                           # tv_list/tv_search/tv_detail blocs, tv_screen + tv_detail.
│   │                           # Categories: Popular / Top Rated / On The Air / Airing Today.
│   │                           # Browse + detail; TV detail is saveable to the watchlist
│   │                           # (favouriting stays movies-only).
│   ├── discover/               # /discover/movie browse: DiscoverFilter (genres/sort/year/
│   │                           # min-rating → query params), DiscoverRepository, remote data
│   │                           # source, DiscoverBloc (flat state: genres + filter +
│   │                           # pagination), discover_screen + filter sheet. Its own tab;
│   │                           # also hosts the global multi-search (search icon → SearchScreen).
│   ├── search/                 # Global /search/multi (movies + TV + people) — SearchBloc,
│   │                           # search_screen + content; opened from the Discover tab.
│   ├── people/                 # Person (detail) + PersonCredit (implements PosterItem),
│   │                           # PersonRepository, remote data source (/person/{id} +
│   │                           # /person/{id}/combined_credits), person_detail bloc, and
│   │                           # person_detail screen (one width-adaptive layout — no
│   │                           # backdrop). Reached by tapping a cast tile on any movie/TV
│   │                           # detail; filmography posters route back into movie/TV detail.
│   ├── favourites/
│   │   ├── data/
│   │   │   ├── models/         # FavouriteMovie (Hive TypeAdapter, persistence-only)
│   │   │   └── repositories/   # FavouritesRepositoryImpl (queries Box; returns Movie)
│   │   ├── domain/
│   │   │   └── repositories/   # FavouritesRepository (abstract — test seam)
│   │   └── presentation/
│   │       ├── cubit/          # FavouritesCubit + FavouritesState({movies, ids})
│   │       ├── screens/        # FavouriteScreen (standalone; body = FavouritesListView)
│   │       └── widgets/        # FavouriteHeroCard, FavouriteToggleButton, FavouritesListView
│   ├── watchlist/
│   │   ├── data/
│   │   │   ├── models/         # WatchlistEntry (Hive TypeAdapter, typeId 2; movies + TV)
│   │   │   └── repositories/   # WatchlistRepositoryImpl ("movie:ID"/"tv:ID" composite keys)
│   │   ├── domain/
│   │   │   ├── entities/       # WatchlistItem (MediaType movie|tv, implements PosterItem)
│   │   │   └── repositories/   # WatchlistRepository (abstract — test seam)
│   │   └── presentation/
│   │       ├── cubit/          # WatchlistCubit + WatchlistState({items, keys})
│   │       └── widgets/        # WatchlistHeroCard, WatchlistToggleButton, WatchlistListView
│   ├── library/
│   │   └── presentation/
│   │       └── screens/        # LibraryScreen (Favourites + Watchlist tabs; the nav tab)
│   └── profile/
│       └── presentation/
│           ├── screens/        # ProfileScreen (favourite count + clear / about)
│           └── widgets/        # ProfileHeader, SettingsTile
├── shared/
│   ├── domain/                 # PosterItem (poster view contract), Genre, CastMember,
│   │                           # Video, Review, MediaImage (detail sub-resources)
│   └── widgets/                # Poster kernel shared by movies + TV — PosterGrid,
│                               # PosterCard, PosterImage, RatingBadge, PosterGridSkeleton,
│                               # CategoryTabBar, detail_cards (DetailHeader/Summary/CastList/
│                               # PosterRail/VideoRail/ReviewsSection/ImageGallery) — plus
│                               # TrailerPlayerScreen, ImageGalleryViewer, AppSearchField,
│                               # AppErrorView, AppEmptyView, RootScreen (5-tab shell)
├── injection_container.dart    # GetIt registrations
├── app.dart                    # MaterialApp + global providers
└── main.dart                   # boot: Env.init → di.init → runApp
```

**Error flow.** `ApiClient` applies a per-request timeout and retries transient failures (network errors + 5xx) with exponential backoff before throwing `UnauthorizedException` / `ServerException` / `NetworkException`; 4xx (incl. 401) fail fast. `MovieRepositoryImpl._guard` converts them to `ServerFailure` (with the original status code, or 401 for unauthorised) / `NetworkFailure`, logging each mapped failure through the `AppLogger` seam. BLoCs `fold` the `Either<Failure, T>` into success / error states.

**Observability.** Code logs through the injected `AppLogger` abstraction, never `print`. The default `ConsoleLogger` routes to `dart:developer`; global Flutter/platform errors are funnelled in at boot. Shipping a crash reporter is a one-line DI swap — see [ADR 0005](docs/adr/0005-observability-seam.md). The network logger logs endpoint paths only, never the `api_key`-bearing URL.

**Persistence boundary.** `FavouriteMovie` and `WatchlistEntry` (each Hive-encoded via a hand-written `TypeAdapter`, type ids `1` and `2`) live only in their feature data layers. The repositories convert to domain types (`Movie` / `WatchlistItem`) at the boundary, so widgets and cubits never see the persistence rows. The watchlist spans both movies and TV shows, so its rows carry a media-type discriminator and are keyed `"movie:ID"` / `"tv:ID"` — numeric ids can collide across the two verticals, so the type is part of the key.

## Setup

1. Install dependencies:

   ```bash
   flutter pub get
   ```

2. Create a `.env` file at the project root with your TMDB v3 API key:

   ```
   BASE_URL=https://api.themoviedb.org/3
   API_KEY=<your-tmdb-v3-api-key>
   ```

   The file is bundled as a Flutter asset (see `pubspec.yaml`) and loaded by `Env.init` at startup.

3. Run the app:

   ```bash
   flutter run                         # default device
   flutter run -d <device-id>          # specific device — use `flutter devices`
   ```

## Tests

The project has three test layers; together they're 301 host-side tests + one device E2E.

```bash
dart format --set-exit-if-changed .   # formatting gate
flutter analyze                       # static analysis (curated lints, strict casts)
flutter test                          # unit + widget + screen-integration tests
flutter test --coverage               # with lcov coverage report
```

These three commands are exactly what CI runs on every push/PR — see
`.github/workflows/ci.yml`. Lint choices and other non-obvious decisions are
recorded in [`docs/adr/`](docs/adr/README.md).

Test layout mirrors `lib/`:

```
test/
├── core/                       # extensions, breakpoints, URL helpers, Failure, ApiClient retry
├── features/
│   ├── movies/
│   │   ├── data/               # repository impl, remote data source
│   │   ├── domain/entities/    # fromJson, copyWith, computed props
│   │   └── presentation/bloc/  # MovieList, MovieSearch, MovieDetail blocs
│   ├── tv/                     # mirrors movies: entities, data, TvList/TvSearch/TvDetail blocs
│   ├── discover/               # DiscoverFilter, remote data source, repo impl, DiscoverBloc
│   ├── people/                 # PersonCredit/Person entities, data (datasource + repo),
│   │                           # PersonDetail bloc
│   ├── favourites/
│   │   ├── data/models/        # FavouriteMovie mapper
│   │   └── presentation/cubit/ # FavouritesState, FavouritesCubit
│   └── watchlist/
│       ├── data/models/        # WatchlistEntry round-trip (incl. movie/TV id-collision)
│       └── presentation/cubit/ # WatchlistState, WatchlistCubit
├── shared/domain/              # Video, Review, MediaImage entity + selection tests
├── integration/                # screen-level: real bloc + real widgets + mocked repo
│   ├── home_content_test.dart
│   ├── tv_content_test.dart
│   └── favourite_screen_test.dart
└── helpers/                    # movie_fixtures.dart, tv_fixtures.dart, people_fixtures.dart
                                # (shared builders)
```

### End-to-end (`integration_test`)

A full-app smoke test boots the real `App`, swaps `ApiClient` for a deterministic fake (lazy-singleton swap via `GetIt`), and drives a complete user journey: home loads → switch tab → open detail → favourite → switch to favourites tab and verify. Hive runs for real, so the test must execute on a device, simulator, or desktop — not via `flutter test`.

```bash
flutter devices                                                 # list targets
flutter test integration_test/app_smoke_test.dart -d macos      # macOS desktop
flutter test integration_test/app_smoke_test.dart -d <id>       # iPhone / Android
```

To run E2E against the real TMDB API, comment out `_swapApiClient()` in `setUpAll`.

## Features

- **Browse** Popular, Now Playing, Top Rated, Upcoming with a horizontal tab switcher.
- **Search** with 400 ms debounce; falls back to category browse when cleared.
- **Infinite scroll** + pull-to-refresh on the category grid.
- **Movie detail** with full-bleed backdrop header, runtime / year / genres chips, top-billed cast (capped at 20, each face tappable → person page), a **trailers & clips** rail, a **photos** gallery, **More Like This** recommendations, and **user reviews**. The detail, credits, recommendations, videos, reviews and images are fetched in one parallel request and merged. Header renders immediately from a seed backdrop path passed via the route, so navigation lands on the image instead of a spinner.
- **Discover & filters** — a dedicated tab over `/discover/movie`: filter by genre, sort order, release year, and minimum rating in a bottom-sheet, with infinite-scroll results. The global multi-search (movies + TV + people via `/search/multi`) lives behind a search icon in this tab.
- **Trailers** — tapping a video opens an in-app YouTube player (`youtube_player_flutter`) with a custom control bar: red scrubber, tap to play/pause, **double-tap left/right to seek ±10 s**, and a fullscreen toggle that rotates to landscape. Owner-disabled / region- or age-restricted videos fall back to a "Watch on YouTube" action.
- **Photos** — a backdrop gallery on movie & TV detail opens a full-screen viewer: swipe between images, pinch-zoom, **double-tap to zoom** (centred on the tap), and **save to the device gallery** (`saver_gallery`, with photo-library permission handling on iOS & Android).
- **Reviews** — author, score, and expandable review text on movie & TV detail.
- **TV shows** on their own tab (Popular / Top Rated / On The Air / Airing Today) with the same search, infinite scroll, and detail layout — season & episode counts replace runtime. TV detail pages are saveable to the watchlist (favouriting stays movies-only). Movies and TV share one **poster kernel** (`PosterItem` view contract + `PosterGrid`/`PosterCard`/detail cards in `shared/`), so the second vertical reuses the first's UI rather than duplicating it.
- **People / cast** — tap any cast member to open a person page with their profile photo, known-for department, birthday / age / birthplace, an expandable biography, and a combined movie + TV **filmography** (sorted by popularity) whose posters route back into the matching movie or TV detail. Reuses the same poster kernel as the browse grids.
- **Favourites** (movies) persisted locally via Hive; reactive — toggling on the detail screen updates the home grid heart and the Library tab in real time.
- **Watchlist** — a separate "watch later" list spanning **both movies and TV shows**, persisted locally via Hive and reactive like favourites. A bookmark toggle on movie & TV detail saves/removes; each saved card carries a MOVIE/TV chip and routes back to the matching detail screen.
- **Shared-element transition** — tapping a favourites or watchlist card flies its backdrop into the detail header with a corner-radius interpolation (16 → 0). Push only; pop uses the standard route transition (suppressed via `PopScope` so the detail screen exits as a single unit).
- **Profile tab** showing favourites count plus a destructive "Clear favourites" flow with confirm dialog.
- **Five-tab shell** — Home · Discover · TV · Library · Profile, lazily built and kept alive via `IndexedStack`. The **Library** tab combines Favourites and Watchlist under one app bar with two segments.
- **Responsive grid** — 3 columns on mobile, scaling 4–7 on tablet (clamped on `width / 180`); aspect ratio shifts slightly between tiers.
- **Light & dark mode** — `MaterialApp` is wired with `themeMode: ThemeMode.system`. Theme-dependent surfaces/text live on `AppColors` instances (`AppColors.light` / `AppColors.dark`) and resolve at the call site via `context.colors`; brand and semantic colors stay as static constants.
