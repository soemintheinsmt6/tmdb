# 0001 — Feature-first Clean Architecture with collapsed use-cases

**Status:** Accepted

## Context

Clean Architecture textbooks prescribe a `UseCase`/`Interactor` class per
operation, sitting between presentation and repositories. For an app this size
(three features, a handful of operations each) that produces a large number of
one-method pass-through classes whose only behaviour is to call a single
repository method — boilerplate with no test or design value.

## Decision

- Organise code **feature-first** (`features/<name>/{data,domain,presentation}`),
  with a shared `core/` and `shared/`.
- **Collapse use-cases.** BLoCs/Cubits depend on the abstract `*Repository`
  directly. The repository is the application-service boundary.
- Keep abstractions only where they earn their keep: as **test seams**
  (`MovieRepository`, `FavouritesRepository`), for **error mapping**
  (`MovieRepositoryImpl._guard`), and for **persistence isolation**
  (`FavouriteMovie` stays in the data layer).

## Consequences

- Less indirection; the call path presentation → repository → data source is
  short and readable.
- The repository interface is the single seam mocked in BLoC/Cubit tests.
- If an operation grows real cross-repository orchestration later, introduce a
  use-case **for that operation only** — the layering already allows it without
  a rewrite.

## Explicitly not adopted

`go_router` (the nav graph is a bottom-nav shell + detail push; `Navigator`
suffices), melos multi-package modularisation, and per-operation use-case
classes. These would add structure without solving a problem this codebase has.
