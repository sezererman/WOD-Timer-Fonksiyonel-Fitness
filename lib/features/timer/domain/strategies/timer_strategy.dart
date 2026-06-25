/// Zamanlayıcı davranışlarını soyutlayan arayüz (Strategy Pattern).
abstract class TimerStrategy {
  /// Ekran üzerinde gösterilecek süreyi hesaplar.
  int calculateDisplayTime(int totalSeconds, int elapsedSeconds);

  /// Fazın bitip bitmediğini kontrol eder.
  bool isFinished(int totalSeconds, int elapsedSeconds);
}

/// Standart geri sayım stratejisi (AMRAP, TABATA, EMOM için).
class CountdownStrategy implements TimerStrategy {
  const CountdownStrategy();

  @override
  int calculateDisplayTime(int totalSeconds, int elapsedSeconds) {
    final remaining = totalSeconds - elapsedSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  bool isFinished(int totalSeconds, int elapsedSeconds) {
    return elapsedSeconds >= totalSeconds;
  }
}

/// İleri sayım stratejisi (FOR TIME için).
class CountupStrategy implements TimerStrategy {
  const CountupStrategy();

  @override
  int calculateDisplayTime(int totalSeconds, int elapsedSeconds) {
    return elapsedSeconds;
  }

  @override
  bool isFinished(int totalSeconds, int elapsedSeconds) {
    // totalSeconds burada Time Cap görevi görür. 0 ise sınır yoktur.
    if (totalSeconds <= 0) return false;
    return elapsedSeconds >= totalSeconds;
  }
}
