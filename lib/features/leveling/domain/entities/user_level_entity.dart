import 'package:equatable/equatable.dart';

/// XP ve Seviye sisteminin saf domain varlığı.
///
/// Bu entity hiçbir dış bağımlılık içermez; yalnızca veriler.
class UserLevelEntity extends Equatable {
  /// Kullanıcının sahip olduğu toplam XP miktarı.
  final int totalXp;

  /// Kullanıcının mevcut seviyesi (1'den başlar).
  final int currentLevel;

  /// Üst üste antrenman yapılan gün sayısı.
  final int streakDays;

  /// Bugün kazanılan XP miktarı (günlük cap takibi için).
  final int dailyXpToday;

  /// Son antrenman tarihi.
  final DateTime? lastWorkoutDate;

  const UserLevelEntity({
    required this.totalXp,
    required this.currentLevel,
    required this.streakDays,
    required this.dailyXpToday,
    this.lastWorkoutDate,
  });

  @override
  List<Object?> get props => [
        totalXp,
        currentLevel,
        streakDays,
        dailyXpToday,
        lastWorkoutDate,
      ];
}
