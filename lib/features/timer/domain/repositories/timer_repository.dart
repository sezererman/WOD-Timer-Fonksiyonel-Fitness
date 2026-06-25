import '../entities/timer_config.dart';

/// Timer repository soyut arayüzü.
/// Data katmanında somut uygulaması sağlanır.
abstract class TimerRepository {
  /// Son kullanılan timer yapılandırmasını getirir.
  Future<TimerConfig?> getLastConfig();

  /// Timer yapılandırmasını kaydeder.
  Future<void> saveConfig(TimerConfig config);

  /// Kayıtlı tüm yapılandırmaları getirir.
  Future<List<TimerConfig>> getSavedConfigs();

  /// Bir yapılandırmayı siler.
  Future<void> deleteConfig(int index);
}
