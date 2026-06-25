import 'dart:async';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class ListenAuthStateChangeUseCase {
  final AuthRepository repository;

  ListenAuthStateChangeUseCase(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}
