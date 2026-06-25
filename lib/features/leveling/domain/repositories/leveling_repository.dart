import '../entities/user_level_entity.dart';
import '../entities/xp_award_result.dart';

/// Leveling feature'ının repository sözleşmesi.
///
/// Implementasyon Data katmanında ([LevelingRepositoryImpl]) yapılır.
abstract class LevelingRepository {
  /// Kullanıcının XP profilini Supabase'den tek seferlik çeker.
  Future<UserLevelEntity> getUserLevel(String userId);

  /// Supabase Realtime üzerinden XP değişikliklerini akış olarak dinler.
  ///
  /// Antrenman kaydedilip RPC çalıştığında bu stream yeni [UserLevelEntity]
  /// emit eder — BLoC bu akışı dinleyerek level-up kontrolü yapar.
  Stream<UserLevelEntity> streamXpUpdates(String userId);

  /// Antrenman tamamlandığında Supabase RPC'yi çağırarak XP ödüllendirir.
  ///
  /// Dönen [XpAwardResult] RPC'nin parse edilmiş çıktısıdır.
  Future<XpAwardResult> awardXp({
    required String userId,
    required String modeName,
    required int totalSeconds,
    required int roundsCompleted,
    required int timeCapSeconds,
    required bool finishedBeforeCap,
    required DateTime clientStartedAt,
    required DateTime clientFinishedAt,
    required int currentLevel,
  });
}
