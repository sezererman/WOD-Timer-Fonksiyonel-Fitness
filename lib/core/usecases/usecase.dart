/// Soyut UseCase sınıfı.
/// Her UseCase tek bir iş kuralını temsil eder.
///
/// [Type] — dönüş tipi
/// [Params] — parametre tipi (parametre yoksa [NoParams] kullanılır)
abstract class UseCase<T, Params> {
  Future<T> call(Params params);
}

/// Parametre gerektirmeyen UseCase'ler için.
class NoParams {
  const NoParams();
}
