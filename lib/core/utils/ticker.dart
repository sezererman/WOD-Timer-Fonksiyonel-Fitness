/// Stream tabanlı zamanlayıcı.
///
/// PERFORMANS: `Stream.periodic` platform-native timer kullanır.
/// Önceki `async* + Future.delayed(100ms)` yaklaşımı her 100ms'de
/// Dart event loop'una giriyordu (saniyede 10 mikrotask).
/// `Stream.periodic` + `.distinct()` ile event loop kirliliği sıfır,
/// GC pressure tamamen ortadan kalktı.
///
/// `startElapsed` parametresi pause/resume senaryolarında offset'i
/// doğru taşır — drift bug'ı olmadan kaldığı yerden devam eder.
class Ticker {
  const Ticker();

  /// Saniye bazında geçen süreyi yayınlar.
  ///
  /// [startElapsed] — Pause sonrası resume için başlangıç offset'i.
  /// Normal başlatmada `0` (varsayılan), resume'da `elapsedSoFar` geçilir.
  Stream<int> tick({int startElapsed = 0}) {
    final startTime = DateTime.now();
    return Stream.periodic(const Duration(seconds: 1), (_) {
      return startElapsed + DateTime.now().difference(startTime).inSeconds;
    }).distinct(); // Aynı saniyeyi iki kez yayınlama (saat precision kayması)
  }
}
