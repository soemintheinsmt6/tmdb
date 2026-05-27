import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:tmdb/core/config/env.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/logging/app_logger.dart';
import 'package:tmdb/core/network/api_client.dart';

class _MockHttpClient extends Mock implements http.Client {}

/// Counts the warnings the retry path emits.
class _RecordingLogger implements AppLogger {
  int warnings = 0;

  @override
  void debug(String message) {}

  @override
  void info(String message) {}

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace}) =>
      warnings++;

  @override
  void error(String message, {Object? error, StackTrace? stackTrace}) {}
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    registerFallbackValue(Uri.parse('https://example.test'));

    // Serve a fake `.env` to rootBundle so `Env`/`ApiConstants` resolve without
    // the real (gitignored) asset — keeps the test hermetic on CI.
    const envContent = 'BASE_URL=https://example.test\nAPI_KEY=test-key';
    binding.defaultBinaryMessenger.setMockMessageHandler('flutter/assets', (
      message,
    ) async {
      final key = utf8.decode(message!.buffer.asUint8List());
      if (key == '.env') {
        return ByteData.sublistView(
          Uint8List.fromList(utf8.encode(envContent)),
        );
      }
      return null;
    });
    await Env.init();
  });

  late _MockHttpClient http_;
  late _RecordingLogger logger;

  setUp(() {
    http_ = _MockHttpClient();
    logger = _RecordingLogger();
  });

  ApiClient buildClient() => ApiClient(
    client: http_,
    logger: logger,
    maxRetries: 2,
    retryBaseDelay: const Duration(milliseconds: 1),
  );

  group('retry behaviour', () {
    test('retries a 5xx response and succeeds on a later attempt', () async {
      var calls = 0;
      when(() => http_.get(any(), headers: any(named: 'headers'))).thenAnswer((
        _,
      ) async {
        calls++;
        if (calls < 2) return http.Response('{"error":"down"}', 503);
        return http.Response('{"ok":true}', 200);
      });

      final result = await buildClient().get('/movie/popular');

      expect(result, {'ok': true});
      expect(calls, 2);
      expect(logger.warnings, 1); // one retry warning
    });

    test('retries on a network error then succeeds', () async {
      var calls = 0;
      when(() => http_.get(any(), headers: any(named: 'headers'))).thenAnswer((
        _,
      ) async {
        calls++;
        if (calls < 2) throw const SocketException('no network');
        return http.Response('{"ok":true}', 200);
      });

      final result = await buildClient().get('/movie/popular');

      expect(result, {'ok': true});
      expect(calls, 2);
    });

    test(
      'does NOT retry a 401 — fails fast as UnauthorizedException',
      () async {
        var calls = 0;
        when(() => http_.get(any(), headers: any(named: 'headers'))).thenAnswer(
          (_) async {
            calls++;
            return http.Response('{"status_message":"bad key"}', 401);
          },
        );

        await expectLater(
          buildClient().get('/movie/popular'),
          throwsA(isA<UnauthorizedException>()),
        );
        expect(calls, 1);
        expect(logger.warnings, 0);
      },
    );

    test('gives up after maxRetries on a persistent 5xx', () async {
      var calls = 0;
      when(() => http_.get(any(), headers: any(named: 'headers'))).thenAnswer((
        _,
      ) async {
        calls++;
        return http.Response('{"status_message":"down"}', 500);
      });

      await expectLater(
        buildClient().get('/movie/popular'),
        throwsA(isA<ServerException>()),
      );
      expect(calls, 3); // 1 initial + 2 retries
    });
  });
}
