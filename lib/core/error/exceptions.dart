class CacheExceptionVer1Ne implements Exception {
  const CacheExceptionVer1Ne([this.message]);

  final String? message;

  @override
  String toString() => 'CacheException: ${message ?? 'Unknown cache error'}';
}

class DatabaseExceptionVer1Ne implements Exception {
  const DatabaseExceptionVer1Ne([this.message]);

  final String? message;

  @override
  String toString() => 'DatabaseException: ${message ?? 'Unknown database error'}';
}

class NetworkExceptionVer1Ne implements Exception {
  const NetworkExceptionVer1Ne([this.message]);

  final String? message;

  @override
  String toString() => 'NetworkException: ${message ?? 'Unknown network error'}';
}
