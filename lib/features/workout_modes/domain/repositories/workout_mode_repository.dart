import '../entities/workout_preset.dart';
import '../entities/workout_mode.dart';

/// Workout mode repository soyut arayüzü.
abstract class WorkoutModeRepository {
  /// Tüm kullanılabilir modları getirir.
  List<WorkoutMode> getAvailableModes();

  /// Bir mod için varsayılan preset'leri getirir.
  List<WorkoutPreset> getPresetsForMode(WorkoutMode mode);

  /// Kullanıcı tanımlı preset kaydeder.
  Future<void> savePreset(WorkoutPreset preset);

  /// Kullanıcı tanımlı preset'leri getirir.
  Future<List<WorkoutPreset>> getUserPresets();
}
