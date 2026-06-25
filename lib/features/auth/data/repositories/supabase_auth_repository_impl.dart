import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../datasources/auth_local_datasource.dart';

class SupabaseAuthRepositoryImpl implements AuthRepository {
  final supabase.SupabaseClient supabaseClient;
  final AuthLocalDataSource localDataSource;

  SupabaseAuthRepositoryImpl({
    required this.supabaseClient,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthFailure('Giriş başarısız: Kullanıcı bulunamadı.');
      }
      final userModel = UserModel.fromSupabaseUser(response.user!);
      await localDataSource.cacheUser(userModel);
      return userModel;
    } on supabase.AuthException catch (e) {
      throw AuthFailure('Kimlik Doğrulama Hatası: ${e.message}');
    } on supabase.PostgrestException catch (e) {
      throw ServerFailure('Veritabanı Hatası: ${e.message}');
    } catch (e) {
      throw const UnexpectedFailure('Giriş yapılırken beklenmeyen bir hata oluştu.');
    }
  }

  @override
  Future<UserEntity> register(String email, String password) async {
    try {
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthFailure('Kayıt işlemi tamamlanamadı.');
      }
      final userModel = UserModel.fromSupabaseUser(response.user!);
      await localDataSource.cacheUser(userModel);
      return userModel;
    } on supabase.AuthException catch (e) {
      throw AuthFailure('Kayıt Hatası: ${e.message}');
    } on supabase.PostgrestException catch (e) {
      throw ServerFailure('Sunucu Hatası: ${e.message}');
    } catch (e) {
      throw const UnexpectedFailure('Kayıt olurken beklenmeyen bir hata oluştu.');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await supabaseClient.auth.signOut();
      await localDataSource.clearCache();
    } on supabase.AuthException catch (e) {
      throw AuthFailure('Çıkış yapılamadı: ${e.message}');
    } on supabase.PostgrestException catch (e) {
      throw ServerFailure('Sunucu Hatası: ${e.message}');
    } catch (e) {
      throw const UnexpectedFailure('Çıkış yapılırken bir hata oluştu.');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        final user = UserModel.fromSupabaseUser(session.user);
        await localDataSource.cacheUser(user);
        return user;
      }
      return await localDataSource.getCachedUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return supabaseClient.auth.onAuthStateChange.map((authState) {
      final session = authState.session;
      if (session != null) {
        return UserModel.fromSupabaseUser(session.user);
      }
      return null;
    });
  }
}
