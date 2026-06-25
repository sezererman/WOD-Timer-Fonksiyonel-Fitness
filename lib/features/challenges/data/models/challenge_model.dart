import '../../domain/entities/challenge.dart';
import '../../../workout_modes/domain/entities/workout_mode.dart';

class ChallengeModel extends Challenge {
  const ChallengeModel({
    required super.id,
    required super.date,
    required super.title,
    required super.mode,
    required super.durationSeconds,
    super.rounds = 1,
    required super.workSeconds,
    super.restSeconds = 0,
    super.prepareSeconds = 10,
    super.cooldownSeconds = 0,
    super.movements = const [],
    super.imageUrl,
    super.likesCount = 0,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    // Mode text'i enum'a çevirme
    final modeStr = json['mode'] as String;
    final mode = WorkoutMode.values.firstWhere(
      (e) => e.name.toLowerCase() == modeStr.toLowerCase(),
      orElse: () => WorkoutMode.custom,
    );

    return ChallengeModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      mode: mode,
      durationSeconds: json['duration_seconds'] as int,
      rounds: json['rounds'] as int? ?? 1,
      workSeconds: json['work_seconds'] as int,
      restSeconds: json['rest_seconds'] as int? ?? 0,
      prepareSeconds: json['prepare_seconds'] as int? ?? 10,
      cooldownSeconds: json['cooldown_seconds'] as int? ?? 0,
      movements: json['movements'] as List<dynamic>? ?? [],
      imageUrl: json['image_url'] as String?,
      likesCount: json['likes_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String().split('T')[0], // Sadece tarih (YYYY-MM-DD)
      'title': title,
      'mode': mode.name,
      'duration_seconds': durationSeconds,
      'rounds': rounds,
      'work_seconds': workSeconds,
      'rest_seconds': restSeconds,
      'prepare_seconds': prepareSeconds,
      'cooldown_seconds': cooldownSeconds,
      'movements': movements,
      'image_url': imageUrl,
      'likes_count': likesCount,
    };
  }
}
