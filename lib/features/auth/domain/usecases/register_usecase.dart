import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;

  const RegisterParams({required this.email, required this.password});
}

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) {
    return repository.register(params.email, params.password);
  }
}
