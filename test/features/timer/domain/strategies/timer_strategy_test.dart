import 'package:flutter_test/flutter_test.dart';
import 'package:fonksiyonel_fitness_timer/features/timer/domain/strategies/timer_strategy.dart';

void main() {
  group('CountdownStrategy', () {
    const strategy = CountdownStrategy();

    test('toplam 60sn, geçen 10sn ise 50sn dönmeli', () {
      expect(strategy.calculateDisplayTime(60, 10), 50);
    });

    test('süre bittiğinde 0 dönmeli ve negatif olmamalı', () {
      expect(strategy.calculateDisplayTime(60, 70), 0);
    });

    test('geçen süre toplam süreye eşitse isFinished true dönmeli', () {
      expect(strategy.isFinished(60, 60), true);
    });

    test('geçen süre toplam süreden küçükse isFinished false dönmeli', () {
      expect(strategy.isFinished(60, 59), false);
    });
  });

  group('CountupStrategy', () {
    const strategy = CountupStrategy();

    test('toplam 60sn, geçen 10sn ise 10sn dönmeli (İleri Sayım)', () {
      expect(strategy.calculateDisplayTime(60, 10), 10);
    });

    test('süre sınırı yoksa (0) isFinished her zaman false dönmeli', () {
      expect(strategy.isFinished(0, 999), false);
    });

    test('süre sınırına (Time Cap) ulaşıldığında isFinished true dönmeli', () {
      expect(strategy.isFinished(60, 60), true);
    });
  });
}
