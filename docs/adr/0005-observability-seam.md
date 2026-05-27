# 0005 — A logging seam instead of a crash-reporting vendor

**Status:** Accepted

## Context

Production readiness implies that failures are *observed*. The obvious move is
to integrate Crashlytics or Sentry. But committing a vendor SDK into a showcase
app adds configuration (DSN/keys, platform setup), a runtime dependency, and
privacy surface — for a project that has no production deployment to report to.
What matters architecturally is that the codebase has a **seam** the vendor can
plug into, and that errors actually flow to it.

## Decision

- Define an `AppLogger` abstraction (`core/logging/app_logger.dart`) with a
  `ConsoleLogger` default that routes through `dart:developer.log` and stays
  quiet for debug/info in release builds.
- Inject it via `get_it`; call sites depend on the abstraction.
- Wire the two global error channels (`FlutterError.onError`,
  `PlatformDispatcher.instance.onError`) into the logger at boot
  (`core/logging/error_reporter.dart`).
- Record every mapped failure in the data layer
  (`MovieRepositoryImpl._guard`) and every transient-failure retry
  (`ApiClient`) through the seam.

## Consequences

- Shipping crash reporting later is a **one-line DI swap**
  (`ConsoleLogger` → a `SentryLogger`/`CrashlyticsLogger`); no call sites change
  and the global handlers pick it up automatically.
- The seam is testable without a vendor: tests assert that failures and retries
  are reported (`movie_repository_impl_test.dart`, `api_client_test.dart`).
- **Security:** the network logger logs only the endpoint path, never the full
  URI, which carries the `api_key` query parameter.
