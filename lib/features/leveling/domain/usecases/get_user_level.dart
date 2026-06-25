import '../entities/user_level_entity.dart';
import '../repositories/leveling_repository.dart';

/// Kullanıcının XP profilini tek seferlik çeken use case.
class GetUserLevel {
  final LevelingRepository _repository;

  const GetUserLevel(this._repository);

  Future<UserLevelEntity> call(String userId) =>
      _repository.getUserLevel(userId);
}
