import 'dart:math' as math;
import '../entities/user_level_entity.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SABITLER
// ─────────────────────────────────────────────────────────────────────────────

/// Temel XP miktarı: Level 1'den 2'ye geçmek için gereken XP.
const double _kBase = 100.0;

/// Büyüme çarpanı: Her seviye bir öncekinden %18 daha fazla XP gerektirir.
const double _kGrowth = 1.18;

/// Günlük maksimum XP miktarı.
const int kDailyXpCap = 1500;

/// Seans başına maksimum XP miktarı.
const int kSessionXpCap = 500;

// ─────────────────────────────────────────────────────────────────────────────
// SEVIYE GRUPLARI
// ─────────────────────────────────────────────────────────────────────────────

/// Tanımlı seviye kademeleri.
enum PlayerTier {
  rookie,       // Level 1-5
  beginner,     // Level 6-15
  intermediate, // Level 16-35
  advanced,     // Level 36-60
  elite,        // Level 61+
}

extension PlayerTierX on PlayerTier {
  String get displayName {
    switch (this) {
      case PlayerTier.rookie:
        return 'Çaylak';
      case PlayerTier.beginner:
        return 'Yeni Başlayan';
      case PlayerTier.intermediate:
        return 'Orta';
      case PlayerTier.advanced:
        return 'İleri';
      case PlayerTier.elite:
        return 'Elit Sporcu';
    }
  }

  /// Tier'in emoji/ikon temsili.
  String get icon {
    switch (this) {
      case PlayerTier.rookie:
        return '🥉';
      case PlayerTier.beginner:
        return '🟢';
      case PlayerTier.intermediate:
        return '🔵';
      case PlayerTier.advanced:
        return '🟣';
      case PlayerTier.elite:
        return '🔴';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// USER LEVEL MODEL — Saf hesaplama sınıfı
// ─────────────────────────────────────────────────────────────────────────────

/// XP ve Seviye sisteminin tüm hesaplama mantığını barındıran saf Dart modeli.
///
/// Bu sınıf Supabase'deki PostgreSQL formülüyle birebir eşleşir.
/// Tüm metodlar [static] ve [pure function] — dış bağımlılık yoktur.
///
/// Formül: XP_required(level) = 100 × 1.18^(level - 1)
class UserLevelModel {
  final UserLevelEntity entity;

  const UserLevelModel(this.entity);

  // ───────── STATIK HESAPLAMA METODLARI ─────────────────────────────────────

  /// Belirli bir seviyeye geçmek için gereken XP miktarını döner.
  ///
  /// ```dart
  /// xpRequiredForLevel(1)  → 100
  /// xpRequiredForLevel(2)  → 118
  /// xpRequiredForLevel(10) → 393
  /// ```
  static int xpRequiredForLevel(int level) {
    assert(level >= 1, 'Level 1\'den küçük olamaz.');
    return (_kBase * math.pow(_kGrowth, level - 1)).floor();
  }

  /// Toplam XP miktarına göre mevcut seviyeyi hesaplar.
  ///
  /// ```dart
  /// levelFromTotalXp(0)    → 1
  /// levelFromTotalXp(100)  → 2
  /// levelFromTotalXp(570)  → 5 (Çaylak son level)
  /// levelFromTotalXp(4400) → 15 (Beginner son level)
  /// ```
  static int levelFromTotalXp(int totalXp) {
    if (totalXp <= 0) return 1;
    int level = 1;
    int cumulative = 0;
    while (true) {
      final needed = xpRequiredForLevel(level);
      if (cumulative + needed > totalXp) break;
      cumulative += needed;
      level++;
    }
    return level;
  }

  /// Mevcut seviye içindeki ilerleme yüzdesini 0.0–1.0 arasında döner.
  ///
  /// Bu değer progress bar için doğrudan kullanılabilir.
  ///
  /// ```dart
  /// progressPercentage(totalXp: 50, level: 1)  → 0.5  (Level 1 yarısı)
  /// progressPercentage(totalXp: 100, level: 1) → 0.0  (Level 2 başlangıcı)
  /// ```
  static double progressPercentage(int totalXp) {
    if (totalXp <= 0) return 0.0;
    final level = levelFromTotalXp(totalXp);
    final xpAtLevelStart = cumulativeXpAtLevelStart(level);
    final xpNeededForThisLevel = xpRequiredForLevel(level);
    final xpProgressInLevel = totalXp - xpAtLevelStart;
    if (xpNeededForThisLevel <= 0) return 1.0;
    return (xpProgressInLevel / xpNeededForThisLevel).clamp(0.0, 1.0);
  }

  /// Level başlangıcındaki kümülatif XP toplamını döner.
  ///
  /// Yani bu levele ulaşmak için toplam kaç XP gerektiği.
  ///
  /// PERFORMANS: Sonuçlar static cache'e alınır — aynı level için
  /// O(n) hesaplama yalnızca bir kez yapılır.
  static final Map<int, int> _cumulativeXpCache = {};

  static int cumulativeXpAtLevelStart(int level) {
    if (level <= 1) return 0;
    return _cumulativeXpCache.putIfAbsent(level, () {
      int total = 0;
      for (int l = 1; l < level; l++) {
        total += xpRequiredForLevel(l);
      }
      return total;
    });
  }

  /// Bir sonraki seviyeye geçmek için kaç XP daha gerektiğini döner.
  static int xpToNextLevel(int totalXp) {
    final level = levelFromTotalXp(totalXp);
    final xpAtLevelStart = cumulativeXpAtLevelStart(level);
    final xpNeededForThisLevel = xpRequiredForLevel(level);
    return (xpAtLevelStart + xpNeededForThisLevel) - totalXp;
  }

  /// Verilen seviyeye karşılık gelen [PlayerTier] tier'ini döner.
  static PlayerTier tierFromLevel(int level) {
    if (level >= 61) return PlayerTier.elite;
    if (level >= 36) return PlayerTier.advanced;
    if (level >= 16) return PlayerTier.intermediate;
    if (level >= 6) return PlayerTier.beginner;
    return PlayerTier.rookie;
  }

  // ───────── INSTANCE METODLARI ─────────────────────────────────────────────

  /// Kullanıcının mevcut level'ı.
  int get level => entity.currentLevel;

  /// Kullanıcının mevcut tier'ı.
  PlayerTier get tier => tierFromLevel(entity.currentLevel);

  /// Kullanıcının tier ismini döner.
  String get tierName => tier.displayName;

  /// Kullanıcının mevcut seviyedeki ilerleme yüzdesi (0.0 – 1.0).
  double get progressPercentageValue => progressPercentage(entity.totalXp);

  /// Bir sonraki seviyeye geçmek için gereken XP.
  int get xpNeededForNextLevel => xpToNextLevel(entity.totalXp);

  /// Mevcut leveldeki toplam XP eşiği.
  int get currentLevelXpThreshold => xpRequiredForLevel(entity.currentLevel);

  /// Kullanıcının bugünkü günlük cap'e ne kadar yaklaştığını döner (0.0–1.0).
  double get dailyCapProgress =>
      (entity.dailyXpToday / kDailyXpCap).clamp(0.0, 1.0);

  /// Günlük cap dolmuş mu?
  bool get isDailyCapReached => entity.dailyXpToday >= kDailyXpCap;

  // ───────── PUANLAMA TABLOSU (dokümantasyon amaçlı) ────────────────────────

  /// Her seviye için gereken XP ve kümülatif XP tablosunu oluşturur.
  /// Kullanım: debug veya onboarding ekranı için.
  static List<Map<String, dynamic>> generateLevelTable({int upToLevel = 65}) {
    final table = <Map<String, dynamic>>[];
    int cumulative = 0;
    for (int l = 1; l <= upToLevel; l++) {
      final needed = xpRequiredForLevel(l);
      cumulative += needed;
      table.add({
        'level': l,
        'xp_for_level': needed,
        'cumulative_xp': cumulative,
        'tier': tierFromLevel(l).displayName,
      });
    }
    return table;
  }
}
