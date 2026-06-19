# tmdb

A movie & TV browser built on top of [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs/getting-started).

## Tech stack

- **Flutter** (Material 3, user-selectable light / dark / system theme)
- **flutter_bloc** for state management (BLoCs for the editorial home, movies, TV, discover & search; Cubits for favourites & watchlist)
- **dartz** `Either<Failure, T>` for error handling
- **equatable** for value objects
- **get_it** for dependency injection
- **http** for networking (wrapped by `core/network/api_client.dart`)
- **hive** for local persistence of favourites, watchlist & settings (theme + Library prefs)
- **cached_network_image**, **shimmer**, **iconsax_plus**, **google_fonts** for UI
- **youtube_player_flutter** (in-app trailers) · **url_launcher** ("Watch on YouTube" fallback · IMDb & JustWatch deep links) · **saver_gallery** (save backdrops to the device gallery) · **share_plus** (system share sheet)
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
│   ├── extensions/         # rating, runtime, year, date helpers
│   ├── logging/            # AppLogger seam + ConsoleLogger + global error handlers
│   ├── network/            # api_client.dart (api_key auth, retry/backoff, exception mapping)
│   ├── responsive/         # breakpoints + ResponsiveBuilder
│   ├── sharing/            # media_share.dart (TMDB link + backdrop → share sheet)
│   ├── storage/            # Hive wrapper (favourite movie/TV + watchlist + settings boxes)
│   ├── theme/              # AppColors, AppTypography, AppTheme, AppDecoration
│   └── utils/              # navigation.dart, typedef.dart, region.dart (device ISO region)
├── features/
│   ├── home/                   # Editorial landing tab. Trending data source + repo
│   │                           # (/trending/all + /trending/tv → PosterItem) and HomeBloc,
│   │                           # which aggregates trending (hero carousel), For You, Now
│   │                           # Playing, Top Rated, Upcoming & Popular Series rails
│   │                           # (best-effort; subscribes to favourites/watchlist for live
│   │                           # For You). home_screen + content; each rail's "See all" → grid.
│   ├── movies/
│   │   ├── data/
│   │   │   ├── datasources/    # MovieRemoteDataSource (concrete, wraps ApiClient)
│   │   │   └── repositories/   # MovieRepositoryImpl (composition + Failure mapping)
│   │   ├── domain/
│   │   │   ├── entities/       # Movie (implements PosterItem), MovieDetail (+ MovieCollection /
│   │   │   │                   # MovieCollectionRef), PaginatedMovies — entities own their
│   │   │   │                   # fromJson; no separate Model class
│   │   │   └── repositories/   # MovieRepository (abstract — test seam)
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── movie_list_bloc/    # Popular / Now Playing / Top Rated / Upcoming
│   │       │   │                       #   — powers the "See all" category grids
│   │       │   ├── movie_search_bloc/  # per-vertical debounced search (superseded by global)
│   │       │   ├── movie_detail_bloc/  # /movie/{id} (+ imdb_id, belongs_to_collection) +
│   │       │   │                       #   credits + recs + videos + reviews + images + watch
│   │       │   │                       #   providers (one parallel fetch, merged via copyWith)
│   │       │   └── collection_bloc/    # /collection/{id} — franchise parts, lazy on banner tap
│   │       ├── screens/
│   │       │   ├── movie_category_screen.dart  # full grid for one category ("See all")
│   │       │   ├── movie_detail/{movie_detail_screen.dart, layouts/}
│   │       │   └── collection/collection_screen.dart  # franchise films (hero from banner)
│   │       └── widgets/        # movie_detail_cards, CollectionBanner, CollectionSkeleton
│   ├── tv/                     # Series vertical, mirrors movies: TvShow (implements
│   │                           # PosterItem), TvShowDetail (+ Season / Episode / SeasonDetail),
│   │                           # TvRepository, remote data source. TvFeedBloc drives the
│   │                           # editorial Series tab (trending-TV hero + Popular / Top Rated /
│   │                           # On The Air / Airing Today rails); tv_list_bloc powers the
│   │                           # "See all" grids, tv_detail_bloc the detail (fan-out also pulls
│   │                           # watch providers + /external_ids for imdb_id), season_detail_bloc
│   │                           # the per-season episode list. tv_category_screen + tv_detail +
│   │                           # season screen; TV detail is saveable to favourites & watchlist.
│   ├── discover/               # /discover/{movie,tv} browse with a Movies/TV toggle:
│   │                           # DiscoverFilter (mediaType + genres/sort/year/min-rating →
│   │                           # per-vertical query params), DiscoverRepository, remote data
│   │                           # source, DiscoverBloc (flat state: genres + filter +
│   │                           # PosterItem results + pagination), discover_screen (toggle +
│   │                           # removable filter chips) + filter sheet. Its own tab; also
│   │                           # hosts the global multi-search (search icon → SearchScreen).
│   ├── search/                 # Global search with an All / Movies / TV / People filter that
│   │                           # routes to /search/{multi,movie,tv,person} — SearchBloc (query +
│   │                           # filter + pagination), search_screen + content; opened from the
│   │                           # Home, Series & Discover app-bar search icons.
│   ├── recommendations/        # "For You" engine: RecommendationsRepository.getForYou(seeds)
│   │                           # fans out /movie|tv recommendations over the user's recent
│   │                           # favourites + watchlist, ranks by cross-seed frequency, and
│   │                           # drops already-saved titles. Consumed by HomeBloc.
│   ├── people/                 # Person (detail) + PersonCredit (implements PosterItem),
│   │                           # PersonRepository, remote data source (/person/{id} +
│   │                           # /person/{id}/combined_credits), person_detail bloc, and
│   │                           # person_detail screen (one width-adaptive layout — no
│   │                           # backdrop). Reached by tapping a cast tile on any movie/TV
│   │                           # detail; filmography posters route back into movie/TV detail.
│   ├── favourites/
│   │   ├── data/
│   │   │   ├── models/         # FavouriteMovie (typeId 1) + FavouriteTvShow (typeId 3)
│   │   │   │                   #   — hand-written Hive TypeAdapters, persistence-only
│   │   │   └── repositories/   # FavouritesRepositoryImpl (merges both boxes → FavouriteItem)
│   │   ├── domain/
│   │   │   ├── entities/       # FavouriteItem (MediaType movie|tv, implements PosterItem)
│   │   │   └── repositories/   # FavouritesRepository (abstract — test seam)
│   │   └── presentation/
│   │       ├── cubit/          # FavouritesCubit + FavouritesState({items, keys})
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
│   │       ├── screens/        # LibraryScreen (Favourites + Watchlist tabs; sort + list/grid,
│   │       │                   #   persisted via SettingsRepository)
│   │       └── widgets/        # LibrarySortSheet (sort-order bottom sheet)
│   ├── profile/
│   │   └── presentation/
│   │       ├── screens/        # ProfileScreen (favourite count · Appearance theme picker ·
│   │       │                   #   clear favourites / watchlist · about)
│   │       └── widgets/        # ProfileHeader, SettingsTile
│   └── settings/               # App preferences: SettingsRepository (Hive-backed) + ThemeCubit
│                               # (System/Light/Dark, app-wide above MaterialApp) + theme-picker
│                               # sheet. Also persists the Library sort + view.
├── shared/
│   ├── domain/                 # PosterItem (poster + backdrop view contract), MediaType,
│   │                           # LibrarySort + SortableSavedItem (ordering), LibraryView,
│   │                           # Genre, CastMember, Video, Review, MediaImage, ShareableMedia,
│   │                           # WatchProvider + WatchProviders
│   └── widgets/                # Poster kernel shared by movies + TV — PosterGrid,
│                               # PosterCard, PosterImage, RatingBadge, PosterGridSkeleton,
│                               # SectionedPosterGrid (Library movie/TV split), CategoryTabBar,
│                               # detail_cards (DetailHeader/Summary/CastList/PosterRail/
│                               # VideoRail/ReviewsSection/ImageGallery), WatchProvidersSection +
│                               # ImdbChip (detail), the editorial FeaturedHero + FeaturedCarousel
│                               # (auto-sliding trending hero) and RailFeedSkeleton/DetailSkeleton
│                               # shimmer loaders — plus TrailerPlayerScreen, ImageGalleryViewer,
│                               # AppSearchField, ShareButton, AppErrorView, AppEmptyView,
│                               # RootScreen (5-tab shell)
├── injection_container.dart    # GetIt registrations
├── app.dart                    # MaterialApp + global providers
└── main.dart                   # boot: Env.init → di.init → runApp
```

**Error flow.** `ApiClient` applies a per-request timeout and retries transient failures (network errors + 5xx) with exponential backoff before throwing `UnauthorizedException` / `ServerException` / `NetworkException`; 4xx (incl. 401) fail fast. `MovieRepositoryImpl._guard` converts them to `ServerFailure` (with the original status code, or 401 for unauthorised) / `NetworkFailure`, logging each mapped failure through the `AppLogger` seam. BLoCs `fold` the `Either<Failure, T>` into success / error states.

**Observability.** Code logs through the injected `AppLogger` abstraction, never `print`. The default `ConsoleLogger` routes to `dart:developer`; global Flutter/platform errors are funnelled in at boot. Shipping a crash reporter is a one-line DI swap — see [ADR 0005](docs/adr/0005-observability-seam.md). The network logger logs endpoint paths only, never the `api_key`-bearing URL.

**Persistence boundary.** The Hive row types (`FavouriteMovie` / `FavouriteTvShow` and `WatchlistEntry` — hand-written `TypeAdapter`s, type ids `1`, `3`, `2`) live only in their feature data layers. The repositories convert to domain types (`FavouriteItem` / `WatchlistItem`) at the boundary, so widgets and cubits never see the persistence rows. Both stores span movies and TV: the watchlist uses one box keyed `"movie:ID"` / `"tv:ID"`; favourites keeps two type-specific boxes (movies keep their original box untouched) and merges them. Either way, membership is checked by `(mediaType, id)` — numeric ids can collide across the two verticals, so the type is always part of the key. A fourth, untyped `settings` box stores primitive preferences (theme mode, Library sort/view) by key as enum indices — no `TypeAdapter`, so no type id is consumed.

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

4. Enable the git hooks so staged Dart files are auto-formatted
   before each commit — this keeps the CI formatting gate from ever failing:

   ```bash
   git config core.hooksPath .githooks
   ```

   The hook lives in [`.githooks/pre-commit`](.githooks/pre-commit) and runs
   `dart format` on staged `*.dart` files, re-staging anything it touches.

## Tests

The project has three test layers; together they're 362 host-side tests + one device E2E.

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
├── core/                       # extensions, breakpoints, URL helpers, Failure, ApiClient retry,
│                               # share links (TMDB URL + message)
├── features/
│   ├── home/                   # HomeBloc (rail aggregation, best-effort, live For You)
│   ├── movies/
│   │   ├── data/               # repository impl (+ getCollection), remote data source
│   │   ├── domain/entities/    # fromJson, copyWith, computed props (+ MovieCollection)
│   │   └── presentation/bloc/  # MovieList, MovieSearch, MovieDetail, Collection blocs
│   ├── tv/                     # mirrors movies: entities (+ SeasonDetail), data,
│   │                           # TvList/TvSearch/TvDetail/SeasonDetail/TvFeed blocs, EpisodeTile
│   ├── discover/               # DiscoverFilter (movie+TV), remote data source, repo impl, DiscoverBloc
│   ├── people/                 # PersonCredit/Person entities, data (datasource + repo),
│   │                           # PersonDetail bloc
│   ├── recommendations/        # RecommendationsRepository ranking / dedupe / exclusion
│   ├── favourites/
│   │   ├── data/models/        # FavouriteMovie + FavouriteTvShow mappers
│   │   └── presentation/cubit/ # FavouritesState, FavouritesCubit
│   ├── watchlist/
│   │   ├── data/models/        # WatchlistEntry round-trip (incl. movie/TV id-collision)
│   │   └── presentation/cubit/ # WatchlistState, WatchlistCubit
│   └── settings/               # ThemeCubit (seed from repo, emit + persist on change)
├── shared/
│   ├── domain/                 # Video/Review/MediaImage/WatchProviders entities, LibrarySort
│   │                           # comparators
│   └── widgets/                # WatchProvidersSection, ImdbChip, season skeleton
├── integration/                # screen-level: real bloc + real widgets + mocked repo
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

- **Editorial home** — a trending **hero carousel** (auto-advancing, seamless loop, page-indicator dots) over curated rails: **For You**, Now Playing, Top Rated, Upcoming, and Popular Series. Each rail's **See all** opens a full, infinite-scroll category grid.
- **For You** — personalised recommendations seeded from your recent favourites & watchlist, ranked by how many of them recommend each title and de-duplicated against everything you've already saved; refreshes live as you save/unsave.
- **Global search** (movies + TV + people) with 400 ms debounce and an **All / Movies / TV / People** filter — each scope routes to its own `/search/{multi,movie,tv,person}` endpoint so every type paginates in full. Reachable from the Home, Series & Discover app bars.
- **Infinite scroll** + pull-to-refresh on the "See all" category and Discover grids.
- **Movie detail** with full-bleed backdrop header, runtime / year / genres chips, top-billed cast (capped at 20, each face tappable → person page), a **trailers & clips** rail, a **photos** gallery, **More Like This** recommendations, and **user reviews**. The detail, credits, recommendations, videos, reviews and images are fetched in one parallel request and merged. The header renders immediately from a seed backdrop passed via the route, and the rest of the page loads behind a **shimmer skeleton** that mirrors the layout — so navigation lands on the image, not a spinner.
- **Discover & filters** — a dedicated tab over `/discover/movie` and `/discover/tv` with a **Movies / TV toggle**: filter by genre, sort order, release year, and minimum rating in a bottom sheet; active filters surface as **removable chips** and results infinite-scroll. A search icon opens the global multi-search.
- **Trailers** — tapping a video opens an in-app YouTube player (`youtube_player_flutter`) with a custom control bar: red scrubber, tap to play/pause, **double-tap left/right to seek ±10 s**, and a fullscreen toggle that rotates to landscape. Owner-disabled / region- or age-restricted videos fall back to a "Watch on YouTube" action.
- **Photos** — a backdrop gallery on movie & TV detail opens a full-screen viewer: swipe between images, pinch-zoom, **double-tap to zoom** (centred on the tap), and **save to the device gallery** (`saver_gallery`, with photo-library permission handling on iOS & Android).
- **Reviews** — author, score, and expandable review text on movie & TV detail.
- **Share** — a share action on movie & TV detail opens the native share sheet (`share_plus`) with the title, year, and canonical TMDB link, best-effort attaching the backdrop image (fetched with a timeout; falls back to text + link).
- **Where to watch** — movie & TV detail show **stream / rent / buy** provider logos (TMDB's JustWatch data) for your device region, sourced via `/watch/providers` in the same parallel detail fetch. JustWatch attribution links to the full TMDB watch page; when your region isn't covered the section falls back to **US** and labels which region is shown (hidden entirely when there's no data anywhere).
- **IMDb** — when a title has an IMDb id (movies carry it directly; TV resolves it via `/external_ids`), a gold **IMDb** button in the detail meta row deep-links to its IMDb page.
- **Collections / franchises** — when a movie is part of a franchise (`belongs_to_collection`, already in the detail payload), a "Part of the … Collection" banner sits under the overview. Tapping it flies the backdrop into a collection screen (shared-element hero, seeded so the target is on-screen while it loads) that lazily fetches `/collection/{id}` and lists every film in release order behind a dedicated shimmer — each routing back to movie detail.
- **TV shows** on their own **Series** tab — a trending-TV **hero carousel** over Popular / Top Rated / On The Air / Airing Today rails (each with See all), sharing the detail layout where season & episode counts replace runtime. A **Seasons** rail on TV detail opens each season's **episode list** (`/tv/{id}/season/{n}` — stills, air dates, ratings, overviews) behind a shimmer skeleton. TV detail pages are saveable to favourites and the watchlist. Movies and TV share one **poster kernel** (`PosterItem` view contract + `PosterGrid`/`PosterCard`/`FeaturedCarousel`/detail cards in `shared/`), so the second vertical reuses the first's UI rather than duplicating it.
- **People / cast** — tap any cast member to open a person page with their profile photo, known-for department, birthday / age / birthplace, an expandable biography, and a combined movie + TV **filmography** (sorted by popularity) whose posters route back into the matching movie or TV detail. Reuses the same poster kernel as the browse grids.
- **Favourites** spanning **both movies and TV shows**, persisted locally via Hive; reactive — toggling the heart on any movie or TV detail screen updates the Library tab in real time.
- **Watchlist** — a separate "watch later" list spanning **both movies and TV shows**, persisted locally via Hive and reactive like favourites. A bookmark toggle on movie & TV detail saves/removes; each saved card carries a MOVIE/TV chip and routes back to the matching detail screen.
- **Shared-element transition** — tapping a trending hero slide, a favourites/watchlist card, or a movie's collection banner flies its backdrop into the destination header with a corner-radius interpolation (16 → 0), on **both push and pop**. The detail route pops normally, so the iOS edge-swipe-back gesture works alongside the hero flight.
- **Profile tab** showing favourites count, an **Appearance** picker (System / Light / Dark), and destructive "Clear favourites" / "Clear watchlist" flows with confirm dialogs.
- **Five-tab shell** — Home · Discover · TV · Library · Profile, lazily built and kept alive via `IndexedStack`. The **Library** tab combines Favourites and Watchlist under one app bar with two segments, plus shared **sort** (recently added · title A–Z · top rated · release date) and **list/grid view** controls that reorder and re-lay-out both segments — in grid view each segment is split into **Movies** and **TV Shows** sections (`SectionedPosterGrid`). Both the sort and the view are **persisted** across launches.
- **Skeleton loading** — Home, Series, Discover, Library, Search, and the movie/TV detail pages load behind shimmer skeletons that mirror their real layouts (no spinners, no layout shift).
- **Responsive grid** — 3 columns on mobile, scaling 4–7 on tablet (clamped on `width / 180`); aspect ratio shifts slightly between tiers.
- **Light & dark mode** — user-selectable **System / Light / Dark** via a `ThemeCubit` that drives `MaterialApp.themeMode` and **persists** the choice (Hive `settings` box), changed from the Profile tab's Appearance picker. Theme-dependent surfaces/text live on `AppColors` instances (`AppColors.light` / `AppColors.dark`) and resolve at the call site via `context.colors`; brand and semantic colors stay as static constants.
