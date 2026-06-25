import 'package:equatable/equatable.dart';
import '../../domain/entities/user_level_entity.dart';
import '../../domain/models/user_level_model.dart';

abstract class LevelState extends Equatable {
  const LevelState();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// BAŞLANGIÇ
// ─────────────────────────────────────────────────────────────────────────────

class LevelInitial extends LevelState {
  const LevelInitial();
}

// ─────────────────────────────────────────────────────────────────────────────
// YÜKLENIYOR
// ─────────────────────────────────────────────────────────────────────────────

class LevelLoading extends LevelState {
  const LevelLoading();
}

// ─────────────────────────────────────────────────────────────────────────────
// BAŞARILI
// ─────────────────────────────────────────────────────────────────────────────

/// Normal yüklü durum — XP ve level bilgileri hazır.
class LevelLoaded extends LevelState {
  final UserLevelEntity entity;

  const LevelLoaded(this.entity);

  // ── Hesaplanmış görünüm değerleri ─────────────────────────────────────────

  UserLevelModel get model => UserLevelModel(entity);

  int get level => entity.currentLevel;

  int get totalXp => entity.totalXp;

  /// Mevcut seviye içindeki ilerleme yüzdesi (0.0 – 1.0).
  double get progressPercentage =>
      UserLevelModel.progressPercentage(entity.totalXp);

  /// Bir sonraki seviyeye kaç XP kaldığı.
  int get xpToNextLevel => UserLevelModel.xpToNextLevel(entity.totalXp);

  /// Mevcut seviye eşiği (bu levelın toplam XP'si).
  int get currentLevelThreshold =>
      UserLevelModel.xpRequiredForLevel(entity.currentLevel);

  /// Mevcut tier (Çaylak / Yeni Başlayan / vb.)
  PlayerTier get tier => UserLevelModel.tierFromLevel(entity.currentLevel);

  String get tierName => tier.displayName;

  int get streakDays => entity.streakDays;

  int get dailyXpToday => entity.dailyXpToday;

  @override
  List<Object?> get props => [entity];
}

// ─────────────────────────────────────────────────────────────────────────────
// XP KAZANILIYOR (RPC çağrısı sırasında)
// ─────────────────────────────────────────────────────────────────────────────

/// Antrenman sonrası XP award RPC'si çalışıyor.
/// UI bu sırada "XP hesaplanıyor..." gösterebilir.
class LevelXpAwarding extends LevelLoaded {
  const LevelXpAwarding(super.entity);
}

// ─────────────────────────────────────────────────────────────────────────────
// SEVİYE ATLANDI 🎉
// ─────────────────────────────────────────────────────────────────────────────

/// Seviye atlama gerçekleşti — UI bu state'i izleyerek Level-Up popup'ı gösterir.
///
/// Bu state bir [LevelLoaded] alt sınıfıdır; tüm XP verileri erişilebilirdir.
/// UI [LevelUpCelebrationDismissed] event'ini göndererek normal state'e döner.
class LevelUpOccurred extends LevelLoaded {
  /// Atlamadan önceki eski seviye.
  final int oldLevel;

  /// Kazanılan XP miktarı (bu seans).
  final int xpAwarded;

  /// Kazanılan XP'nin breakdown'u.
  final Map<String, int> xpBreakdown;

  const LevelUpOccurred({
    required UserLevelEntity entity,
    required this.oldLevel,
    required this.xpAwarded,
    required this.xpBreakdown,
  }) : super(entity);

  @override
  List<Object?> get props => [entity, oldLevel, xpAwarded, xpBreakdown];
}

// ─────────────────────────────────────────────────────────────────────────────
// XP KAZANILDI (seviye atlamadan)
// ─────────────────────────────────────────────────────────────────────────────

/// Seviye atlanmadan XP kazanıldı — küçük bir ödül animasyonu gösterilebilir.
class XpEarned extends LevelLoaded {
  final int xpAwarded;
  final Map<String, int> xpBreakdown;

  const XpEarned({
    required UserLevelEntity entity,
    required this.xpAwarded,
    required this.xpBreakdown,
  }) : super(entity);

  @override
  List<Object?> get props => [entity, xpAwarded, xpBreakdown];
}

// ─────────────────────────────────────────────────────────────────────────────
// HATA
// ─────────────────────────────────────────────────────────────────────────────

class LevelError extends LevelState {
  final String message;
  const LevelError(this.message);

  @override
  List<Object?> get props => [message];
}
