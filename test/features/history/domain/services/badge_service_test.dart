import 'package:flutter_test/flutter_test.dart';
import 'package:fonksiyonel_fitness_timer/features/history/domain/entities/workout_record.dart';
import 'package:fonksiyonel_fitness_timer/features/history/domain/services/badge_service.dart';

void main() {
  late BadgeService badgeService;

  setUp(() {
    badgeService = BadgeService();
  });

  group('BadgeService - Milestone Tests', () {
    test('Hiç antrenman yoksa rozet verilmemeli', () {
      final result = badgeService.checkMilestones([], []);
      expect(result.isEmpty, true);
    });

    test('İlk antrenman tamamlandığında FIRST BLOOD rozeti verilmeli', () {
      final history = [
        WorkoutRecord(
          id: '1',
          modeName: 'AMRAP',
          totalSeconds: 600,
          rounds: 10,
          workSeconds: 60,
          restSeconds: 0,
          date: DateTime.now(),
        )
      ];
      final result = badgeService.checkMilestones(history, []);
      expect(result.any((b) => b.id == 'first_blood'), true);
    });

    test('Daha önce kazanılmış rozet tekrar verilmemeli', () {
      final history = [
        WorkoutRecord(
          id: '1',
          modeName: 'AMRAP',
          totalSeconds: 600,
          rounds: 10,
          workSeconds: 60,
          restSeconds: 0,
          date: DateTime.now(),
        )
      ];
      final result = badgeService.checkMilestones(history, []);
      final secondCheck = badgeService.checkMilestones(history, result);
      expect(secondCheck.isEmpty, true);
    });

    test('30 dk üzeri antrenmanda ENDURANCE rozeti verilmeli', () {
      final history = [
        WorkoutRecord(
          id: '1',
          modeName: 'FOR TIME',
          totalSeconds: 1801, // > 30 dk
          rounds: 1,
          workSeconds: 1801,
          restSeconds: 0,
          date: DateTime.now(),
        )
      ];
      final result = badgeService.checkMilestones(history, []);
      expect(result.any((b) => b.id == 'endurance_warrior'), true);
    });
  });
}
