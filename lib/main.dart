import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'bootstrap.dart';
import 'app.dart';
import 'core/di/injection.dart';
import 'features/timer/data/datasources/audio_service.dart';

Future<void> main() async {
  try {
    await bootstrap();
    runApp(const App());
    
    // Uygulama ilk frame'i çizdikten (render) hemen sonra tetiklenir.
    // Ses dosyalarının RAM'e yüklenmesi (preload) gibi aciliyeti olmayan ağır işlemleri
    // uygulama açılış süresini yavaşlatmaması için buraya, post-frame callback'e erteliyoruz (Lazy Loading).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sl<AudioService>().init();
    });
  } catch (e, stackTrace) {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.black,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Uygulama Başlatılırken Hata Oluştu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  kDebugMode
                      ? e.toString()
                      : 'Lütfen uygulamayı yeniden başlatın.',
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Text(
                    stackTrace.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}