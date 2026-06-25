import 'package:equatable/equatable.dart';
import 'exercise_entity.dart';

class WorkoutShareEntity extends Equatable {
  final String id;
  final String userId;
  final String? userName;
  final String? userAvatarUrl;

  /// Kullanıcının XP seviyesi (tier rozeti için). null ise rozet gösterilmez.
  final int? userLevel;

  final String workoutType; // AMRAP, EMOM, TABATA vb.
  final int durationSeconds;
  final int? score; // AMRAP için tekrar, TABATA için round vb.
  final DateTime date;
  final String? notes;
  final int likesCount;
  final List<String> likedUserIds;
  final List<ExerciseEntity> exercises;

  const WorkoutShareEntity({
    required this.id,
    required this.userId,
    this.userName,
    this.userAvatarUrl,
    this.userLevel,
    required this.workoutType,
    required this.durationSeconds,
    this.score,
    required this.date,
    this.notes,
    this.likesCount = 0,
    this.likedUserIds = const [],
    this.exercises = const [],
  });

  WorkoutShareEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    int? userLevel,
    String? workoutType,
    int? durationSeconds,
    int? score,
    DateTime? date,
    String? notes,
    int? likesCount,
    List<String>? likedUserIds,
    List<ExerciseEntity>? exercises,
  }) {
    return WorkoutShareEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      userLevel: userLevel ?? this.userLevel,
      workoutType: workoutType ?? this.workoutType,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      score: score ?? this.score,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      likesCount: likesCount ?? this.likesCount,
      likedUserIds: likedUserIds ?? this.likedUserIds,
      exercises: exercises ?? this.exercises,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatarUrl,
        userLevel,
        workoutType,
        durationSeconds,
        score,
        date,
        notes,
        likesCount,
        likedUserIds,
        exercises,
      ];
}
