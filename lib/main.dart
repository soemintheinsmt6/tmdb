import 'package:flutter/material.dart';
import 'package:tmdb/app.dart';
import 'package:tmdb/core/config/env.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/logging/error_reporter.dart';
import 'package:tmdb/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.init(flavor: Flavor.dev);
  await di.init();

  // Route uncaught framework/platform errors through the logging seam.
  installGlobalErrorHandlers(di.sl<AppLogger>());

  runApp(const App());
}
