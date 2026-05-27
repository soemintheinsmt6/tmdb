# 0002 — Entities own their `fromJson`; no separate Model classes

**Status:** Accepted

## Context

The common Clean Architecture pattern keeps a `Model` (with JSON
serialisation) in the data layer, separate from a pure domain `Entity`, and
maps between them. That separation pays off when the wire format and the domain
shape diverge, or when serialisation pulls in heavy dependencies.

Here, the TMDB payloads map almost directly to what the UI needs, and the
serialisation is hand-written (no `json_serializable`/`freezed` codegen), so a
parallel Model hierarchy would be duplication.

## Decision

- Domain **entities own their `fromJson`** (`Movie`, `MovieDetail`, `Genre`,
  `CastMember`, `PaginatedMovies`). No separate data-layer Model class for the
  movies feature.
- The **one** place a persistence-shaped type is justified — the Hive row —
  stays in the data layer as `FavouriteMovie` (see [0003](0003-hive-for-favourites-persistence.md)),
  and is mapped to/from `Movie` at the repository boundary.

## Consequences

- One type per concept; parsing logic lives next to the shape it produces and
  is unit-tested directly (`movie_test.dart`, `movie_detail_test.dart`).
- The domain layer technically knows the JSON shape. Accepted trade-off: the
  app is API-bound and there is no second data source to insulate against.
- No build-runner/codegen step in the toolchain.

## Revisit if

A second data source (e.g. a different API or a cache with a different shape)
appears, or serialisation grows complex enough to warrant codegen.
