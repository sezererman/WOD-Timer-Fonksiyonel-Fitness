import '../../domain/entities/workout_share_entity.dart';
import '../../domain/repositories/workout_share_repository.dart';
import '../datasources/workout_share_local_datasource.dart';
import '../datasources/workout_share_remote_datasource.dart';
import '../models/workout_share_model.dart';
import '../../../../core/error/exceptions.dart';

class WorkoutShareRepositoryImpl implements WorkoutShareRepository {
  final WorkoutShareRemoteDataSource remoteDataSource;
  final WorkoutShareLocalDataSource localDataSource;

  WorkoutShareRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> shareWorkout(WorkoutShareEntity workoutShare) async {
    try {
      final model = WorkoutShareModel.fromEntity(workoutShare);
      await remoteDataSource.shareWorkout(model);
    } on AuthException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Bilinmeyen bir hata oluştu: ${e.toString()}');
    }
  }

  @override
  Future<List<WorkoutShareEntity>> getSharedWorkouts({required int limit, required int offset}) async {
    try {
      // 1. Önce sunucudan güncel veriyi çekmeyi dene
      final remoteData = await remoteDataSource.getSharedWorkouts(limit: limit, offset: offset);
      
      // 2. Sadece ilk sayfayı (offset == 0) önbelleğe kaydet (Offline modda en güncel akışı göstermek için)
      if (offset == 0) {
        await localDataSource.cacheSharedWorkouts(remoteData);
      }
      return remoteData;
    } catch (e) {
      // 3. Eğer sunucudan çekerken hata olursa (İnternet yoksa), ilk sayfa için lokal önbellekten oku
      if (offset == 0) {
        try {
          return await localDataSource.getCachedSharedWorkouts();
        } catch (cacheError) {
          throw const DatabaseException('Bağlantı hatası: İnternet bağlantınızı kontrol edin.');
        }
      }
      // Sayfalama sırasında internet giderse cache gösterme, sadece hata fırlat
      throw const DatabaseException('Bağlantı hatası: Daha fazla gönderi yüklenemedi.');
    }
  }

  @override
  Future<void> toggleLike({required String workoutId, required bool isLiking}) async {
    try {
      await remoteDataSource.toggleLike(workoutId: workoutId, isLiking: isLiking);
    } on AuthException {
      rethrow;
    } on DatabaseException {
      rethrow;
    } catch (e) {
      throw DatabaseException('Bilinmeyen bir hata oluştu: ${e.toString()}');
    }
  }
}
