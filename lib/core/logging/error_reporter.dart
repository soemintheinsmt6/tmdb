import 'package:flutter/foundation.dart';

import 'package:tmdb/core/logging/app_logger.dart';

/// Wires Flutter's two global error channels into [logger] so uncaught
/// framework and platform errors are recorded through the same seam as
/// everything else. Call once during boot, before `runApp`.
///
/// A crash reporter (Crashlytics/Sentry) plugs in by swapping the [AppLogger]
/// implementation — these handlers do not change.
void installGlobalErrorHandlers(AppLogger logger) {
  // Errors thrown inside the Flutter framework (build/layout/paint, etc.).
  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    logger.error(
      'FlutterError: ${details.exceptionAsString()}',
      error: details.exception,
      stackTrace: details.stack,
    );
    previousOnError?.call(details);
  };

  // Uncaught errors from the underlying platform / async gaps.
  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('Uncaught platform error', error: error, stackTrace: stack);
    return true; // handled — keep the app alive.
  };
}
