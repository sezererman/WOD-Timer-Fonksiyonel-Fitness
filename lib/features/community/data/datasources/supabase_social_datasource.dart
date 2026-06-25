import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';

class SupabaseSocialDataSource {
  final SupabaseClient supabaseClient;

  SupabaseSocialDataSource({required this.supabaseClient});

  /// 1. Pagination (Sayfalama) ile Antrenman Akışını Getirme
  /// [page] parametresi 0'dan başlar.
  Future<List<Map<String, dynamic>>> getFeedPosts({
    required int page,
    int limit = 10,
  }) async {
    final int offset = page * limit;
    try {
      // Performans: JOIN mantığı ile 'users' tablosundan sadece isim ve avatar çekiliyor.
      // Not: Bu işlemin çalışması için public şemasında user_id'ye referans veren bir 'users' tablonuz (veya view) olmalıdır.
      final response = await supabaseClient
          .from('shared_workouts')
          .select('*, users(name, avatar_url, user_xp_profiles(current_level))')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1); // Örn: 0. sayfa -> 0-9

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw const DatabaseException('Sosyal akış yüklenirken bir hata oluştu.');
    }
  }

  /// 2. Realtime (Gerçek Zamanlı): Belirli bir gönderinin YORUMLARINI dinleme
  /// Herhangi birisi yorum yaptığında (INSERT, UPDATE, DELETE), UI'ı anında günceller.
  Stream<List<Map<String, dynamic>>> listenToComments(String workoutId) {
    try {
      return supabaseClient
          .from('comments')
          .stream(primaryKey: ['id'])
          .eq('workout_id', workoutId)
          .order('created_at', ascending: true);
    } catch (e) {
      throw const DatabaseException('Yorum akışı dinlenemiyor.');
    }
  }

  /// 2. Realtime (Gerçek Zamanlı): Belirli bir gönderinin BEĞENİLERİNİ dinleme
  /// Beğeni eklendiğinde veya silindiğinde anında tetiklenir.
  Stream<List<Map<String, dynamic>>> listenToLikes(String workoutId) {
    try {
      return supabaseClient
          .from('likes')
          .stream(primaryKey: ['id'])
          .eq('workout_id', workoutId);
    } catch (e) {
      throw const DatabaseException('Beğeni akışı dinlenemiyor.');
    }
  }

  /// Ekstra Opsiyon: Eğer Yorumları Çekerken de JOIN yapmak isterseniz
  /// Stream'ler JOIN desteklemez. JOIN'li halini normal future olarak sayfalama ile çekebilirsiniz.
  Future<List<Map<String, dynamic>>> getCommentsWithUsers({
    required String workoutId,
    required int page,
    int limit = 10,
  }) async {
    final int offset = page * limit;
    try {
      final response = await supabaseClient
          .from('comments')
          .select('*, users(name, avatar_url)')
          .eq('workout_id', workoutId)
          .order('created_at', ascending: true)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw const DatabaseException('Yorumlar yüklenirken bir hata oluştu.');
    }
  }
}
