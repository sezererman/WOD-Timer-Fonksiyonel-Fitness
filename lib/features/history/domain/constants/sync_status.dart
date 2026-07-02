/// Senkronizasyon durumu sabitleri.
///
/// Magic string kullanımını önlemek için tüm sync status değerleri
/// bu merkezi sınıfta tanımlanmıştır.
abstract final class SyncStatus {
  /// Henüz Supabase'e gönderilmemiş, yerel Hive kaydı.
  static const String pending = 'pending';

  /// Başarıyla Supabase'e gönderilmiş kayıt.
  static const String synced = 'synced';

  /// Gönderim sırasında hata oluşan kayıt — bir sonraki sync döngüsünde tekrar denenecek.
  static const String failed = 'failed';
}
