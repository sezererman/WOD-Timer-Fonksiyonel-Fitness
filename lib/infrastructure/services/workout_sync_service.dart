import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../../features/history/domain/repositories/history_repository.dart';
import '../../features/history/domain/constants/sync_status.dart';

/// Arka plan senkronizasyon servisi.
/// Yerel veritabanında (Hive) [SyncStatus.pending] veya [SyncStatus.failed]
/// statüsündeki antrenmanları bulur ve internet bağlantısı varsa Supabase'e gönderir.
class WorkoutSyncService {
  final SupabaseClient _supabaseClient;
  final HistoryRepository _historyRepository;
  final Connectivity _connectivity;

  WorkoutSyncService({
    required SupabaseClient supabaseClient,
    required HistoryRepository historyRepository,
    Connectivity? connectivity,
  })  : _supabaseClient = supabaseClient,
        _historyRepository = historyRepository,
        _connectivity = connectivity ?? Connectivity();

  /// Bekleyen veya hata alan tüm antrenmanları senkronize etmeye çalışır.
  Future<void> syncPendingWorkouts() async {
    try {
      // 1. İnternet kontrolü
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        debugPrint('SyncService: İnternet yok, senkronizasyon atlanıyor.');
        return;
      }

      // 2. Bekleyenleri getir
      final pendingWorkouts = await _historyRepository.getPendingWorkouts();
      if (pendingWorkouts.isEmpty) {
        debugPrint('SyncService: Senkronize edilecek kayıt yok.');
        return;
      }

      debugPrint('SyncService: ${pendingWorkouts.length} kayıt eşitleniyor...');

      // 3. Her bir kaydı Supabase'e gönder
      for (final workout in pendingWorkouts) {
        try {
          final userId = _supabaseClient.auth.currentUser?.id;
          if (userId == null) {
            debugPrint('SyncService: Oturum yok, kayıt eşitlenemedi.');
            return; // Kullanıcı giriş yapmamışsa sync yapamayız
          }

          final payload = {
            'id': workout.id,
            'user_id': userId,
            'mode_name': workout.modeName,
            'total_seconds': workout.totalSeconds,
            'rounds': workout.rounds,
            'work_seconds': workout.workSeconds,
            'rest_seconds': workout.restSeconds,
            'date': workout.date.toIso8601String(),
          };

          // Supabase'e upsert (id'ye göre yoksa ekle, varsa güncelle)
          await _supabaseClient.from('workouts').upsert(payload);

          // 4. Başarılıysa statüyü 'synced' olarak güncelle
          await _historyRepository.updateSyncStatus(workout.id, SyncStatus.synced);
          debugPrint('SyncService: ${workout.id} başarıyla eşitlendi.');
        } catch (e) {
          debugPrint('SyncService: ${workout.id} eşitleme hatası: $e');
          // 5. Hataysa statüyü 'failed' olarak güncelle
          await _historyRepository.updateSyncStatus(workout.id, SyncStatus.failed);
        }
      }
    } catch (e) {
      debugPrint('SyncService: Genel senkronizasyon hatası: $e');
    }
  }
}
