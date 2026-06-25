import 'package:hive_ce/hive.dart';
import '../../domain/entities/app_settings.dart';
import '../models/app_settings_model.dart';

class SettingsLocalDatasource {
  static const String _boxName = 'app_settings';
  static const String _key = 'settings';

  Future<Box<Map>> get _box async => Hive.openBox<Map>(_boxName);

  Future<AppSettings> getSettings() async {
    final box = await _box;
    final data = box.get(_key);
    if (data == null) return const AppSettings();
    return AppSettingsModel.fromMap(Map<String, dynamic>.from(data)).toEntity();
  }

  Future<void> updateSettings(AppSettings settings) async {
    final box = await _box;
    await box.put(_key, AppSettingsModel.fromEntity(settings).toMap());
  }
}
