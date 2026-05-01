# tmdb

A movie browser built on top of [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs/getting-started).

## Tech stack

- **Flutter** (Material 3, light + dark themes that follow the system setting)
- **flutter_bloc** for state management
- **dartz** `Either<Failure, T>` for error handling
- **equatable** for value objects
- **get_it** for dependency injection
- **http** for networking (wrapped by `core/network/api_client.dart`)
- **cached_network_image**, **shimmer**, **iconsax_plus**, **google_fonts** for UI

## Architecture

Clean Architecture + Feature-first

```
lib/
├── core/
│   ├── constants/         # api_constants.dart (TMDB endpoints)
│   ├── error/             # exceptions.dart, failures.dart
│   ├── extensions/        # rating, runtime, year helpers
│   ├── network/           # api_client.dart (Bearer or api_key auth)
│   ├── responsive/        # breakpoints + ResponsiveBuilder
│   ├── theme/             # AppColors, AppTypography, AppTheme, AppDecoration
│   └── utils/             # navigation.dart, typedef.dart
├── features/
│   └── movies/
│       ├── data/
│       │   ├── models/        # Movie, MovieDetail, Genre, CastMember, PaginatedMovies
│       │   └── repositories/  # MovieRepository (abstract) + impl
│       └── presentation/
│           ├── bloc/
│           │   ├── movie_list_bloc/   # Popular / Now Playing / Top Rated / Upcoming
│           │   ├── movie_search_bloc/ # debounced search
│           │   └── movie_detail_bloc/ # /movie/{id} + credits + recommendations
│           ├── screens/
│           │   ├── home/{home_screen.dart, layouts/}
│           │   └── movie_detail/{movie_detail_screen.dart, layouts/}
│           └── widgets/        # MoviePoster, MovieCard, RatingBadge, …
├── shared/widgets/             # AppSearchField, AppErrorView, AppEmptyView
├── injection_container.dart    # GetIt registrations
├── app.dart
└── main.dart
```

Each repository catches `ServerException` / `NetworkException` thrown by `ApiClient` and returns `Left(ServerFailure)` / `Left(NetworkFailure)`. BLoCs `fold` the result into success / failure states.

## Running the app

Then:

```bash
flutter pub get
```

For analyze / tests:

```bash
flutter analyze
flutter test
```

## Features

- **Browse** Popular, Now Playing, Top Rated, Upcoming with horizontal tab switcher.
- **Search** with 400 ms debounce; falls back to category browse when cleared.
- **Infinite scroll** + pull-to-refresh on the category grid.
- **Movie detail** with backdrop hero, runtime / year / genres chips, top-billed cast, and "More Like This" recommendations.
- **Responsive grid** — 2 columns on mobile, 4 on tablet (the only two tiers we target).
- **Light & dark mode** — `MaterialApp` is wired with `themeMode: ThemeMode.system`, so the UI flips with the OS. Theme-dependent surfaces/text live on `AppColors` instances (`AppColors.light` / `AppColors.dark`) and resolve at the call site via `context.colors`; brand and semantic colors stay as static constants.
