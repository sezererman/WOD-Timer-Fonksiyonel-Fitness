import '../../domain/entities/badge.dart';

class BadgeModel extends Badge {
  const BadgeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.iconAsset,
    required super.earnedDate,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      // Eğer DB'den geliyorsa 'icon_url', local'den geliyorsa 'iconAsset' vs
      iconAsset: (json['icon_url'] ?? json['iconAsset'] ?? '') as String,
      earnedDate: json['earned_at'] != null 
          ? DateTime.parse(json['earned_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon_url': iconAsset,
      'earned_at': earnedDate.toIso8601String(),
    };
  }

  /// Supabase user_badges tablosuna kaydetmek için model.
  Map<String, dynamic> toUserBadgeJson(String userId) {
    return {
      'user_id': userId,
      'badge_id': id,
      'earned_at': earnedDate.toIso8601String(),
    };
  }
}
