library;

/// Data katmanı exception sınıfları.
/// Repository tarafından yakalanıp Failure'a dönüştürülür.

class DatabaseException implements Exception {
  final String message;
  const DatabaseException([this.message = 'Veritabanı hatası']);

  @override
  String toString() => 'DatabaseException: $message';
}

class AudioException implements Exception {
  final String message;
  const AudioException([this.message = 'Ses hatası']);

  @override
  String toString() => 'AudioException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Kimlik doğrulama hatası']);

  @override
  String toString() => 'AuthException: $message';
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Önbellek hatası']);

  @override
  String toString() => 'CacheException: $message';
}

class StorageException implements Exception {
  final String message;
  const StorageException([this.message = 'Depolama hatası']);

  @override
  String toString() => 'StorageException: $message';
}
