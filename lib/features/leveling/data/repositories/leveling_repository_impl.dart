import '../../domain/entities/user_level_entity.dart';
import '../../domain/entities/xp_award_result.dart';
import '../../domain/repositories/leveling_repository.dart';
import '../datasources/leveling_remote_datasource.dart';

/// [LevelingRepository] interface'inin Supabase implementasyonu.
class LevelingRepositoryImpl implements LevelingRepository {
  final LevelingRemoteDataSource _dataSource;

  const LevelingRepositoryImpl(this._dataSource);

  @override
  Future<UserLevelEntity> getUserLevel(String userId) =>
      _dataSource.getUserLevel(userId);

  @override
  Stream<UserLevelEntity> streamXpUpdates(String userId) =>
      _dataSource.streamXpUpdates(userId);

  @override
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
  }) =>
      _dataSource.awardXp(
        userId: userId,
        modeName: modeName,
        totalSeconds: totalSeconds,
        roundsCompleted: roundsCompleted,
        timeCapSeconds: timeCapSeconds,
        finishedBeforeCap: finishedBeforeCap,
        clientStartedAt: clientStartedAt,
        clientFinishedAt: clientFinishedAt,
        currentLevel: currentLevel,
      );
}
