import 'package:flutter_dotenv/flutter_dotenv.dart';

enum Flavor { dev, staging, prod }

class Env {
  Env._();

  static Flavor _flavor = Flavor.dev;
  static Flavor get flavor => _flavor;

  static Future<void> init({Flavor flavor = Flavor.dev}) async {
    _flavor = flavor;
    await dotenv.load(fileName: _fileFor(flavor));
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
    final value = dotenv.env[key];
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
