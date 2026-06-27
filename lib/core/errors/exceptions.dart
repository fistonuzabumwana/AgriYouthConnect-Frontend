/// Base exceptions for AgriYouthConnectAI clean architecture bounds.
class ServerException implements Exception {
  final String message;
  const ServerException({this.message = 'Server encountered an error.'});

  @override
  String toString() => 'ServerException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException({this.message = 'Local cache operation failed.'});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network connection failed or timed out.'});

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException({this.message = 'Unauthorized request or session expired.'});

  @override
  String toString() => 'AuthException: $message';
}
