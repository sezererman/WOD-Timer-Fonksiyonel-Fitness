/// Süre formatlama yardımcıları.
class DurationFormatter {
  DurationFormatter._();

  /// Saniyeyi "MM:SS" formatına çevirir.
  /// Örnek: 125 → "02:05"
  static String format(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Saniyeyi "HH:MM:SS" formatına çevirir (1 saatten uzun süreler için).
  /// Örnek: 3725 → "01:02:05"
  static String formatLong(int totalSeconds) {
    if (totalSeconds < 3600) return format(totalSeconds);
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Duration nesnesinden "MM:SS" string döndürür.
  static String fromDuration(Duration duration) {
    return format(duration.inSeconds);
  }
}
