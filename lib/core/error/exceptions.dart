/// Thrown when a server-side error occurs (status code >= 400).
class ServerException implements Exception {
  const ServerException({required this.message, required this.statusCode});

  final String message;
  final int statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown when the server responds with 401 (token expired / invalid).
class UnauthorizedException implements Exception {
  const UnauthorizedException({
    this.message = 'Authentication failed. Check your TMDB API token.',
  });

  final String message;

  @override
  String toString() => 'UnauthorizedException: $message';
}

/// Thrown when a network-level error occurs (no internet, timeout, etc.).
class NetworkException implements Exception {
  const NetworkException({required this.message});

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}
