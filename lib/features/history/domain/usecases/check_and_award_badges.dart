import '../entities/badge.dart';
import '../repositories/badge_repository.dart';
import '../services/badge_service.dart';
import '../entities/workout_record.dart';

/// Antrenman başarıyla bittiğinde çalışıp kullanıcının geçmişine bakarak 
/// yeni bir rozet kazanıp kazanmadığını kontrol eden UseCase.
class CheckAndAwardBadgesUseCase {
  final BadgeRepository _repository;
  final BadgeService _badgeService;

  const CheckAndAwardBadgesUseCase({
    required BadgeRepository repository,
    required BadgeService badgeService,
  })  : _repository = repository,
        _badgeService = badgeService;

  /// Yeni kazanılan rozetleri veritabanına kaydeder ve bu yeni rozetlerin listesini döndürür.
  Future<List<Badge>> call(List<WorkoutRecord> historyRecords) async {
    final earnedBadges = await _repository.getEarnedBadges();
    final newBadges = _badgeService.checkMilestones(historyRecords, earnedBadges);

    for (final badge in newBadges) {
      await _repository.saveBadge(badge);
    }

    return newBadges;
  }
}
