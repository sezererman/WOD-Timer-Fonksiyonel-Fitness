import 'package:hive_ce/hive.dart';
import '../../../../core/utils/security_service.dart';
import '../../domain/entities/badge.dart';

class BadgeLocalDatasource {
  static const String _boxName = 'earned_badges';
  final SecurityService _securityService;

  BadgeLocalDatasource(this._securityService);

  Future<Box<Map>> get _box async {
    final key = await _securityService.getEncryptionKey();
    return Hive.openBox<Map>(
      _boxName,
      encryptionCipher: HiveAesCipher(key),
    );
  }

  Future<List<Badge>> getEarnedBadges() async {
    final box = await _box;
    return box.values.map((data) {
      final map = Map<String, dynamic>.from(data);
      return Badge(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        iconAsset: map['iconAsset'] as String,
        earnedDate: DateTime.parse(map['earnedDate'] as String),
      );
    }).toList();
  }

  Future<void> saveBadge(Badge badge) async {
    final box = await _box;
    await box.put(badge.id, {
      'id': badge.id,
      'title': badge.title,
      'description': badge.description,
      'iconAsset': badge.iconAsset,
      'earnedDate': badge.earnedDate.toIso8601String(),
    });
  }
}
