import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/ticker.dart';
import '../../utils/security_service.dart';

/// Core altyapı bağımlılıklarını kaydeder.
/// Supabase, SecureStorage, Ticker gibi tüm feature'ların paylaştığı yapılar.
abstract final class CoreModule {
  static void register(GetIt sl) {
    sl.registerLazySingleton<Ticker>(() => const Ticker());

    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );

    sl.registerLazySingleton<SecurityService>(
      () => SecurityService(storage: sl()),
    );

    // Supabase — bootstrap.dart'ta initialize edilmiş olmalı.
    sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);
  }
}
