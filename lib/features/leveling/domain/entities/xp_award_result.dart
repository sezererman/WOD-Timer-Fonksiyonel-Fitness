/// Supabase `calculate_and_award_xp` RPC yanıtını temsil eden value object.
///
/// Parse mantığı data katmanında — BLoC yalnızca typed değerleri tüketir (SRP).
class XpAwardResult {
  /// Bu seans için verilen XP miktarı. 0 ise ödül verilmemiş demektir.
  final int xpAwarded;

  /// RPC sonrasındaki toplam XP.
  final int newTotalXp;

  /// Yeni seviye numarası.
  final int newLevel;

  /// Önceki seviye numarası.
  final int oldLevel;

  /// Seviye atlandı mı?
  final bool leveledUp;

  /// XP dağılım detayları (kategori → miktar).
  final Map<String, int> xpBreakdown;

  const XpAwardResult({
    required this.xpAwarded,
    required this.newTotalXp,
    required this.newLevel,
    required this.oldLevel,
    required this.leveledUp,
    required this.xpBreakdown,
  });

  /// Supabase RPC'nin döndürdüğü ham [Map]'ten [XpAwardResult] oluşturur.
  factory XpAwardResult.fromMap(Map<String, dynamic> map, {required int fallbackLevel}) {
    return XpAwardResult(
      xpAwarded: map['xp_awarded'] as int? ?? 0,
      newTotalXp: map['new_total_xp'] as int? ?? 0,
      newLevel: map['new_level'] as int? ?? fallbackLevel,
      oldLevel: map['old_level'] as int? ?? fallbackLevel,
      leveledUp: map['leveled_up'] as bool? ?? false,
      xpBreakdown: _parseBreakdown(map['xp_breakdown']),
    );
  }

  static Map<String, int> _parseBreakdown(dynamic raw) {
    if (raw == null) return {};
    final map = Map<String, dynamic>.from(raw as Map);
    return map.map((k, v) => MapEntry(k, (v as num).toInt()));
  }
}
