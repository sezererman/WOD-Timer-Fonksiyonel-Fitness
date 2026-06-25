import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../../../../core/error/exceptions.dart';
import '../models/comment_model.dart';
import 'comment_remote_datasource.dart';

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final SupabaseClient supabaseClient;

  CommentRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<CommentModel>> getComments({
    required String workoutId,
    required int limit,
    required int offset,
  }) async {
    try {
      final response = await supabaseClient
          .from('workout_comments')
          .select()
          .eq('workout_id', workoutId)
          .order('created_at', ascending: true) // Eski yorumlar üstte
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw const DatabaseException('Yorumlar getirilirken hata oluştu.');
    }
  }

  @override
  Future<void> addComment({
    required String workoutId,
    required String text,
  }) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException('Kullanıcı oturumu bulunamadı.');
      }

      await supabaseClient.from('workout_comments').insert({
        'workout_id': workoutId,
        'user_id': currentUser.id,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw const DatabaseException('Yorum eklenirken hata oluştu.');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException('Kullanıcı oturumu bulunamadı.');
      }

      // Güvenlik: Kullanıcı sadece kendi yorumunu silebilir (Supabase RLS ile de desteklenmeli)
      await supabaseClient
          .from('workout_comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', currentUser.id);
    } catch (e) {
      throw const DatabaseException('Yorum silinirken hata oluştu.');
    }
  }

  @override
  Future<void> reportComment(String commentId, String reason) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException('Kullanıcı oturumu bulunamadı.');
      }

      await supabaseClient.from('reported_comments').insert({
        'comment_id': commentId,
        'reported_by': currentUser.id,
        'reason': reason,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw const DatabaseException('Yorum raporlanırken hata oluştu.');
    }
  }
}
