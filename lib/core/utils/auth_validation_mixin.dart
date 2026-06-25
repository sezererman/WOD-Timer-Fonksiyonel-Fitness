mixin AuthValidationMixin {
  /// E-posta formatının geçerliliğini kontrol eder.
  String? validateEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'E-posta adresi boş bırakılamaz.';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }

    return null; // Valid
  }

  /// Şifrenin güvenlik kurallarına uygunluğunu kontrol eder.
  /// En az 8 karakter, bir büyük harf ve bir rakam içermelidir.
  String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Şifre alanı boş bırakılamaz.';
    }

    if (password.length < 8) {
      return 'Şifre en az 8 karakter uzunluğunda olmalıdır.';
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    if (!hasUppercase) {
      return 'Şifre en az bir büyük harf içermelidir.';
    }

    final hasDigits = RegExp(r'[0-9]').hasMatch(password);
    if (!hasDigits) {
      return 'Şifre en az bir rakam içermelidir.';
    }

    return null; // Valid
  }
}
