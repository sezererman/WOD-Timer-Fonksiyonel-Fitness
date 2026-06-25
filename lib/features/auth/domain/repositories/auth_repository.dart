import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> register(String email, String password);
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Stream<UserEntity?> get authStateChanges;
}
