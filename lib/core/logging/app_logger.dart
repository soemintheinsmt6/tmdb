import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Severity of a log record, ordered from least to most severe.
enum LogLevel { debug, info, warning, error }

/// Application-wide logging seam.
///
/// Presentation, data, and core code depend on this abstraction rather than
/// `print` or a vendor SDK directly. Swap [ConsoleLogger] in the DI container
/// for a Crashlytics / Sentry-backed implementation to ship crash reporting —
/// no call sites change.
abstract class AppLogger {
  void debug(String message);

  void info(String message);

  void warning(String message, {Object? error, StackTrace? stackTrace});

  /// Records an error/exception. This is the seam a crash reporter hooks into.
  void error(String message, {Object? error, StackTrace? stackTrace});
}

/// Default implementation. Routes through `dart:developer.log` (visible in the
/// IDE/DevTools logging view) and stays silent for non-error records in release
/// builds to avoid leaking diagnostics into production logs.
class ConsoleLogger implements AppLogger {
  const ConsoleLogger({this.name = 'tmdb'});

  final String name;

  @override
  void debug(String message) => _log(LogLevel.debug, message);

  @override
  void info(String message) => _log(LogLevel.info, message);

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.warning, message, error: error, stackTrace: stackTrace);

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      _log(LogLevel.error, message, error: error, stackTrace: stackTrace);

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    // In release, only surface warnings and errors; debug/info are dev aids.
    if (kReleaseMode && level.index < LogLevel.warning.index) return;
    developer.log(
      message,
      name: '$name.${level.name}',
      level: _severity(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  // Maps to dart:developer levels (loosely the syslog scale).
  int _severity(LogLevel level) => switch (level) {
    LogLevel.debug => 500,
    LogLevel.info => 800,
    LogLevel.warning => 900,
    LogLevel.error => 1000,
  };
}
