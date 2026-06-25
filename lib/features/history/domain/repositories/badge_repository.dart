import '../entities/badge.dart';

/// Rozet verilerine erişimi soyutlayan repository arayüzü.
/// HistoryBloc bu arayüzü UseCase üzerinden kullanır —
/// hiçbir zaman Data katmanına (BadgeLocalDatasource) doğrudan bağlanmaz.
abstract class BadgeRepository {
  /// Daha önce kazanılmış rozetleri getirir.
  Future<List<Badge>> getEarnedBadges();

  /// Yeni kazanılan bir rozeti kaydeder.
  Future<void> saveBadge(Badge badge);
}
