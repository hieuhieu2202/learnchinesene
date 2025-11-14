class CacheException implements Exception {
  const CacheException([this.message]);

  final String? message;

  @override
  String toString() => 'CacheException: ${message ?? 'Unknown cache error'}';
}

class DatabaseException implements Exception {
  const DatabaseException([this.message]);

  final String? message;

  @override
  String toString() => 'DatabaseException: ${message ?? 'Unknown database error'}';
}

class NetworkException implements Exception {
  const NetworkException([this.message]);

  final String? message;

  @override
  String toString() => 'NetworkException: ${message ?? 'Unknown network error'}';
}
