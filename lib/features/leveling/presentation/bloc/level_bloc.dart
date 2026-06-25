import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_level_entity.dart';
import '../../domain/usecases/get_user_level.dart';
import '../../domain/usecases/stream_xp_updates.dart';
import '../../domain/repositories/leveling_repository.dart';
import 'level_event.dart';
import 'level_state.dart';

/// XP ve Seviye sisteminin tüm iş mantığını yöneten BLoC.
///
/// Sorumlulukları:
///   1. Kullanıcı level profilini Supabase'den çeker (tek seferlik).
///   2. Supabase Realtime stream'e abone olur — XP değişince otomatik günceller.
///   3. Antrenman sonrası RPC'yi tetikler ve level-up kontrolü yapar.
///   4. Level-up gerçekleşirse [LevelUpOccurred] state'i emit eder (popup tetikler).
class LevelBloc extends Bloc<LevelEvent, LevelState> {
  final GetUserLevel _getUserLevel;
  final StreamXpUpdates _streamXpUpdates;
  final LevelingRepository _repository;

  StreamSubscription<UserLevelEntity>? _xpSubscription;

  LevelBloc({
    required GetUserLevel getUserLevel,
    required StreamXpUpdates streamXpUpdates,
    required LevelingRepository repository,
  })  : _getUserLevel = getUserLevel,
        _streamXpUpdates = streamXpUpdates,
        _repository = repository,
        super(const LevelInitial()) {
    on<LevelStarted>(_onStarted);
    on<LevelXpAwardRequested>(_onXpAwardRequested);
    on<LevelXpUpdatedFromStream>(_onXpUpdatedFromStream);
    on<LevelUpCelebrationDismissed>(_onCelebrationDismissed);
    on<LevelStopped>(_onStopped);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BAŞLATMA
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onStarted(
    LevelStarted event,
    Emitter<LevelState> emit,
  ) async {
    emit(const LevelLoading());

    try {
      // 1. İlk profil verisi
      final entity = await _getUserLevel(event.userId);
      emit(LevelLoaded(entity));

      // 2. Realtime stream'e abone ol
      await _xpSubscription?.cancel();
      _xpSubscription = _streamXpUpdates(event.userId).listen(
        (updatedEntity) {
          add(LevelXpUpdatedFromStream(
            newTotalXp: updatedEntity.totalXp,
            newLevel: updatedEntity.currentLevel,
            streakDays: updatedEntity.streakDays,
            dailyXpToday: updatedEntity.dailyXpToday,
          ));
        },
        onError: (_) {
          // Realtime hatası: sessizce yoksay, mevcut state kalır
        },
      );
    } catch (e) {
      emit(LevelError('XP profili yüklenemedi: ${e.toString()}'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // XP ÖDÜL TALEP ET
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onXpAwardRequested(
    LevelXpAwardRequested event,
    Emitter<LevelState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LevelLoaded) return;

    // Yükleniyor göster
    emit(LevelXpAwarding(currentState.entity));

    try {
      final result = await _repository.awardXp(
        userId: event.userId,
        modeName: event.modeName,
        totalSeconds: event.totalSeconds,
        roundsCompleted: event.roundsCompleted,
        timeCapSeconds: event.timeCapSeconds,
        finishedBeforeCap: event.finishedBeforeCap,
        clientStartedAt: event.clientStartedAt,
        clientFinishedAt: event.clientFinishedAt,
        currentLevel: currentState.level,
      );

      // XP sıfır: red veya cap nedeniyle ödül verilmedi
      if (result.xpAwarded == 0) {
        emit(currentState);
        return;
      }

      // Güncellenmiş entity — Realtime stream de gelecek; burada hemen güncelle
      final updatedEntity = UserLevelEntity(
        totalXp: result.newTotalXp,
        currentLevel: result.newLevel,
        streakDays: currentState.streakDays,
        dailyXpToday: currentState.dailyXpToday + result.xpAwarded,
        lastWorkoutDate: DateTime.now(),
      );

      if (result.leveledUp && result.newLevel > result.oldLevel) {
        // 🎉 SEVİYE ATLANDI
        emit(LevelUpOccurred(
          entity: updatedEntity,
          oldLevel: result.oldLevel,
          xpAwarded: result.xpAwarded,
          xpBreakdown: result.xpBreakdown,
        ));
      } else {
        // ✅ XP kazanıldı, seviye atlanmadı
        emit(XpEarned(
          entity: updatedEntity,
          xpAwarded: result.xpAwarded,
          xpBreakdown: result.xpBreakdown,
        ));
      }
    } catch (e) {
      // RPC hatası — mevcut state'i koru, hatayı göster
      final currentLoaded = state;
      if (currentLoaded is LevelLoaded) {
        emit(currentLoaded);
      }
      emit(LevelError('XP ödüllendirilemedi: ${e.toString()}'));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REALTIME STREAM GÜNCELLEMESİ
  // ─────────────────────────────────────────────────────────────────────────

  /// Supabase Realtime'dan gelen XP güncellemelerini işler.
  ///
  /// Bu handler doğrudan [LevelUpOccurred] emit etmez çünkü Realtime
  /// güncellemesi zaten RPC'nin tetiklediği [_onXpAwardRequested] sonrasında
  /// gelir. Burada sadece state'i güncel tutar.
  void _onXpUpdatedFromStream(
    LevelXpUpdatedFromStream event,
    Emitter<LevelState> emit,
  ) {
    final currentState = state;

    // Eğer şu an LevelUpOccurred ise — popup henüz kapatılmadı,
    // stream güncellemesini yoksay (popup'ı geçersiz kılmamak için).
    if (currentState is LevelUpOccurred) return;

    final updatedEntity = UserLevelEntity(
      totalXp: event.newTotalXp,
      currentLevel: event.newLevel,
      streakDays: event.streakDays,
      dailyXpToday: event.dailyXpToday,
      lastWorkoutDate: currentState is LevelLoaded
          ? currentState.entity.lastWorkoutDate
          : null,
    );

    emit(LevelLoaded(updatedEntity));
  }

  // ─────────────────────────────────────────────────────────────────────────
  // KUTLAMA KAPATILDI
  // ─────────────────────────────────────────────────────────────────────────

  void _onCelebrationDismissed(
    LevelUpCelebrationDismissed event,
    Emitter<LevelState> emit,
  ) {
    final currentState = state;
    if (currentState is LevelUpOccurred) {
      // Popup kapatıldı — normal LevelLoaded state'ine dön
      emit(LevelLoaded(currentState.entity));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // DURDURMA
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onStopped(
    LevelStopped event,
    Emitter<LevelState> emit,
  ) async {
    await _xpSubscription?.cancel();
    _xpSubscription = null;
    emit(const LevelInitial());
  }

  @override
  Future<void> close() {
    _xpSubscription?.cancel();
    return super.close();
  }
}
