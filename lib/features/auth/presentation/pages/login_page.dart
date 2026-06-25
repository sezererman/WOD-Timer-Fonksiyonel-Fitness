import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_constants.dart';
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            _emailController.text,
            _passwordController.text,
          ),
        );
  }

  void _onDummyLoginPressed() {
    context.read<AuthBloc>().add(
          const AuthLoginRequested('dummy@dummy.com', 'Password1'),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Giriş')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is Authenticated) {
            // GoRouter'ın redirect mekanizması otomatik olarak ana sayfaya yönlendirecektir.
            // Bu nedenle manuel bir Navigator push işlemine gerek yoktur.
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Giriş Yap', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Şifre',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),
                  if (state is AuthLoading)
                    const CircularProgressIndicator()
                  else ...[
                    ElevatedButton(
                      onPressed: _onLoginPressed,
                      style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      child: const Text('Giriş Yap'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _onDummyLoginPressed,
                      style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      child: const Text('Login Dummy'),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.go(Routes.register);
                      },
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text(
                        'Hesabın yok mu? Üye Ol',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber, // Daha görünür olması için temanın ana rengi
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        context.go(Routes.timer);
                      },
                      style: TextButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
                      child: const Text(
                        'Giriş Yapmadan Devam Et',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
