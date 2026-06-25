import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../models/workout_share_model.dart';
import 'workout_share_remote_datasource.dart';
import '../../../../core/error/exceptions.dart';

/// Ana (UI) thread'i yormamak için Isolate içinde çalışacak TOP-LEVEL dönüştürme fonksiyonu.
/// Sınıfın (class) dışında olmak zorundadır (Dart Isolate kuralı).
List<WorkoutShareModel> _parseWorkoutShareList(List<dynamic> jsonList) {
  // Burada isterseniz şifre çözme (AES decryption vb.) işlemlerini de yapabilirsiniz,
  // ana ekran kesinlikle donmayacaktır.
  return jsonList
      .map((json) => WorkoutShareModel.fromJson(json as Map<String, dynamic>))
      .toList();
}

class WorkoutShareRemoteDataSourceImpl implements WorkoutShareRemoteDataSource {
  final SupabaseClient supabaseClient;

  WorkoutShareRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> shareWorkout(WorkoutShareModel workoutShare) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException('Kullanıcı oturumu bulunamadı.');
      }
      
      // GÜVENLİK: İstek yapan kullanıcı ile modele kaydedilen kullanıcı ID aynı olmalı.
      if (currentUser.id != workoutShare.userId) {
        throw const AuthException('Yetkisiz işlem: Sadece kendi antrenmanınızı paylaşabilirsiniz.');
      }

      await supabaseClient.from('shared_workouts').insert(workoutShare.toJson());
    } catch (e) {
      throw const DatabaseException('Antrenman paylaşılırken bir hata oluştu');
    }
  }

  @override
  Future<List<WorkoutShareModel>> getSharedWorkouts({required int limit, required int offset}) async {
    try {
      final response = await supabaseClient
          .from('shared_workouts')
          .select('*, users(name, avatar_url, user_xp_profiles(current_level))')
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // JSON Parsing (Dönüştürme) ve potansiyel Şifre Çözme (Decryption) gibi ağır işlemleri
      // Ana UI Thread'i dondurmamak (jank yaratmamak) için `compute` kullanarak 
      // arka plan Isolate'ine devrediyoruz.
      return await compute(_parseWorkoutShareList, response as List<dynamic>);
    } catch (e) {
      throw const DatabaseException('Paylaşılan antrenmanlar getirilirken bir hata oluştu');
    }
  }

  @override
  Future<void> toggleLike({required String workoutId, required bool isLiking}) async {
    try {
      final currentUser = supabaseClient.auth.currentUser;
      if (currentUser == null) {
        throw const AuthException('Kullanıcı oturumu bulunamadı.');
      }
      
      // Supabase tarafında 'toggle_like' adında bir RPC (Remote Procedure Call) fonksiyonumuz
      // olduğunu varsayarak atomic işlem yapıyoruz. Bu fonksiyon DB'de likes_count'u güvenle günceller.
      // Eger RPC yoksa ve Postgres'in array yapısı kullanılacaksa:
      // Atomic array append/remove ve count inc/dec işlemi gerekir.
      await supabaseClient.rpc(
        'toggle_workout_like',
        params: {
          'p_workout_id': workoutId,
          'p_user_id': currentUser.id,
          'p_is_liking': isLiking,
        },
      );
    } catch (e) {
      throw const DatabaseException('Beğeni işlemi sırasında veritabanı hatası oluştu.');
    }
  }
}
