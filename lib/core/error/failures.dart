import 'package:equatable/equatable.dart';

/// Domain katmanı hata sınıfları.
/// `implements Exception` ile BLoC'taki catch bloklarında yakalanabilir.
abstract class Failure extends Equatable implements Exception {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

/// Veritabanı işlem hatası.
class DatabaseFailure extends Failure {
  const DatabaseFailure([super.message = 'Veritabanı hatası oluştu']);
}

/// Ses çalma hatası.
class AudioFailure extends Failure {
  const AudioFailure([super.message = 'Ses çalınamadı']);
}

/// Genel beklenmeyen hata.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Beklenmeyen bir hata oluştu']);
}

/// Kimlik doğrulama hatası.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Kimlik doğrulama işlemi başarısız']);
}

/// Önbellek hatası.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Önbellek işlemi başarısız']);
}

/// Sunucu / Ağ hatası.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Sunucu bağlantısı başarısız oldu']);
}
