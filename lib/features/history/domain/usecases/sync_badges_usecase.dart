import '../entities/badge.dart';
import '../repositories/badge_repository.dart';
import '../services/badge_service.dart';
import '../entities/workout_record.dart';

/// Antrenman kayıtlarını analiz edip yeni rozetleri tespit eden,
/// tespit edilenleri kaydedip tüm kazanılmış rozetleri döndüren UseCase.
///
/// HistoryBloc bu UseCase'i çağırır — BadgeLocalDatasource'u hiç bilmez.
class SyncBadgesUseCase {
  final BadgeRepository _repository;
  final BadgeService _badgeService;

  const SyncBadgesUseCase({
    required BadgeRepository repository,
    required BadgeService badgeService,
  })  : _repository = repository,
        _badgeService = badgeService;

  /// [records] ile yeni rozet kontrolü yapar, yenilerini kaydeder
  /// ve güncel rozet listesini döndürür.
  Future<List<Badge>> call(List<WorkoutRecord> records) async {
    final earnedBadges = await _repository.getEarnedBadges();
    final newBadges = _badgeService.checkMilestones(records, earnedBadges);

    for (final badge in newBadges) {
      await _repository.saveBadge(badge);
    }

    // Yeni eklenenler de dahil güncel listeyi döndür
    if (newBadges.isEmpty) return earnedBadges;
    return _repository.getEarnedBadges();
  }
}
