import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:tmdb/core/constants/api_constants.dart';
import 'package:tmdb/core/error/exceptions.dart';

/// A thin wrapper around [http.Client] that handles common headers,
/// base URL prefixing, TMDB v3 `api_key` auth, and error mapping.
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Map<String, String> _buildHeaders() {
    return const {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Builds a [Uri] with the base URL, the relative [endpoint], optional
  /// [query] params, and the v3 `api_key` query parameter.
  Uri _buildUri(String endpoint, {Map<String, String>? query}) {
    final params = <String, String>{
      ...?query,
      'api_key': ApiConstants.apiKey,
    };
    final base = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    return base.replace(queryParameters: {
      ...base.queryParameters,
      ...params,
    });
  }

  // ── GET ────────────────────────────────────────────────
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? query,
  }) async {
    final response = await _executeRequest(
      () => _client.get(_buildUri(endpoint, query: query), headers: _buildHeaders()),
    );
    return _handleResponse(response);
  }

  // ── Network error wrapper ──────────────────────────────
  Future<http.Response> _executeRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request();
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
