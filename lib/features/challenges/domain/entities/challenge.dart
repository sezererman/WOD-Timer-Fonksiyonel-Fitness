import 'package:equatable/equatable.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';

class Challenge extends Equatable {
  final String id;
  final DateTime date;
  final String title;
  final WorkoutMode mode;
  final int durationSeconds;
  final int rounds;
  final int workSeconds;
  final int restSeconds;
  final int prepareSeconds;
  final int cooldownSeconds;
  final List<dynamic> movements;
  final String? imageUrl;
  final int likesCount;

  const Challenge({
    required this.id,
    required this.date,
    required this.title,
    required this.mode,
    required this.durationSeconds,
    this.rounds = 1,
    required this.workSeconds,
    this.restSeconds = 0,
    this.prepareSeconds = 10,
    this.cooldownSeconds = 0,
    this.movements = const [],
    this.imageUrl,
    this.likesCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        date,
        title,
        mode,
        durationSeconds,
        rounds,
        workSeconds,
        restSeconds,
        prepareSeconds,
        cooldownSeconds,
        movements,
        imageUrl,
        likesCount,
      ];
}
