import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection.dart';

/// Uygulama başlatma işlemleri.
/// DI, Hive init, sistem UI yapılandırması.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Çevre değişkenlerini (environment variables) yükle
  String supabaseUrl = const String.fromEnvironment('SUPABASE_URL');
  String supabaseAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY');

  // Geliştirme ortamı için .env dosyasına fallback yapıyoruz
  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    try {
      await dotenv.load();
      supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
      supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    } catch (e) {
      debugPrint('.env load error: $e');
    }
  }

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'SUPABASE credentials missing.\n\n'
      'Lütfen ya terminalden "--dart-define" ile çalıştırın,\n'
      'Ya da proje dizininde ".env" dosyası oluşturup içine:\n'
      'SUPABASE_URL=...\nSUPABASE_ANON_KEY=...\n'
      'ekleyin.',
    );
  }

  // Paralel başlatma: Supabase ve Hive veritabanı ilklendirmeleri birbirinden tamamen bağımsızdır.
  // Bu yüzden bunları Future.wait() ile paralel çalıştırarak başlatma süresini kısaltıyoruz.
  await Future.wait([
    Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    ),
    Hive.initFlutter(),
  ]);

  // Dependency Injection
  await initDependencies();

  // Sistem UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Yatay modu kapat
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
