import 'package:equatable/equatable.dart';

abstract class LevelEvent extends Equatable {
  const LevelEvent();

  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// BAŞLATMA
// ─────────────────────────────────────────────────────────────────────────────

/// Kullanıcı oturum açtığında veya profil sayfası açıldığında tetiklenir.
/// XP profilini çeker ve Realtime stream'e abone olur.
class LevelStarted extends LevelEvent {
  final String userId;
  const LevelStarted(this.userId);

  @override
  List<Object?> get props => [userId];
}

// ─────────────────────────────────────────────────────────────────────────────
// XP KAZANMA
// ─────────────────────────────────────────────────────────────────────────────

/// Antrenman tamamlandığında çağrılır.
/// BLoC bu event ile Supabase RPC'yi tetikler.
class LevelXpAwardRequested extends LevelEvent {
  final String userId;
  final String modeName;
  final int totalSeconds;
  final int roundsCompleted;
  final int timeCapSeconds;
  final bool finishedBeforeCap;
  final DateTime clientStartedAt;
  final DateTime clientFinishedAt;

  const LevelXpAwardRequested({
    required this.userId,
    required this.modeName,
    required this.totalSeconds,
    required this.roundsCompleted,
    required this.timeCapSeconds,
    required this.finishedBeforeCap,
    required this.clientStartedAt,
    required this.clientFinishedAt,
  });

  @override
  List<Object?> get props => [
        userId,
        modeName,
        totalSeconds,
        roundsCompleted,
        timeCapSeconds,
        finishedBeforeCap,
        clientStartedAt,
        clientFinishedAt,
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// REALTIME GÜNCELLEMESİ
// ─────────────────────────────────────────────────────────────────────────────

/// Supabase Realtime'dan gelen XP güncellemesini BLoC'a iletir.
/// Doğrudan kullanıcı tarafından tetiklenmez; BLoC'un iç stream listener'ı kullanır.
class LevelXpUpdatedFromStream extends LevelEvent {
  final int newTotalXp;
  final int newLevel;
  final int streakDays;
  final int dailyXpToday;

  const LevelXpUpdatedFromStream({
    required this.newTotalXp,
    required this.newLevel,
    required this.streakDays,
    required this.dailyXpToday,
  });

  @override
  List<Object?> get props => [newTotalXp, newLevel, streakDays, dailyXpToday];
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL UP POPUP
// ─────────────────────────────────────────────────────────────────────────────

/// Level Up kutlama animasyonu gösterildikten sonra, UI bu event'i göndererek
/// BLoC'u normal [LevelLoaded] state'e geri döndürür.
class LevelUpCelebrationDismissed extends LevelEvent {
  const LevelUpCelebrationDismissed();
}

// ─────────────────────────────────────────────────────────────────────────────
// KAPATMA
// ─────────────────────────────────────────────────────────────────────────────

/// Realtime aboneliğini iptal eder. dispose() sırasında çağrılmalıdır.
class LevelStopped extends LevelEvent {
  const LevelStopped();
}
