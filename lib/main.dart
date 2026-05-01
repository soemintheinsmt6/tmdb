import 'package:flutter/material.dart';
import 'package:tmdb/app.dart';
import 'package:tmdb/core/config/env.dart';
import 'package:tmdb/injection_container.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Env.init(flavor: Flavor.dev);
  await di.init();

  runApp(const App());
}
