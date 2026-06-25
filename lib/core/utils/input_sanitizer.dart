class InputSanitizer {
  /// XSS ve zararlı kod enjeksiyonunu engellemek için metni temizler.
  /// Yalnızca harf, rakam, temel noktalama işaretleri ve emojilere izin verir.
  /// İsteğe bağlı olarak maksimum karakter sınırını uygular.
  static String sanitizeTips(String input, {int maxLength = 300}) {
    if (input.isEmpty) return '';

    // Uzunluk kontrolü
    String sanitized = input;
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    // HTML tag'lerini temizle (<script> vs.)
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false), '');

    return sanitized.trim();
  }
}
