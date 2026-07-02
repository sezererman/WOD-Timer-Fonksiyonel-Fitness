import 'package:hive_ce/hive.dart';
import '../../../../core/utils/security_service.dart';
import '../../domain/entities/workout_record.dart';
import '../../domain/constants/sync_status.dart';
import '../models/workout_record_model.dart';

/// Antrenman geçmişi yerel veri kaynağı.
///
/// Hive box, [Hive.openBox] tarafından dahili olarak önbelleğe alınır:
/// aynı box adıyla yapılan her çağrı aynı instance'ı döndürür.
/// Bu yüzden getter'ı her seferinde çağırmak güvenlidir.
class HistoryLocalDatasource {
  static const String _boxName = 'workout_history';
  final SecurityService _securityService;

  // Box instance'ı, ilk çağrıdan sonra Hive tarafından önbelleğe alınır.
  // Tekrar openBox() çağrısı yapıldığında aynı instance döner — güvenli.
  Box<Map>? _cachedBox;

  HistoryLocalDatasource(this._securityService);

  Future<Box<Map>> get _box async {
    if (_cachedBox != null && _cachedBox!.isOpen) return _cachedBox!;
    final encryptionKey = await _securityService.getEncryptionKey();
    _cachedBox = await Hive.openBox<Map>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    return _cachedBox!;
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

  /// Hive'da [SyncStatus.pending] veya [SyncStatus.failed] statüsündeki
  /// tüm kayıtları döndürür.
  Future<List<WorkoutRecord>> getPendingWorkouts() async {
    final box = await _box;
    final records = box.values
        .map((data) =>
            WorkoutRecordModel.fromMap(Map<String, dynamic>.from(data)))
        .where((model) =>
            model.syncStatus == SyncStatus.pending ||
            model.syncStatus == SyncStatus.failed)
        .map((model) => model.toEntity())
        .toList();
    return records;
  }

  /// Belirtilen kaydın sync statüsünü günceller.
  ///
  /// [status] parametresi [SyncStatus] sabitlerinden biri olmalıdır.
  Future<void> updateSyncStatus(String id, String status) async {
    assert(
      status == SyncStatus.pending ||
          status == SyncStatus.synced ||
          status == SyncStatus.failed,
      'updateSyncStatus: Geçersiz status değeri "$status". '
      'SyncStatus sabitlerinden birini kullanın.',
    );
    final box = await _box;
    final data = box.get(id);
    if (data != null) {
      final map = Map<String, dynamic>.from(data);
      map['syncStatus'] = status;
      await box.put(id, map);
    }
  }
}
