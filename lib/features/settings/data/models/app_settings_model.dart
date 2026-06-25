import '../../domain/entities/app_settings.dart';

class AppSettingsModel {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool keepScreenOn;

  const AppSettingsModel({
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.keepScreenOn,
  });

  factory AppSettingsModel.fromEntity(AppSettings entity) {
    return AppSettingsModel(
      soundEnabled: entity.soundEnabled,
      vibrationEnabled: entity.vibrationEnabled,
      keepScreenOn: entity.keepScreenOn,
    );
  }

  factory AppSettingsModel.fromMap(Map<String, dynamic> map) {
    return AppSettingsModel(
      soundEnabled: map['soundEnabled'] as bool? ?? true,
      vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
      keepScreenOn: map['keepScreenOn'] as bool? ?? true,
    );
  }

  AppSettings toEntity() {
    return AppSettings(
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      keepScreenOn: keepScreenOn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'keepScreenOn': keepScreenOn,
    };
  }
}
