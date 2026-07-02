/// Duration üzerinde yardımcı extension'lar.
extension DurationExtensions on Duration {
  /// "MM:SS" formatında string döndürür.
  String get formatted {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// "HH:MM:SS" formatında string döndürür.
  String get formattedLong {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}

/// int (saniye) üzerinde yardımcı extension.
extension IntDurationExtension on int {
  Duration get seconds => Duration(seconds: this);
  Duration get minutes => Duration(minutes: this);
}
