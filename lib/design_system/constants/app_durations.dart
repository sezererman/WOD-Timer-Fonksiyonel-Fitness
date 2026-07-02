/// Varsayılan süre sabitleri (saniye cinsinden).
class AppDurations {
  AppDurations._();

  // Hazırlık
  static const int defaultPrepareSeconds = 10;

  // Tabata varsayılanları
  static const int tabataWorkSeconds = 20;
  static const int tabataRestSeconds = 10;
  static const int tabataDefaultRounds = 8;

  // EMOM varsayılanları
  static const int emomDefaultMinutes = 1;
  static const int emomDefaultRounds = 10;

  // AMRAP varsayılanları
  static const int amrapDefaultMinutes = 12;

  // Genel varsayılanlar
  static const int defaultWorkSeconds = 60;
  static const int defaultRestSeconds = 30;
  static const int defaultRounds = 5;
  static const int defaultCooldownSeconds = 0;
  static const int forTimeDefaultSeconds = 900;

  // Sınırlar
  static const int minSeconds = 5;
  static const int maxSeconds = 3600;  // 60 dakika
  static const int minRounds = 1;
  static const int maxRounds = 100;

  // Timer Ayarları
  static const int countdownThreshold = 3; // Son kaç saniye bip sesi çalsın?
  static const int maxTimeJumpSeconds = 2; // Anti-cheat süresi (Zaman sıçraması sınırı)

  // Animasyon süreleri
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);
}
