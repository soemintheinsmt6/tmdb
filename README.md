# tmdb

A movie browser built on top of [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs/getting-started).

## Tech stack

- **Flutter** (Material 3, light + dark themes that follow the system setting)
- **flutter_bloc** for state management (BLoCs for movies, Cubit for favourites)
- **dartz** `Either<Failure, T>` for error handling
- **equatable** for value objects
- **get_it** for dependency injection
- **http** for networking (wrapped by `core/network/api_client.dart`)
- **objectbox** for local persistence of favourites
- **cached_network_image**, **shimmer**, **iconsax_plus**, **google_fonts** for UI
- **bloc_test**, **mocktail**, **integration_test** for tests

## Architecture

Feature-first with a thin Clean-Architecture split. Each feature owns its `data/`, `domain/`, and `presentation/` layers; abstractions are kept only where they earn their keep (test seams, error mapping, persistence isolation). Use cases were intentionally collapsed — BLoCs depend on the `*Repository` abstract directly.

```
lib/
├── core/
│   ├── config/             # Env (loads .env via rootBundle)
│   ├── constants/          # api_constants.dart (TMDB endpoints + image URLs)
│   ├── error/              # exceptions.dart, failures.dart
│   ├── extensions/         # rating, runtime, year helpers
│   ├── network/            # api_client.dart (api_key auth, exception mapping)
│   ├── responsive/         # breakpoints + ResponsiveBuilder
│   ├── storage/            # ObjectBox wrapper (favourites store)
│   ├── theme/              # AppColors, AppTypography, AppTheme, AppDecoration
│   └── utils/              # navigation.dart, typedef.dart
├── features/
│   ├── movies/
│   │   ├── data/
│   │   │   ├── datasources/    # MovieRemoteDataSource (concrete, wraps ApiClient)
│   │   │   └── repositories/   # MovieRepositoryImpl (composition + Failure mapping)
│   │   ├── domain/
│   │   │   ├── entities/       # Movie, MovieDetail, Genre, CastMember, PaginatedMovies
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
│   │       └── widgets/        # MoviePoster, MovieCard, RatingBadge, …
│   ├── favourites/
│   │   ├── data/
│   │   │   ├── models/         # FavouriteMovie (ObjectBox @Entity, persistence-only)
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
├── shared/widgets/             # AppSearchField, AppErrorView, AppEmptyView, RootScreen
├── injection_container.dart    # GetIt registrations
├── app.dart                    # MaterialApp + global providers
└── main.dart                   # boot: Env.init → di.init → runApp
```

**Error flow.** `ApiClient` throws `UnauthorizedException` / `ServerException` / `NetworkException`. `MovieRepositoryImpl._guard` converts them to `ServerFailure` (with the original status code, or 401 for unauthorised) / `NetworkFailure`. BLoCs `fold` the `Either<Failure, T>` into success / error states.

**Persistence boundary.** `FavouriteMovie` (ObjectBox `@Entity`) lives only in the favourites data layer. The repository converts to `Movie` at the boundary, so widgets and the cubit only see domain types.

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

The project has three test layers; together they're 121 host-side tests + one device E2E.

```bash
flutter analyze                # static analysis
flutter test                   # unit + widget + screen-integration tests
```

Test layout mirrors `lib/`:

```
test/
├── core/                       # extensions, breakpoints, URL helpers, Failure
├── features/
│   ├── movies/
│   │   ├── data/               # repository impl, remote data source
│   │   ├── domain/entities/    # fromJson, copyWith, computed props
│   │   └── presentation/bloc/  # MovieList, MovieSearch, MovieDetail blocs
│   └── favourites/
│       ├── data/models/        # FavouriteMovie mapper
│       └── presentation/cubit/ # FavouritesState, FavouritesCubit
├── integration/                # screen-level: real bloc + real widgets + mocked repo
│   ├── home_content_test.dart
│   └── favourite_screen_test.dart
└── helpers/movie_fixtures.dart # shared builders
```

### End-to-end (`integration_test`)

A full-app smoke test boots the real `App`, swaps `ApiClient` for a deterministic fake (lazy-singleton swap via `GetIt`), and drives a complete user journey: home loads → switch tab → open detail → favourite → switch to favourites tab and verify. ObjectBox runs for real, so the test must execute on a device, simulator, or desktop — not via `flutter test`.

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
- **Movie detail** with backdrop hero, runtime / year / genres chips, top-billed cast (capped at 20), and "More Like This" recommendations.
- **Favourites** persisted locally via ObjectBox; reactive — toggling on the detail screen updates the home grid heart and the Favourites tab in real time.
- **Profile tab** showing favourites count plus a destructive "Clear favourites" flow with confirm dialog.
- **Responsive grid** — 3 columns on mobile, scaling 4–7 on tablet (clamped on `width / 180`); aspect ratio shifts slightly between tiers.
- **Light & dark mode** — `MaterialApp` is wired with `themeMode: ThemeMode.system`. Theme-dependent surfaces/text live on `AppColors` instances (`AppColors.light` / `AppColors.dark`) and resolve at the call site via `context.colors`; brand and semantic colors stay as static constants.
