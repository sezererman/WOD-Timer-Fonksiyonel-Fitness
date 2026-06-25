import '../constants/badge_id.dart';
import '../entities/workout_record.dart';
import '../entities/badge.dart';

/// Kullanıcının başarılarını analiz eden ve rozet veren servis.
class BadgeService {
  /// Yeni kazanılan rozetleri döner.
  List<Badge> checkMilestones(List<WorkoutRecord> history, List<Badge> earnedBadges) {
    final newBadges = <Badge>[];
    final earnedIds = earnedBadges.map((b) => b.id).toSet();

    // 1. İlk Antrenman (First Blood)
    if (history.isNotEmpty && !earnedIds.contains(BadgeId.firstBlood)) {
      newBadges.add(Badge(
        id: BadgeId.firstBlood,
        title: 'İLK KAN',
        description: 'İlk antrenmanını tamamladın!',
        iconAsset: 'assets/icons/badges/first_blood.png',
        earnedDate: DateTime.now(),
      ));
    }

    // 2. Dayanıklılık (Endurance) - 30 dk üzeri antrenman
    final hasLongWorkout = history.any((r) => r.totalSeconds >= 1800);
    if (hasLongWorkout && !earnedIds.contains(BadgeId.enduranceWarrior)) {
      newBadges.add(Badge(
        id: BadgeId.enduranceWarrior,
        title: 'DAYANIKLILIK SAVAŞÇISI',
        description: '30 dakika üzerinde aralıksız çalıştın!',
        iconAsset: 'assets/icons/badges/endurance.png',
        earnedDate: DateTime.now(),
      ));
    }

    // 3. İstikrar (Consistency) - Son 7 günde 5 antrenman
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final weeklyCount = history.where((r) => r.date.isAfter(weekAgo)).length;
    if (weeklyCount >= 5 && !earnedIds.contains(BadgeId.consistencyKing)) {
      newBadges.add(Badge(
        id: BadgeId.consistencyKing,
        title: 'İSTİKRAR KRALI',
        description: 'Bir haftada 5 antrenman tamamladın!',
        iconAsset: 'assets/icons/badges/consistency.png',
        earnedDate: DateTime.now(),
      ));
    }

    // 4. Onluk Seri (Perfect Ten) - 10 toplam antrenman
    if (history.length >= 10 && !earnedIds.contains(BadgeId.perfectTen)) {
      newBadges.add(Badge(
        id: BadgeId.perfectTen,
        title: 'MÜKEMMEL ONLU',
        description: 'Toplam 10 antrenmana ulaştın!',
        iconAsset: 'assets/icons/badges/ten.png',
        earnedDate: DateTime.now(),
      ));
    }

    return newBadges;
  }
}
