import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthException('E-posta veya şifre hatalı.');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } catch (e) {
      // Credential Stuffing'i önlemek için generic mesaj dönüyoruz.
      throw const AuthException('E-posta veya şifre hatalı.');
    }
  }

  @override
  Future<UserModel> register(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthException('Kayıt işlemi başarısız oldu.');
      }
      return UserModel.fromSupabaseUser(response.user!);
    } on AuthException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
    } catch (e) {
      throw AuthException('Çıkış yapılırken bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        return UserModel.fromSupabaseUser(session.user);
      }
      return null;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}
