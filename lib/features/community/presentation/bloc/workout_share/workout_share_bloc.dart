import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'workout_share_event.dart';
import 'workout_share_state.dart';
import '../../../domain/entities/workout_share_entity.dart';
import '../../../domain/repositories/workout_share_repository.dart';

class WorkoutShareBloc extends Bloc<WorkoutShareEvent, WorkoutShareState> {
  final WorkoutShareRepository _repository;

  WorkoutShareBloc({required WorkoutShareRepository repository})
      : _repository = repository,
        super(WorkoutShareInitial()) {
    on<FetchSharedWorkoutsEvent>(_onFetchSharedWorkouts);
    on<ToggleLikeEvent>(_onToggleLikeLocal);

    // Optimistic UI için: 
    // Sunucuya giden isteği her post özelinde (groupBy workoutId) Debounce ediyoruz.
    // Kullanıcı butona 10 kere basarsa sadece son durum (isLiking) sunucuya iletilir.
    on<SyncLikeServerEvent>(
      _onSyncLikeServer,
      transformer: _debounceByWorkoutId(const Duration(milliseconds: 600)),
    );
  }

  EventTransformer<SyncLikeServerEvent> _debounceByWorkoutId(Duration duration) {
    return (events, mapper) {
      return events
          .groupBy((event) => event.workoutId)
          .flatMap((group) => group.debounceTime(duration).flatMap(mapper));
    };
  }

  Future<void> _onFetchSharedWorkouts(
    FetchSharedWorkoutsEvent event,
    Emitter<WorkoutShareState> emit,
  ) async {
    emit(WorkoutShareLoading());
    try {
      final posts = await _repository.getSharedWorkouts(limit: 20, offset: 0);
      emit(WorkoutShareLoaded(posts: posts));
    } catch (e) {
      emit(const WorkoutShareError('Antrenmanlar yüklenirken hata oluştu.'));
    }
  }

  void _onToggleLikeLocal(
    ToggleLikeEvent event,
    Emitter<WorkoutShareState> emit,
  ) {
    if (state is! WorkoutShareLoaded) return;
    
    final currentState = state as WorkoutShareLoaded;
    // PERFORMANS: Tek List.from kopyası — önceki kodda 2 kez kopyalanıyordu.
    // originalPosts: rollback için sakladığımız orijinal liste.
    final originalPosts = currentState.posts;
    
    final postIndex = originalPosts.indexWhere((p) => p.id == event.workoutId);
    if (postIndex == -1) return;

    final post = originalPosts[postIndex];
    final isCurrentlyLiked = post.likedUserIds.contains(event.currentUserId);
    final willLike = !isCurrentlyLiked;

    // Güncellenmiş likedUserIds listesi
    final updatedLikedUserIds = [
      ...post.likedUserIds.where((id) => id != event.currentUserId),
      if (willLike) event.currentUserId,
    ];

    final updatedPost = post.copyWith(
      likesCount: willLike ? post.likesCount + 1 : post.likesCount - 1,
      likedUserIds: updatedLikedUserIds,
    );

    // Optimistic Update: Tek kopya — yalnızca değişen elemanı değiştir
    final updatedPosts = List<WorkoutShareEntity>.from(originalPosts)
      ..[postIndex] = updatedPost;

    // 1. Arayüzyü aninda güncelle (Optimistic UI)
    emit(currentState.copyWith(posts: updatedPosts));

    // 2. Sunucu senkronizasyonu için event fırlat (Debounce ile)
    add(SyncLikeServerEvent(
      workoutId: event.workoutId,
      isLiking: willLike,
      originalPosts: originalPosts, // Hata olursa geri dönmek (Rollback) için
    ));
  }

  Future<void> _onSyncLikeServer(
    SyncLikeServerEvent event,
    Emitter<WorkoutShareState> emit,
  ) async {
    try {
      await _repository.toggleLike(
        workoutId: event.workoutId,
        isLiking: event.isLiking,
      );
    } catch (e) {
      // 3. Rollback: Eğer sunucu işlemi başarısız olursa arayüzü eski haline döndür
      if (state is WorkoutShareLoaded) {
        emit(WorkoutShareOptimisticError(
          'Beğeni işlemi başarısız oldu.',
          List<WorkoutShareEntity>.from(event.originalPosts),
        ));
        // Error state'i gösterdikten sonra tekrar yüklü duruma dönmek için
        emit(WorkoutShareLoaded(
          posts: List<WorkoutShareEntity>.from(event.originalPosts),
          hasReachedMax: (state as WorkoutShareLoaded).hasReachedMax,
        ));
      }
    }
  }
}
