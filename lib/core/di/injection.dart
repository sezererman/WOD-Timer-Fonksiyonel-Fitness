import 'package:get_it/get_it.dart';

import 'modules/core_module.dart';
import 'modules/timer_module.dart';
import 'modules/workout_modes_module.dart';
import 'modules/history_module.dart';
import 'modules/settings_module.dart';
import 'modules/auth_module.dart';
import 'modules/community_module.dart';
import 'modules/profile_module.dart';
import 'modules/leveling_module.dart';

final sl = GetIt.instance;

/// Tüm bağımlılıkları başlatan ana orchestrator.
///
/// Her feature kendi modül dosyasında izole edilmiştir (SRP / CCP).
/// Yeni feature eklemek için yeni bir `XxxModule.register(sl)` satırı yeterlidir —
/// bu dosyaya başka bir değişiklik gerekmez (OCP).
Future<void> initDependencies() async {
  CoreModule.register(sl);
  TimerModule.register(sl);
  WorkoutModesModule.register(sl);
  HistoryModule.register(sl);
  SettingsModule.register(sl);
  AuthModule.register(sl);
  CommunityModule.register(sl);
  ProfileModule.register(sl);
  LevelingModule.register(sl);

  await sl.allReady();
}
