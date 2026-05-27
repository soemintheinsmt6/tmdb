import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/error/exceptions.dart';
import 'package:tmdb/core/logging/app_logger.dart';

/// A thin wrapper around [http.Client] that handles common headers,
/// base URL prefixing, TMDB v3 `api_key` auth, error mapping, and transient-
/// failure retries with exponential backoff.
class ApiClient {
  ApiClient({
    http.Client? client,
    AppLogger? logger,
    this.timeout = const Duration(seconds: 20),
    this.maxRetries = 2,
    this.retryBaseDelay = const Duration(milliseconds: 300),
  }) : _client = client ?? http.Client(),
       _logger = logger;

  final http.Client _client;
  final AppLogger? _logger;

  /// Per-request deadline. A request that exceeds it surfaces as a
  /// [NetworkException] via the [TimeoutException] branch in [_executeRequest].
  final Duration timeout;

  /// Number of *additional* attempts after the first for transient failures
  /// (network errors and 5xx). 4xx — including 401 — are never retried.
  final int maxRetries;

  /// Base delay for exponential backoff: attempt _n_ waits `base * 2^(n-1)`.
  final Duration retryBaseDelay;

  Map<String, String> _buildHeaders() {
    return const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Builds a [Uri] with the base URL, the relative [endpoint], optional
  /// [query] params, and the v3 `api_key` query parameter.
  Uri _buildUri(String endpoint, {Map<String, String>? query}) {
    final params = <String, String>{...?query, 'api_key': ApiConstants.apiKey};
    final base = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return base.replace(queryParameters: {...base.queryParameters, ...params});
  }

  // ── GET ────────────────────────────────────────────────
  Future<dynamic> get(String endpoint, {Map<String, String>? query}) {
    // Note: only the endpoint path is logged — never the full Uri, which
    // carries the `api_key` query parameter.
    return _withRetry(endpoint, () async {
      final response = await _executeRequest(
        () => _client.get(
          _buildUri(endpoint, query: query),
          headers: _buildHeaders(),
        ),
      );
      return _handleResponse(response);
    });
  }

  /// Runs [action], retrying on transient failures up to [maxRetries] times
  /// with exponential backoff. Non-transient errors (4xx, parse errors) and a
  /// final exhausted retry rethrow immediately.
  Future<T> _withRetry<T>(String endpoint, Future<T> Function() action) async {
    var attempt = 0;
    while (true) {
      try {
        return await action();
      } on Exception catch (error) {
        attempt++;
        if (attempt > maxRetries || !_isTransient(error)) rethrow;
        final delay = retryBaseDelay * (1 << (attempt - 1));
        _logger?.warning(
          'GET $endpoint failed (attempt $attempt/$maxRetries); '
          'retrying in ${delay.inMilliseconds}ms',
          error: error,
        );
        await Future<void>.delayed(delay);
      }
    }
  }

  bool _isTransient(Object error) =>
      error is NetworkException ||
      (error is ServerException && error.statusCode >= 500);

  // ── Network error wrapper ──────────────────────────────
  Future<http.Response> _executeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(timeout);
    } on SocketException {
      throw const NetworkException(
        message: 'Unable to connect. Please check your network.',
      );
    } on TimeoutException {
      throw const NetworkException(
        message: 'Connection timed out. Please try again.',
      );
    } on http.ClientException {
      throw const NetworkException(
        message: 'Unable to connect. Please check your network.',
      );
    }
  }

  // ── Response handler ──────────────────────────────────
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException(message: _parseErrorBody(response.body));
    }

    throw ServerException(
      message: _parseErrorBody(response.body),
      statusCode: response.statusCode,
    );
  }

  /// TMDB error responses look like:
  /// `{"status_code": 7, "status_message": "Invalid API key", ...}`.
  String _parseErrorBody(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return (json['status_message'] ?? json['message'] ?? body).toString();
    } catch (_) {
      return body;
    }
  }
}
