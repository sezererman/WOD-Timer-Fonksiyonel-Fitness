import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fonksiyonel_fitness_timer/main.dart' as app;

void main() {
  // Entegrasyon testleri için bağlayıcıyı başlatır
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E: Uygulama açılışı, WOD seçimi ve Timer başlatma', (WidgetTester tester) async {
    // 1. Uygulamayı Başlat
    await app.main();
    // Uygulamanın ayağa kalkması ve animasyonların bitmesi için bekle
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // 2. Alt Navigasyon (Bottom Nav) üzerinden WOD sekmesine tıkla
    // Not: Kullanıcı "Topluluk" üzerinden "Meydan Okumayı Kabul Et" butonunu talep etti ancak
    // Meydan okumalar (Challenges) menüsü "WOD" sekmesi altında yer almaktadır.
    final wodTab = find.text('WOD');
    expect(wodTab, findsOneWidget, reason: 'Bottom Nav üzerinde WOD sekmesi bulunamadı.');
    await tester.tap(wodTab);
    await tester.pumpAndSettle();

    // 3. Gelen Meydan Okumalar listesinde en üstteki antrenman kartına tıkla
    final firstChallengeCard = find.text('20 Min AMRAP - Cindy');
    expect(firstChallengeCard, findsOneWidget, reason: 'İlk meydan okuma kartı (Cindy) bulunamadı.');
    await tester.tap(firstChallengeCard);
    await tester.pumpAndSettle(); // BottomSheet'in tamamen açılmasını bekle

    // 4. Açılan detay sayfasında 'MEYDAN OKUMAYI KABUL ET' butonuna bas
    final acceptChallengeBtn = find.text('MEYDAN OKUMAYI KABUL ET');
    expect(acceptChallengeBtn, findsOneWidget, reason: 'Meydan okumayı kabul et butonu bulunamadı.');
    await tester.tap(acceptChallengeBtn);
    await tester.pumpAndSettle(); // go_router'ın Timer sayfasına geçişini bekle

    // 5. Yönlendirilen sayfanın Timer sayfası olduğunu ve antrenmanın otomatik başladığını doğrula
    // TimerPage initState içinde otomatik olarak TimerStarted event'i fırlattığı için
    // uygulama anında "Hazırlık" (Prepare) evresine geçer ve "Duraklat" (Pause) butonu görünür.
    final pauseButton = find.byIcon(Icons.pause_rounded);
    expect(pauseButton, findsOneWidget, reason: 'Timer sayfasına yönlendirme veya otomatik başlatma başarısız!');

    // 6. Zamanlayıcıyı duraklatıp (Pause) tekrar başlatmayı (Play) test et
    await tester.tap(pauseButton);
    await tester.pumpAndSettle(); // Duraklatma state'ine geçişi bekle

    // Şimdi "Başlat" (Play) butonunun ekranda olduğunu doğrula
    final startButton = find.byIcon(Icons.play_arrow_rounded);
    expect(startButton, findsOneWidget, reason: 'Timer duraklatılamadı; Play butonu ekranda yok!');

    // Tekrar başlat (Resume)
    await tester.tap(startButton);
    await tester.pump(); // Tap event'ini işlet

    // Timer akışında biraz zaman geçmesini simüle et (2 saniye)
    await tester.pump(const Duration(seconds: 2));

    // Tekrar "Duraklat" butonunun göründüğünü kontrol et
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget, reason: 'Timer tekrar başlatılamadı!');
  });
}
