import 'package:equatable/equatable.dart';

/// Uygulama ayarları entity'si.
class AppSettings extends Equatable {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool keepScreenOn;

  const AppSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.keepScreenOn = true,
  });

  AppSettings copyWith({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? keepScreenOn,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }

  @override
  List<Object?> get props => [soundEnabled, vibrationEnabled, keepScreenOn];
}
