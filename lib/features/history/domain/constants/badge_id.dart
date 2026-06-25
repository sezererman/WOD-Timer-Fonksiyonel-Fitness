/// Rozet ID sabit değerleri.
///
/// Yazım hatalarını derleme zamanında önler ve refactoring'i güvenli kılar.
/// Yeni rozet eklendiğinde bu dosya tek güncelleme noktasıdır.
abstract final class BadgeId {
  // Birinci Antrenman
  static const String firstBlood = 'first_blood';

  // 30 Dakika Üzeri Antrenman
  static const String enduranceWarrior = 'endurance_warrior';

  // Haftada 5 Antrenman
  static const String consistencyKing = 'consistency_king';

  // Toplam 10 Antrenman
  static const String perfectTen = 'perfect_ten';
}
