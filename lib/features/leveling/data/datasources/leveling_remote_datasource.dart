import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_level_entity.dart';
import '../../domain/entities/xp_award_result.dart';

/// Supabase'den XP verilerini çeken ve stream eden veri kaynağı.
class LevelingRemoteDataSource {
  final SupabaseClient _client;
  static const _table = 'user_xp_profiles';

  const LevelingRemoteDataSource(this._client);

  // ─────────────────────────────────────────────────────────────────────────
  // TEK SEFERLİK FETCH
  // ─────────────────────────────────────────────────────────────────────────

  /// Kullanıcının XP profilini Supabase'den çeker.
  /// Profil yoksa sıfır değerli bir [UserLevelEntity] döner.
  Future<UserLevelEntity> getUserLevel(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) {
      // Henüz profil oluşturulmamış → varsayılan sıfır entity
      return const UserLevelEntity(
        totalXp: 0,
        currentLevel: 1,
        streakDays: 0,
        dailyXpToday: 0,
      );
    }

    return _fromMap(response);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REALTIME STREAM
  // ─────────────────────────────────────────────────────────────────────────

  /// Supabase Realtime üzerinden XP güncellemelerini stream eder.
  ///
  /// `user_xp_profiles` tablosundaki bu kullanıcının satırı her değiştiğinde
  /// stream yeni bir [UserLevelEntity] emit eder.
  Stream<UserLevelEntity> streamXpUpdates(String userId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', userId)
        .map((rows) {
          if (rows.isEmpty) {
            return const UserLevelEntity(
              totalXp: 0,
              currentLevel: 1,
              streakDays: 0,
              dailyXpToday: 0,
            );
          }
          return _fromMap(rows.first);
        });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RPC ÇAĞRISI — XP AWARD
  // ─────────────────────────────────────────────────────────────────────────

  /// Supabase `calculate_and_award_xp` RPC'sini çağırır.
  ///
  /// Tüm hesaplama ve güvenlik kontrolleri backend'de gerçekleşir.
  /// Bu metod yalnızca parametreleri iletir ve parse edilmiş sonucu döner.
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
  }) async {
    final raw = await _client.rpc(
      'calculate_and_award_xp',
      params: {
        'p_user_id': userId,
        'p_mode_name': modeName,
        'p_total_seconds': totalSeconds,
        'p_rounds_completed': roundsCompleted,
        'p_time_cap_seconds': timeCapSeconds,
        'p_finished_before_cap': finishedBeforeCap,
        'p_client_started_at': clientStartedAt.toUtc().toIso8601String(),
        'p_client_finished_at': clientFinishedAt.toUtc().toIso8601String(),
      },
    );

    final map = Map<String, dynamic>.from(raw as Map);
    return XpAwardResult.fromMap(map, fallbackLevel: currentLevel);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // YARDIMCI
  // ─────────────────────────────────────────────────────────────────────────

  UserLevelEntity _fromMap(Map<String, dynamic> map) {
    return UserLevelEntity(
      totalXp: map['total_xp'] as int? ?? 0,
      currentLevel: map['current_level'] as int? ?? 1,
      streakDays: map['streak_days'] as int? ?? 0,
      dailyXpToday: map['daily_xp_today'] as int? ?? 0,
      lastWorkoutDate: map['last_workout_date'] != null
          ? DateTime.tryParse(map['last_workout_date'] as String)
          : null,
    );
  }
}
