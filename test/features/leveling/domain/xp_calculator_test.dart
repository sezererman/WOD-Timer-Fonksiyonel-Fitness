// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter_test/flutter_test.dart';

import 'package:fonksiyonel_fitness_timer/features/leveling/domain/models/user_level_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// XP HESAPLAMA ALGORİTMASI — BİRİM TESTLERİ
//
// Test edilen sınıf: UserLevelModel (saf Dart, dış bağımlılık yok)
// Formül: XP_required(level) = 100 × 1.18^(level - 1)
// Büyüme: Her seviye öncekinden %18 daha fazla XP gerektirir.
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 1: xpRequiredForLevel — Bir Seviye İçin Gereken XP
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 1. xpRequiredForLevel (Üstel Büyüme)', () {
    // GIVEN: Level = 1.
    // WHEN: xpRequiredForLevel(1) çağrılır.
    // THEN: Temel XP miktarı 100 dönmeli.
    test(
      'GIVEN level=1 / WHEN xpRequiredForLevel / THEN 100 dönmeli (taban değer)',
      () {
        // Formül: 100 × 1.18^(1-1) = 100 × 1.0 = 100
        expect(UserLevelModel.xpRequiredForLevel(1), equals(100));
      },
    );

    // GIVEN: Level = 2.
    // WHEN: xpRequiredForLevel(2) çağrılır.
    // THEN: 118 dönmeli (100 × 1.18^1 = 118.0 → floor = 118).
    test(
      'GIVEN level=2 / WHEN xpRequiredForLevel / THEN 118 dönmeli (%18 büyüme)',
      () {
        expect(UserLevelModel.xpRequiredForLevel(2), equals(118));
      },
    );

    // GIVEN: Level = 10.
    // WHEN: xpRequiredForLevel(10) çağrılır.
    // THEN: 443 dönmeli (100 × 1.18^9 = 443.92... → floor = 443).
    test(
      'GIVEN level=10 / WHEN xpRequiredForLevel / THEN 443 dönmeli (üstel artış)',
      () {
        // Formül: 100 × 1.18^(10-1) = 100 × 4.4355... = 443.55... → floor = 443
        expect(UserLevelModel.xpRequiredForLevel(10), equals(443));
      },
    );

    // GIVEN: Level = 20.
    // WHEN: xpRequiredForLevel(20) çağrılır.
    // THEN: Formüle göre hesaplanan değer dönmeli (~2321).
    test(
      'GIVEN level=20 / WHEN xpRequiredForLevel / THEN formül sonucu doğru olmalı',
      () {
        // 100 × 1.18^(20-1) = 100 × 23.2144... = 2321 → floor = 2321
        expect(UserLevelModel.xpRequiredForLevel(20), equals(2321));
      },
    );

    // GIVEN: Level = 1'den küçük değer (0).
    // WHEN: xpRequiredForLevel(0) çağrılır.
    // THEN: AssertionError fırlatılmalı (Fail Fast prensibi).
    test(
      'GIVEN level=0 (geçersiz) / WHEN xpRequiredForLevel / THEN AssertionError fırlatmalı',
      () {
        // assert(level >= 1) → debug modda AssertionError fırlatır.
        expect(
          () => UserLevelModel.xpRequiredForLevel(0),
          throwsA(isA<AssertionError>()),
        );
      },
    );

    // GIVEN: Negatif level değeri (-10).
    // WHEN: xpRequiredForLevel(-10) çağrılır.
    // THEN: AssertionError fırlatılmalı (negatif level geçersiz).
    test(
      'GIVEN level=-10 (negatif geçersiz) / WHEN xpRequiredForLevel / THEN AssertionError fırlatmalı',
      () {
        expect(
          () => UserLevelModel.xpRequiredForLevel(-10),
          throwsA(isA<AssertionError>()),
        );
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 2: levelFromTotalXp — Toplam XP'den Seviye Hesaplama
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 2. levelFromTotalXp (XP → Level Dönüşümü)', () {
    // GIVEN: totalXp = 0.
    // WHEN: levelFromTotalXp(0) çağrılır.
    // THEN: Level 1 dönmeli (başlangıç seviyesi).
    test(
      'GIVEN totalXp=0 / WHEN levelFromTotalXp / THEN level=1 dönmeli',
      () {
        expect(UserLevelModel.levelFromTotalXp(0), equals(1));
      },
    );

    // GIVEN: totalXp = 99 (Level 1 eşiğinin bir altı).
    // WHEN: levelFromTotalXp(99) çağrılır.
    // THEN: Level 1 dönmeli (henüz 2'ye geçmemeli).
    test(
      'GIVEN totalXp=99 (Level 2 eşiği altı) / WHEN levelFromTotalXp / THEN hâlâ level=1 olmalı',
      () {
        expect(UserLevelModel.levelFromTotalXp(99), equals(1));
      },
    );

    // GIVEN: totalXp = 100 (Level 1 için gereken tam XP).
    // WHEN: levelFromTotalXp(100) çağrılır.
    // THEN: Level 2 dönmeli.
    test(
      'GIVEN totalXp=100 (Level 2 eşiği) / WHEN levelFromTotalXp / THEN level=2 dönmeli',
      () {
        expect(UserLevelModel.levelFromTotalXp(100), equals(2));
      },
    );

    // GIVEN: totalXp = 218 (100 + 118 = Level 3 eşiği).
    // WHEN: levelFromTotalXp(218) çağrılır.
    // THEN: Level 3 dönmeli.
    test(
      'GIVEN totalXp=218 (Level 3 eşiği: 100+118) / WHEN levelFromTotalXp / THEN level=3 dönmeli',
      () {
        expect(UserLevelModel.levelFromTotalXp(218), equals(3));
      },
    );

    // GIVEN: totalXp = negatif değer (-50).
    // WHEN: levelFromTotalXp(-50) çağrılır.
    // THEN: Level 1 dönmeli (negatif XP'ye karşı savunmalı davranış).
    test(
      'GIVEN totalXp=-50 (negatif) / WHEN levelFromTotalXp / THEN level=1 dönmeli (savunmalı)',
      () {
        expect(UserLevelModel.levelFromTotalXp(-50), equals(1));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 3: progressPercentage — Seviye İlerleme Yüzdesi
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 3. progressPercentage (İlerleme Yüzdesi)', () {
    // GIVEN: totalXp = 0.
    // WHEN: progressPercentage(0) çağrılır.
    // THEN: 0.0 dönmeli (hiç ilerleme yok).
    test(
      'GIVEN totalXp=0 / WHEN progressPercentage / THEN 0.0 dönmeli',
      () {
        expect(UserLevelModel.progressPercentage(0), equals(0.0));
      },
    );

    // GIVEN: totalXp = 50 (Level 1'in yarısı, 50/100 = 0.5).
    // WHEN: progressPercentage(50) çağrılır.
    // THEN: 0.5 dönmeli.
    test(
      'GIVEN totalXp=50 (Level 1 yarısı) / WHEN progressPercentage / THEN 0.5 dönmeli',
      () {
        expect(UserLevelModel.progressPercentage(50), closeTo(0.5, 0.001));
      },
    );

    // GIVEN: totalXp = 100 (tam Level 2 başlangıcı).
    // WHEN: progressPercentage(100) çağrılır.
    // THEN: 0.0 dönmeli (yeni levelin başlangıcı).
    test(
      'GIVEN totalXp=100 (Level 2 başlangıcı) / WHEN progressPercentage / THEN 0.0 dönmeli',
      () {
        expect(UserLevelModel.progressPercentage(100), closeTo(0.0, 0.001));
      },
    );

    // GIVEN: totalXp = 159 (Level 2: 100 başlangıç + 118 gerekli → 59 ilerleme = 59/118 ≈ 0.5).
    // WHEN: progressPercentage(159) çağrılır.
    // THEN: ~0.5 dönmeli.
    test(
      'GIVEN totalXp=159 (Level 2 yarısı) / WHEN progressPercentage / THEN ~0.5 dönmeli',
      () {
        expect(UserLevelModel.progressPercentage(159), closeTo(0.5, 0.01));
      },
    );

    // GIVEN: totalXp çok büyük (99999).
    // WHEN: progressPercentage çağrılır.
    // THEN: 0.0 ile 1.0 arasında bir değer dönmeli (clamp).
    test(
      'GIVEN çok yüksek totalXp / WHEN progressPercentage / THEN 0.0-1.0 arasında olmalı',
      () {
        final result = UserLevelModel.progressPercentage(99999);
        expect(result, inInclusiveRange(0.0, 1.0));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 4: cumulativeXpAtLevelStart — Kümülatif XP (Level Başlangıcı)
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 4. cumulativeXpAtLevelStart (Kümülatif XP)', () {
    // GIVEN: Level = 1 (başlangıç).
    // WHEN: cumulativeXpAtLevelStart(1) çağrılır.
    // THEN: 0 dönmeli (hiç XP gerekmez).
    test(
      'GIVEN level=1 / WHEN cumulativeXpAtLevelStart / THEN 0 dönmeli',
      () {
        expect(UserLevelModel.cumulativeXpAtLevelStart(1), equals(0));
      },
    );

    // GIVEN: Level = 2.
    // WHEN: cumulativeXpAtLevelStart(2) çağrılır.
    // THEN: 100 dönmeli (Level 1 için gereken: 100).
    test(
      'GIVEN level=2 / WHEN cumulativeXpAtLevelStart / THEN 100 dönmeli',
      () {
        expect(UserLevelModel.cumulativeXpAtLevelStart(2), equals(100));
      },
    );

    // GIVEN: Level = 3.
    // WHEN: cumulativeXpAtLevelStart(3) çağrılır.
    // THEN: 218 dönmeli (100 + 118 = 218).
    test(
      'GIVEN level=3 / WHEN cumulativeXpAtLevelStart / THEN 218 dönmeli (100+118)',
      () {
        expect(UserLevelModel.cumulativeXpAtLevelStart(3), equals(218));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 5: xpToNextLevel — Sonraki Seviye İçin Gereken XP
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 5. xpToNextLevel (Sonraki Seviye Mesafesi)', () {
    // GIVEN: totalXp = 0 (Level 1 başı).
    // WHEN: xpToNextLevel(0) çağrılır.
    // THEN: Level 2 için 100 XP gerekli.
    test(
      'GIVEN totalXp=0 / WHEN xpToNextLevel / THEN 100 XP gerekli',
      () {
        expect(UserLevelModel.xpToNextLevel(0), equals(100));
      },
    );

    // GIVEN: totalXp = 50 (Level 1 yarısında).
    // WHEN: xpToNextLevel(50) çağrılır.
    // THEN: 50 XP daha gerekli.
    test(
      'GIVEN totalXp=50 (Level 1 ortası) / WHEN xpToNextLevel / THEN 50 XP gerekli',
      () {
        expect(UserLevelModel.xpToNextLevel(50), equals(50));
      },
    );

    // GIVEN: totalXp = 100 (tam Level 2 başlangıcı).
    // WHEN: xpToNextLevel(100) çağrılır.
    // THEN: Level 3 için 118 XP gerekli (Level 2'nin gerektirdiği miktarın tamamı).
    test(
      'GIVEN totalXp=100 (Level 2 başı) / WHEN xpToNextLevel / THEN 118 XP gerekli',
      () {
        expect(UserLevelModel.xpToNextLevel(100), equals(118));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 6: tierFromLevel — Seviye Kademesi (Tier)
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 6. tierFromLevel (Seviye Kademesi)', () {
    // GIVEN: Level 1-5 → Rookie (Çaylak).
    test('GIVEN level=1 / WHEN tierFromLevel / THEN PlayerTier.rookie dönmeli', () {
      expect(UserLevelModel.tierFromLevel(1), equals(PlayerTier.rookie));
    });
    test('GIVEN level=5 / WHEN tierFromLevel / THEN PlayerTier.rookie dönmeli', () {
      expect(UserLevelModel.tierFromLevel(5), equals(PlayerTier.rookie));
    });

    // GIVEN: Level 6-15 → Beginner.
    test('GIVEN level=6 / WHEN tierFromLevel / THEN PlayerTier.beginner dönmeli', () {
      expect(UserLevelModel.tierFromLevel(6), equals(PlayerTier.beginner));
    });
    test('GIVEN level=15 / WHEN tierFromLevel / THEN PlayerTier.beginner dönmeli', () {
      expect(UserLevelModel.tierFromLevel(15), equals(PlayerTier.beginner));
    });

    // GIVEN: Level 16-35 → Intermediate.
    test('GIVEN level=16 / WHEN tierFromLevel / THEN PlayerTier.intermediate dönmeli', () {
      expect(UserLevelModel.tierFromLevel(16), equals(PlayerTier.intermediate));
    });

    // GIVEN: Level 36-60 → Advanced.
    test('GIVEN level=36 / WHEN tierFromLevel / THEN PlayerTier.advanced dönmeli', () {
      expect(UserLevelModel.tierFromLevel(36), equals(PlayerTier.advanced));
    });

    // GIVEN: Level 61+ → Elite.
    test('GIVEN level=61 / WHEN tierFromLevel / THEN PlayerTier.elite dönmeli', () {
      expect(UserLevelModel.tierFromLevel(61), equals(PlayerTier.elite));
    });
    test('GIVEN level=100 / WHEN tierFromLevel / THEN PlayerTier.elite dönmeli', () {
      expect(UserLevelModel.tierFromLevel(100), equals(PlayerTier.elite));
    });
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 7: ENTEGRASYON — 20 Dakika + 3 Günlük Streak Senaryosu
  //
  // Bu test, XP hesaplama sisteminin uçtan uca tutarlılığını doğrular.
  // XP sistemi backend'de (Supabase RPC) hesaplandığından, burada
  // "hesaplama motoru" olan UserLevelModel'ın tutarlı çalıştığını kanıtlarız.
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 7. Entegrasyon (20 Dakika + 3 Streak Senaryosu)', () {
    // GIVEN: Kullanıcı 20 dakika (1200 sn) antrenman yaptı.
    //        3 günlük streak'i var.
    //        Sistem 350 XP ödüllendirdi (backend simülasyonu).
    //        Kullanıcının önceki toplam XP'si 80'di.
    //        Sonraki toplam XP: 80 + 350 = 430 XP.
    // WHEN: levelFromTotalXp(430) hesaplanır.
    // THEN: Level 4 olmalı.
    //       Kümülatif: L1(100) + L2(118) + L3(139) = 357 < 430 → Level 4 içinde.
    test(
      'GIVEN 350 XP kazanıldı (80+350=430) / WHEN levelFromTotalXp / THEN level=4 olmalı',
      () {
        const previousXp = 80;
        const earnedXp = 350; // Backend'in hesapladığı ödül (simüle)
        const totalXp = previousXp + earnedXp;

        final level = UserLevelModel.levelFromTotalXp(totalXp);

        // Kümülatif eşikler: L1→L2:100, L2→L3:118, L3→L4:139 → toplam:357
        // 430 > 357 → Level 4 içinde.
        expect(level, equals(4));
      },
    );

    // GIVEN: totalXp = 430, level = 3.
    // WHEN: progressPercentage(430) hesaplanır.
    // THEN: Level 3 içinde ilerleme doğru hesaplanmalı.
    //       L3 başlangıcı: 218 XP. L3 için gereken: xpRequiredForLevel(3) = 139.
    //       İlerleme: (430 - 218) / 139 = 212 / 139 ≈ 1.0 (sınır: clamp 1.0)
    //       NOT: 430 > 218 + 139 = 357 → demek ki 430 Level 4'e geçiyor!
    //       levelFromTotalXp(430) kontrolü: L1:100, L2:118, L3:139 → toplam 357. 430>357 → Level 4.
    test(
      'GIVEN totalXp=430 / WHEN levelFromTotalXp / THEN kesin level hesaplanmalı',
      () {
        // Gerçek kümülatif hesaplama:
        // L1→L2: 100 XP gerekli (cumulative: 100)
        // L2→L3: 118 XP gerekli (cumulative: 218)
        // L3→L4: 139 XP gerekli (cumulative: 357)
        // L4→L5: ~164 XP gerekli (cumulative: ~521)
        // 430 XP → 357 < 430 < 521 → Level 4
        expect(UserLevelModel.levelFromTotalXp(430), equals(4));
      },
    );

    // GIVEN: totalXp = 430, level = 4.
    // WHEN: xpToNextLevel(430) hesaplanır.
    // THEN: Level 4 → Level 5 için gereken XP doğru hesaplanmalı.
    //       L4 başlangıcı: 357. L4 gerekli: 164. Hedef: 357+164=521.
    //       Kalan: 521 - 430 = 91 XP.
    test(
      'GIVEN totalXp=430 (Level 4) / WHEN xpToNextLevel / THEN 91 XP kaldı olmalı',
      () {
        final remaining = UserLevelModel.xpToNextLevel(430);
        // L4 eşiği: 357, L4 için gereken: 164, hedef: 521
        // 521 - 430 = 91
        expect(remaining, equals(91));
      },
    );

    // GIVEN: Level 3'teki kullanıcı.
    // WHEN: tierFromLevel(3) çağrılır.
    // THEN: PlayerTier.rookie olmalı (Level 1-5 arası).
    test(
      'GIVEN level=3 / WHEN tierFromLevel / THEN PlayerTier.rookie (Çaylak) olmalı',
      () {
        expect(UserLevelModel.tierFromLevel(3), equals(PlayerTier.rookie));
      },
    );

    // GIVEN: Streak bonusu hesaplama tutarlılık testi.
    //        Backend 3 günlük streak için %20 bonus uygular (bilgi amaçlı).
    //        Temel XP = 200 (20 dk antrenman), streak bonus = +40 XP → toplam = 240 XP.
    //        Kullanıcının önceki XP: 0. Yeni XP: 240.
    // WHEN: 240 XP için level hesaplanır.
    // THEN: Level 3 olmalı (L1:100, L2:118 → 218 < 240 < 357 → L3).
    test(
      'GIVEN streak bonuslu 240 XP / WHEN levelFromTotalXp / THEN level=3 olmalı',
      () {
        const baseXp = 200; // 20 dk çalışma tabanı (simüle)
        const streakBonus = 40; // 3 günlük streak %20 bonus
        const totalXp = baseXp + streakBonus;

        expect(UserLevelModel.levelFromTotalXp(totalXp), equals(3));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 8: kDailyXpCap ve kSessionXpCap SABİTLERİ
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 8. XP Cap Sabitleri', () {
    // GIVEN: Günlük cap sabiti.
    // WHEN: kDailyXpCap değeri okunur.
    // THEN: 1500 olmalı.
    test(
      'GIVEN kDailyXpCap / WHEN değer okunur / THEN 1500 olmalı',
      () {
        expect(kDailyXpCap, equals(1500));
      },
    );

    // GIVEN: Seans başına cap sabiti.
    // WHEN: kSessionXpCap değeri okunur.
    // THEN: 500 olmalı.
    test(
      'GIVEN kSessionXpCap / WHEN değer okunur / THEN 500 olmalı',
      () {
        expect(kSessionXpCap, equals(500));
      },
    );

    // GIVEN: kDailyXpCap ve kSessionXpCap mantıksal ilişkisi.
    // WHEN: Değerler karşılaştırılır.
    // THEN: Günlük cap, seans cap'inden büyük olmalı (mantıksal tutarlılık).
    test(
      'GIVEN XP cap sabitleri / WHEN karşılaştırılır / THEN günlük cap > seans cap olmalı',
      () {
        expect(kDailyXpCap, greaterThan(kSessionXpCap));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GRUP 9: generateLevelTable — Tablo Doğruluğu
  // ───────────────────────────────────────────────────────────────────────────

  group('XpCalculator — 9. generateLevelTable (Seviye Tablosu)', () {
    // GIVEN: 5 seviyeye kadar bir tablo oluştur.
    // WHEN: generateLevelTable(upToLevel: 5) çağrılır.
    // THEN: 5 kayıt dönmeli ve her kayıt doğru level numarasını içermeli.
    test(
      'GIVEN upToLevel=5 / WHEN generateLevelTable / THEN 5 kayıt ve doğru level numaraları dönmeli',
      () {
        final table = UserLevelModel.generateLevelTable(upToLevel: 5);
        expect(table.length, equals(5));
        for (int i = 0; i < 5; i++) {
          expect(table[i]['level'], equals(i + 1));
        }
      },
    );

    // GIVEN: Tablo Level 1 verisi.
    // WHEN: İlk tablonun xp_for_level değeri okunur.
    // THEN: 100 olmalı (taban değer).
    test(
      'GIVEN tablo Level 1 / WHEN xp_for_level / THEN 100 olmalı',
      () {
        final table = UserLevelModel.generateLevelTable(upToLevel: 3);
        expect(table[0]['xp_for_level'], equals(100));
      },
    );

    // GIVEN: Tablo Level 2 kümülatif XP.
    // WHEN: İkinci kaydın cumulative_xp değeri okunur.
    // THEN: 218 olmalı (100 + 118 = 218).
    test(
      'GIVEN tablo Level 2 / WHEN cumulative_xp / THEN 218 olmalı (100+118)',
      () {
        final table = UserLevelModel.generateLevelTable(upToLevel: 3);
        expect(table[1]['cumulative_xp'], equals(218));
      },
    );
  });
}
