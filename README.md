# tmdb

A movie & TV browser built on top of [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs/getting-started).

## Tech stack

- **Flutter** (Material 3, light + dark themes that follow the system setting)
- **flutter_bloc** for state management (BLoCs for movies & TV, Cubit for favourites)
- **dartz** `Either<Failure, T>` for error handling
- **equatable** for value objects
- **get_it** for dependency injection
- **http** for networking (wrapped by `core/network/api_client.dart`)
- **hive** for local persistence of favourites
- **cached_network_image**, **shimmer**, **iconsax_plus**, **google_fonts** for UI
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
│   ├── storage/            # Hive wrapper (favourites box)
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
│   │       │   └── movie_detail_bloc/  # /movie/{id} + credits + recommendations
│   │       ├── screens/
│   │       │   ├── home/{home_screen.dart, layouts/}
│   │       │   └── movie_detail/{movie_detail_screen.dart, layouts/}
│   │       └── widgets/        # home_content + movie_detail_cards (compose the shared kernel)
│   ├── tv/                     # Same shape as movies: TvShow (implements PosterItem),
│   │                           # TvShowDetail, TvRepository, remote data source,
│   │                           # tv_list/tv_search/tv_detail blocs, tv_screen + tv_detail.
│   │                           # Categories: Popular / Top Rated / On The Air / Airing Today.
│   │                           # Browse + detail only — no favouriting in v1.
│   ├── favourites/
│   │   ├── data/
│   │   │   ├── models/         # FavouriteMovie (Hive TypeAdapter, persistence-only)
│   │   │   └── repositories/   # FavouritesRepositoryImpl (queries Box; returns Movie)
│   │   ├── domain/
│   │   │   └── repositories/   # FavouritesRepository (abstract — test seam)
│   │   └── presentation/
│   │       ├── cubit/          # FavouritesCubit + FavouritesState({movies, ids})
│   │       ├── screens/        # FavouriteScreen
│   │       └── widgets/        # FavouriteHeroCard, FavouriteToggleButton
│   └── profile/
│       └── presentation/
│           ├── screens/        # ProfileScreen (favourite count + clear / about)
│           └── widgets/        # ProfileHeader, SettingsTile
├── shared/
│   ├── domain/                 # PosterItem (poster view contract), Genre, CastMember
│   └── widgets/                # Poster kernel shared by movies + TV — PosterGrid,
│                               # PosterCard, PosterImage, RatingBadge, PosterGridSkeleton,
│                               # CategoryTabBar, detail_cards (DetailHeader/Summary/
│                               # CastList/PosterRail) — plus AppSearchField, AppErrorView,
│                               # AppEmptyView, RootScreen
├── injection_container.dart    # GetIt registrations
├── app.dart                    # MaterialApp + global providers
└── main.dart                   # boot: Env.init → di.init → runApp
```

**Error flow.** `ApiClient` applies a per-request timeout and retries transient failures (network errors + 5xx) with exponential backoff before throwing `UnauthorizedException` / `ServerException` / `NetworkException`; 4xx (incl. 401) fail fast. `MovieRepositoryImpl._guard` converts them to `ServerFailure` (with the original status code, or 401 for unauthorised) / `NetworkFailure`, logging each mapped failure through the `AppLogger` seam. BLoCs `fold` the `Either<Failure, T>` into success / error states.

**Observability.** Code logs through the injected `AppLogger` abstraction, never `print`. The default `ConsoleLogger` routes to `dart:developer`; global Flutter/platform errors are funnelled in at boot. Shipping a crash reporter is a one-line DI swap — see [ADR 0005](docs/adr/0005-observability-seam.md). The network logger logs endpoint paths only, never the `api_key`-bearing URL.

**Persistence boundary.** `FavouriteMovie` (Hive-encoded via a hand-written `TypeAdapter`) lives only in the favourites data layer. The repository converts to `Movie` at the boundary, so widgets and the cubit only see domain types.

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

The project has three test layers; together they're 178 host-side tests + one device E2E.

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
│   └── favourites/
│       ├── data/models/        # FavouriteMovie mapper
│       └── presentation/cubit/ # FavouritesState, FavouritesCubit
├── integration/                # screen-level: real bloc + real widgets + mocked repo
│   ├── home_content_test.dart
│   ├── tv_content_test.dart
│   └── favourite_screen_test.dart
└── helpers/                    # movie_fixtures.dart, tv_fixtures.dart (shared builders)
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
- **Movie detail** with full-bleed backdrop header, runtime / year / genres chips, top-billed cast (capped at 20), and "More Like This" recommendations. Header renders immediately from a seed backdrop path passed via the route, so navigation lands on the image instead of a spinner.
- **TV shows** on their own tab (Popular / Top Rated / On The Air / Airing Today) with the same search, infinite scroll, and detail layout — season & episode counts replace runtime. Browse + detail only (no favouriting in v1). Movies and TV share one **poster kernel** (`PosterItem` view contract + `PosterGrid`/`PosterCard`/detail cards in `shared/`), so the second vertical reuses the first's UI rather than duplicating it.
- **Favourites** persisted locally via Hive; reactive — toggling on the detail screen updates the home grid heart and the Favourites tab in real time.
- **Shared-element transition** — tapping a favourites card flies its backdrop into the detail header with a corner-radius interpolation (16 → 0). Push only; pop uses the standard route transition (suppressed via `PopScope` so the detail screen exits as a single unit).
- **Profile tab** showing favourites count plus a destructive "Clear favourites" flow with confirm dialog.
- **Responsive grid** — 3 columns on mobile, scaling 4–7 on tablet (clamped on `width / 180`); aspect ratio shifts slightly between tiers.
- **Light & dark mode** — `MaterialApp` is wired with `themeMode: ThemeMode.system`. Theme-dependent surfaces/text live on `AppColors` instances (`AppColors.light` / `AppColors.dark`) and resolve at the call site via `context.colors`; brand and semantic colors stay as static constants.
