/// OWASP Girdi Doğrulama (Input Validation) kurallarına uygun güvenlik yardımcı sınıfı.
class SanitizationUtils {
  SanitizationUtils._();

  /// Kullanıcı girdisini (örn. Özel Antrenman Adı) SQL Injection ve 
  /// XSS (Cross-Site Scripting) saldırılarına karşı temizler.
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    // 1. Zararlı olabilecek özel karakterleri (HTML tagları, script tagları) temizle
    var sanitized = input.replaceAll(RegExp(r'<[^>]*>'), '');

    // 2. SQL Injection için kritik olabilecek karakterleri escape et veya sil
    sanitized = sanitized.replaceAll(RegExp(r'''['";\-/]'''), '');

    // 3. Sadece alfasayısal, boşluk ve zararsız Türkçe karakterlere izin ver
    // Örn: 'A-Z', 'a-z', '0-9', ' ', '.', ',', '-', '_', ve Türkçe karakterler
    sanitized = sanitized.replaceAll(RegExp(r'[^a-zA-Z0-9\s.,\-_çÇğĞıİöÖşŞüÜ]'), '');

    return sanitized.trim();
  }

  /// Yorumlar için XSS sanitization (Emojilere izin verir)
  static String sanitizeComment(String input) {
    if (input.isEmpty) return input;
    
    // 1. Karakter Sınırı: Maksimum 250 karakter
    var sanitized = input.length > 250 ? input.substring(0, 250) : input;

    // 2. Tehlikeli HTML/Script tag'lerini tamamen kaldır (XSS koruması)
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // 3. Sadece harf, rakam, temel noktalama işaretleri ve Unicode (emojiler dahil) karakterlere izin ver
    // Özel semboller (script injection yapabilecek) kısıtlanır.
    // Emoji pattern'i çok geniştir, bu sebeple "sadece istenmeyenleri silmek" (blacklisting) 
    // yerine zararlı olabilecek '<', '>', '{', '}' gibi karakterleri silmek daha güvenlidir.
    sanitized = sanitized.replaceAll(RegExp(r'[<>\{\}\\]'), '');

    return sanitized.trim();
  }

  /// E-posta doğrulama (Eğer profil sistemi eklenirse)
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  }

  /// Sadece rakamlardan oluşan input doğrulama
  static bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }
}
