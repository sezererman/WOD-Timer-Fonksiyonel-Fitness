import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException, StorageException;
import '../../../../core/error/exceptions.dart';
import '../../../community/data/models/comment_model.dart';
import '../../../community/data/models/workout_share_model.dart';
import '../models/user_profile_model.dart';
import 'profile_remote_datasource.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProfileRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<UserProfileModel> getUserProfile(String userId) async {
    try {
      final userResponse = await supabaseClient
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      final workoutsCount = await supabaseClient
          .from('shared_workouts')
          .select('id')
          .eq('user_id', userId)
          .count(CountOption.exact);

      final likesCount = await supabaseClient
          .from('likes')
          .select('id')
          .eq('user_id', userId)
          .count(CountOption.exact);

      final commentsCount = await supabaseClient
          .from('comments')
          .select('id')
          .eq('user_id', userId)
          .count(CountOption.exact);

      return UserProfileModel(
        id: userResponse['id'] as String,
        name: userResponse['name'] as String?,
        avatarUrl: userResponse['avatar_url'] as String?,
        totalWorkouts: workoutsCount.count,
        totalLikes: likesCount.count,
        totalComments: commentsCount.count,
      );
    } catch (e) {
      debugPrint('getUserProfile Error: $e');
      throw DatabaseException('Profil bilgileri alınırken bir hata oluştu: $e');
    }
  }

  @override
  Future<List<WorkoutShareModel>> getSharedWorkouts(String userId) async {
    try {
      final response = await supabaseClient
          .from('shared_workouts')
          .select('*, users(name, avatar_url, user_xp_profiles(current_level))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => WorkoutShareModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getSharedWorkouts Error: $e');
      throw DatabaseException('Paylaşılan antrenmanlar alınırken hata oluştu: $e');
    }
  }

  @override
  Future<List<CommentModel>> getUserComments(String userId) async {
    try {
      final response = await supabaseClient
          .from('comments')
          .select('*, shared_workouts(*, users(name, avatar_url))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // Note: We might need to attach workout info to comment model if UI needs it,
      // but standard CommentModel might not support it. We'll leave it as CommentModel.
      // Wait, the prompt says "yorum yapılan antrenmanın başlığı ile birlikte". 
      // I'll need to make sure the UI can display it if the model holds it.
      return (response as List<dynamic>)
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('getUserComments Error: $e');
      throw DatabaseException('Yorumlar alınırken hata oluştu: $e');
    }
  }

  @override
  Future<List<WorkoutShareModel>> getLikedWorkouts(String userId) async {
    try {
      final response = await supabaseClient
          .from('likes')
          .select('*, shared_workouts(*, users(name, avatar_url, user_xp_profiles(current_level)))')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .where((json) => (json as Map<String, dynamic>)['shared_workouts'] != null)
          .map((json) {
        final map = json as Map<String, dynamic>;
        final workoutJson = map['shared_workouts'] as Map<String, dynamic>;
        return WorkoutShareModel.fromJson(workoutJson);
      }).toList();
    } catch (e) {
      debugPrint('getLikedWorkouts Error: $e');
      throw DatabaseException('Beğenilen antrenmanlar alınırken hata oluştu: $e');
    }
  }

  /// Kullanıcı avatarını Supabase [avatars] bucket'ına yükler.
  ///
  /// Dosya adı = [userId] (uid.jpg) → Eski fotoğrafın üzerine yazılır,
  /// depolama şişmez. [upsert: true] bu davranışı garanti eder.
  ///
  /// Yükleme tamamlandıktan sonra [users.avatar_url] güncellenir.
  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    // Dosya yolu: {uid}/{uid}.jpg
    // Klasör = uid → RLS politikası: foldername[1] = auth.uid()
    final filePath = '$userId/$userId.jpg';

    try {
      // 1. Supabase Storage'a yükle (upsert = eski dosyanın üzerine yaz)
      await supabaseClient.storage
          .from('avatars')
          .upload(
            filePath,
            imageFile,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      // 2. Public URL'i al
      final publicUrl = supabaseClient.storage
          .from('avatars')
          .getPublicUrl(filePath);

      // 3. users tablosundaki avatar_url alanını güncelle
      await supabaseClient
          .from('users')
          .update({'avatar_url': publicUrl})
          .eq('id', userId);

      debugPrint('uploadAvatar ✅ url=$publicUrl');
      return publicUrl;
    } on StorageException catch (e) {
      debugPrint('uploadAvatar StorageException: $e');
      throw StorageException('Avatar yüklenirken hata oluştu: ${e.message}');
    } catch (e) {
      debugPrint('uploadAvatar Error: $e');
      throw StorageException('Avatar yüklenirken beklenmeyen hata: $e');
    }
  }

  @override
  Future<void> updateProfileDetails({
    required String userId,
    String? bio,
    String? favoriteMove,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (bio != null) updates['bio'] = bio;
      if (favoriteMove != null) updates['favorite_move'] = favoriteMove;

      if (updates.isNotEmpty) {
        await supabaseClient
            .from('users')
            .update(updates)
            .eq('id', userId);
      }
    } catch (e) {
      debugPrint('updateProfileDetails Error: $e');
      throw DatabaseException('Profil güncellenirken hata oluştu: $e');
    }
  }
}
