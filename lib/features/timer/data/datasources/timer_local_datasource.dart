import 'package:hive_ce/hive.dart';
import '../../../../core/utils/security_service.dart';
import '../../domain/entities/timer_config.dart';
import '../models/timer_config_model.dart';

/// Timer yapılandırmaları için yerel veri kaynağı.
class TimerLocalDatasource {
  static const String _boxName = 'timer_configs';
  final SecurityService _securityService;

  TimerLocalDatasource(this._securityService);

  Future<Box<Map>> get _box async {
    final encryptionKey = await _securityService.getEncryptionKey();
    return Hive.openBox<Map>(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  /// Son kayıtlı yapılandırmayı getirir.
  Future<TimerConfig?> getLastConfig() async {
    final box = await _box;
    if (box.isEmpty) return null;
    final data = box.getAt(box.length - 1);
    if (data == null) return null;
    return TimerConfigModel.fromMap(Map<String, dynamic>.from(data)).toEntity();
  }

  /// Yapılandırmayı kaydeder.
  Future<void> saveConfig(TimerConfig config) async {
    final box = await _box;
    await box.add(TimerConfigModel.fromEntity(config).toMap());
  }

  /// Tüm yapılandırmaları getirir.
  Future<List<TimerConfig>> getAllConfigs() async {
    final box = await _box;
    return box.values
        .map((data) =>
            TimerConfigModel.fromMap(Map<String, dynamic>.from(data)).toEntity())
        .toList();
  }

  /// Yapılandırmayı siler.
  Future<void> deleteConfig(int index) async {
    final box = await _box;
    await box.deleteAt(index);
  }
}
