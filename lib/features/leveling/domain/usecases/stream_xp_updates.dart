import '../entities/user_level_entity.dart';
import '../repositories/leveling_repository.dart';

/// Supabase Realtime üzerinden XP değişikliklerini stream olarak dinleyen use case.
///
/// BLoC bu use case'i inject ederek her XP güncellemesinde yeni state emit eder.
/// Level-up tespiti BLoC içinde yapılır (eski level vs yeni level karşılaştırması).
class StreamXpUpdates {
  final LevelingRepository _repository;

  const StreamXpUpdates(this._repository);

  Stream<UserLevelEntity> call(String userId) =>
      _repository.streamXpUpdates(userId);
}
