import 'package:hive_ce/hive.dart';
import '../../../../core/utils/security_service.dart';
import '../../domain/entities/workout_preset.dart';
import '../models/workout_preset_model.dart';

/// Workout mode yerel veri kaynağı.
class WorkoutModeLocalDatasource {
  static const String _boxName = 'workout_presets';
  final SecurityService _securityService;

  WorkoutModeLocalDatasource(this._securityService);

  Future<Box<Map>> get _box async {
    final encryptionKey = await _securityService.getEncryptionKey();
    return Hive.openBox<Map>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<void> savePreset(WorkoutPreset preset) async {
    final box = await _box;
    await box.add(WorkoutPresetModel.fromEntity(preset).toMap());
  }

  Future<List<WorkoutPreset>> getUserPresets() async {
    final box = await _box;
    return box.values
        .map((data) =>
            WorkoutPresetModel.fromMap(Map<String, dynamic>.from(data)).toEntity())
        .toList();
  }
}
