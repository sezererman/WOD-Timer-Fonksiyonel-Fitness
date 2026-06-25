import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_constants.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/widgets/custom_password_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState!.validate()) {
      // Not: AuthBloc/AuthRepository 'name' parametresini destekliyorsa eklenebilir.
      // Şimdilik standart email/password register event'i tetikleniyor.
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          _emailController.text.trim(),
          _passwordController.text,
        ),
      );
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-posta alanı boş bırakılamaz';
    }
    // Basit bir e-posta regex'i
    final emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir e-posta adresi girin';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre alanı boş bırakılamaz';
    }
    // En az 8 karakter, 1 büyük harf, 1 rakam
    final passwordRegex = RegExp(
      r'^(?=.*[A-Z])(?=.*\d)[A-Za-z\d!@#$%^&*()_+{}|:<>?~,-.]{8,}$',
    );
    if (!passwordRegex.hasMatch(value)) {
      return 'Şifre en az 8 karakter, 1 büyük harf ve 1 rakam içermelidir';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre onayı boş bırakılamaz';
    }
    if (value != _passwordController.text) {
      return 'Şifreler birbiriyle eşleşmiyor';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Tema renklerini çekiyoruz (CrossFit teması, koyu arkaplan, primer renkler)
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Üye Ol',
          style: TextStyle(fontFamily: 'Orbitron', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            // Güvenlik prensiplerine uygun (detaysız ama anlaşılır) hata mesajı
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Kayıt işlemi başarısız. Lütfen bilgilerinizi kontrol edip tekrar deneyin.',
                ),
                backgroundColor: Colors.redAccent,
              ),
            );
          } else if (state is Authenticated) {
            // Kayıt başarılıysa doğrudan timer sayfasına yönlendir
            context.go(Routes.timer);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.fitness_center_rounded,
                      size: 64,
                      color: Colors.amber, // veya temanızın primary rengi
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Aramıza Katıl',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Antrenmanlarını kaydetmek ve topluluğa katılmak için bir hesap oluştur.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Ad Soyad Alanı
                    TextFormField(
                      controller: _nameController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Ad Soyad',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                          ? 'Ad soyad boş bırakılamaz'
                          : null,
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 20),

                    // E-posta Alanı
                    TextFormField(
                      controller: _emailController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'E-posta',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 20),

                    // Şifre Alanı
                    CustomPasswordField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      validator: _validatePassword,
                    ),
                    const SizedBox(height: 20),

                    // Şifreyi Onayla Alanı
                    CustomPasswordField(
                      controller: _confirmPasswordController,
                      enabled: !isLoading,
                      labelText: 'Şifreyi Onayla',
                      prefixIcon: Icons.lock_reset_outlined,
                      validator: _validateConfirmPassword,
                      showStrengthIndicator:
                          false, // Onay alanında çubuğa gerek yok
                    ),
                    const SizedBox(height: 32),

                    // Kayıt Butonu
                    ElevatedButton(
                      onPressed: isLoading ? null : _onRegisterPressed,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Üye Ol',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),

                    // Login'e Dönüş Butonu
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () => context.go(Routes.login),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Zaten bir hesabın var mı? Giriş Yap',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
