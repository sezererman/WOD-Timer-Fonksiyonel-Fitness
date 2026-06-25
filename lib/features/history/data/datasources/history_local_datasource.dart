import 'package:hive_ce/hive.dart';
import '../../../../core/utils/security_service.dart';
import '../../domain/entities/workout_record.dart';
import '../models/workout_record_model.dart';

/// Antrenman geçmişi yerel veri kaynağı.
class HistoryLocalDatasource {
  static const String _boxName = 'workout_history';
  final SecurityService _securityService;

  HistoryLocalDatasource(this._securityService);

  Future<Box<Map>> get _box async {
    final encryptionKey = await _securityService.getEncryptionKey();
    return Hive.openBox<Map>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  Future<List<WorkoutRecord>> getHistory() async {
    final box = await _box;
    final records = box.values
        .map((data) =>
            WorkoutRecordModel.fromMap(Map<String, dynamic>.from(data)).toEntity())
        .toList();
    records.sort((a, b) => b.date.compareTo(a.date));
    return records;
  }

  Future<void> saveWorkout(WorkoutRecord record) async {
    final box = await _box;
    await box.put(record.id, WorkoutRecordModel.fromEntity(record).toMap());
  }

  Future<void> deleteWorkout(String id) async {
    final box = await _box;
    await box.delete(id);
  }
}
