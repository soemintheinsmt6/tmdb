import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

enum Flavor { dev, staging, prod }

class Env {
  Env._();

  static Flavor _flavor = Flavor.dev;
  static final Map<String, String> _values = {};

  static Flavor get flavor => _flavor;

  static Future<void> init({Flavor flavor = Flavor.dev}) async {
    _flavor = flavor;
    final raw = await rootBundle.loadString(_fileFor(flavor));
    _values
      ..clear()
      ..addAll(_parse(raw));
  }

  static Map<String, String> _parse(String raw) {
    final out = <String, String>{};
    for (final line in const LineSplitter().convert(raw)) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      final key = trimmed.substring(0, eq).trim();
      var value = trimmed.substring(eq + 1).trim();
      if ((value.startsWith('"') && value.endsWith('"')) ||
          (value.startsWith("'") && value.endsWith("'"))) {
        value = value.substring(1, value.length - 1);
      }
      out[key] = value;
    }
    return out;
  }

  static String _fileFor(Flavor flavor) {
    switch (flavor) {
      case Flavor.dev:
        return '.env';
      case Flavor.staging:
        return '.env.staging';
      case Flavor.prod:
        return '.env.prod';
    }
  }

  static String _required(String key) {
    final value = _values[key];
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing required env var "$key" in ${_fileFor(_flavor)}',
      );
    }
    return value;
  }

  static String get baseUrl => _required('BASE_URL');
  static String get apiKey => _required('API_KEY');
}
