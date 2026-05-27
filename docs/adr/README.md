# Architecture Decision Records

Short records of the non-obvious engineering decisions in this project — the
*why* behind choices a reviewer might otherwise read as oversights. Each ADR is
immutable once accepted; a reversal is a new ADR that supersedes the old one.

Format: Status · Context · Decision · Consequences ([Michael Nygard style](https://github.com/joelparkerhenderson/architecture-decision-record)).

| # | Title | Status |
|---|-------|--------|
| [0001](0001-feature-first-clean-architecture.md) | Feature-first Clean Architecture with collapsed use-cases | Accepted |
| [0002](0002-entities-own-their-json.md) | Entities own their `fromJson`; no separate Model classes | Accepted |
| [0003](0003-hive-for-favourites-persistence.md) | Hive for favourites, behind a repository boundary | Accepted |
| [0004](0004-quality-gates-and-curated-lints.md) | CI quality gates + a curated lint set | Accepted |
| [0005](0005-observability-seam.md) | A logging seam instead of a crash-reporting vendor | Accepted |
