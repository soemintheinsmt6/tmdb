# 0003 — Hive for favourites, behind a repository boundary

**Status:** Accepted (supersedes an earlier ObjectBox implementation)

## Context

Favourites need local persistence that survives restarts and updates the UI
reactively. The project initially used ObjectBox, which pulls native binaries
into the build and adds a code-generation step. For a single small box keyed by
movie id, that is more machinery than the problem needs.

## Decision

- Persist favourites with **Hive** (`hive`/`hive_flutter`), a single typed box
  keyed by `movie.id`.
- Use a **hand-written `TypeAdapter`** (`FavouriteMovieAdapter`) — no codegen,
  consistent with [0002](0002-entities-own-their-json.md).
- Keep the persistence type (`FavouriteMovie`) **inside the data layer**. The
  repository converts to/from the domain `Movie` at the boundary, so the cubit
  and widgets only ever see domain types.
- Expose reactivity as a `Stream<List<Movie>>` (`watchAll`) built on
  `Box.watch()`, plus a synchronous `getAll()` to seed initial cubit state
  without a frame of empty UI.

## Consequences

- No native build artifacts or generated files; simpler `pubspec` and CI.
- Persistence is swappable: only `FavouritesRepositoryImpl` and
  `HiveStorage` know about Hive.
- Hive's real box requires a device/desktop, so the full round-trip is covered
  by the on-device E2E smoke test rather than `flutter test`; the repository
  contract is unit-tested against a mock in the cubit/integration tests.
- Write methods (`toggle`/`remove`/`clear`) return `Future<void>` and the
  awaited box op is propagated, so a failed write surfaces rather than being
  swallowed.
