import '../../domain/entities/badge.dart';
import '../../domain/repositories/badge_repository.dart';
import '../datasources/badge_local_datasource.dart';

/// BadgeRepository'nin Hive tabanlı implementasyonu.
/// Data katmanı burada kapsülleniyor — BLoC bu sınıfı doğrudan bilmez.
class BadgeRepositoryImpl implements BadgeRepository {
  final BadgeLocalDatasource _localDatasource;

  const BadgeRepositoryImpl(this._localDatasource);

  @override
  Future<List<Badge>> getEarnedBadges() => _localDatasource.getEarnedBadges();

  @override
  Future<void> saveBadge(Badge badge) => _localDatasource.saveBadge(badge);
}
