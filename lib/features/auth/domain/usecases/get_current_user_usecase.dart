import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Mevcut oturum açmış kullanıcıyı döndüren UseCase.
///
/// [AuthBloc]'un doğrudan [AuthRepository]'ye bağlı olmasını önler (DIP).
/// Oturum yoksa `null` döner.
class GetCurrentUserUseCase extends UseCase<UserEntity?, NoParams> {
  final AuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  @override
  Future<UserEntity?> call(NoParams params) => _repository.getCurrentUser();
}
