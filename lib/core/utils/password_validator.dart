/// Şifre gücünü hesaplayan saf Dart fonksiyonu.
/// Kriterler:
/// 1. En az 8 karakter
/// 2. En az 1 büyük harf
/// 3. En az 1 rakam
/// 4. En az 1 özel karakter
///
/// Dönüş değeri: 0.0 ile 1.0 arasında bir değer (Her kriter 0.25 puan).
double calculatePasswordStrength(String password) {
  if (password.isEmpty) return 0.0;

  double strength = 0.0;

  if (password.length >= 8) strength += 0.25;
  if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
  if (RegExp(r'\d').hasMatch(password)) strength += 0.25;
  if (RegExp(r'[!@#$%^&*(),.?":{}|<>\-_=+\/\\[\]~]').hasMatch(password)) strength += 0.25;

  return strength;
}
