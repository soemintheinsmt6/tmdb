# 0004 — CI quality gates + a curated lint set

**Status:** Accepted

## Context

A portfolio/enterprise-grade codebase needs its quality bar enforced
automatically, not by convention. Two levers: continuous integration and static
analysis. For lints, the options were the default `flutter_lints`, an
everything-on package (e.g. `very_good_analysis`), or a curated set. A maximal
ruleset generates churn and noise (e.g. forcing explicit-default arguments out
of tests) that obscures the high-signal rules.

## Decision

- **CI** (`.github/workflows/ci.yml`) runs on every push/PR to `master`:
  `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test
  --coverage`, with the coverage report uploaded as an artifact. Concurrency
  cancels superseded runs.
- **Lints**: build on `flutter_lints` and add a *curated* set in
  `analysis_options.yaml`, grouped by intent (async correctness, const/
  immutability, clarity, safety). Enable analyzer `strict-casts` and
  `strict-raw-types`, and promote `unawaited_futures` to an **error**.
- Rules that fought the codebase's intentional style were deliberately left
  out: `avoid_redundant_argument_values` (tests pass defaults for readability)
  and `sort_pub_dependencies` (deps are grouped by purpose with comments).

## Consequences

- `unawaited_futures`/`discarded_futures` caught real fire-and-forget async
  (the favourites write and a navigation push) and forced an explicit decision
  at each site.
- The bar is reproducible locally: the three CI commands are the same ones a
  developer runs.
- Adding a rule is a deliberate act with a rationale, not an import.
