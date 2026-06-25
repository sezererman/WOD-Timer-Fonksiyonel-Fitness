import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/check_and_award_badges.dart';
import '../../domain/repositories/history_repository.dart';
import 'badges_event.dart';
import 'badges_state.dart';

/// Rozet kontrolü BLoC'u.
///
/// Animasyon zamanlama sorumluluğu UI katmanındadır (BlocListener).
/// BLoC yalnızca yeni rozetleri tespit edip tek seferde bildirir —
/// [Future.delayed] gibi UI kaygıları burada yoktur.
class BadgesBloc extends Bloc<BadgesEvent, BadgesState> {
  final CheckAndAwardBadgesUseCase _checkAndAwardBadges;
  final HistoryRepository _historyRepository;

  BadgesBloc({
    required CheckAndAwardBadgesUseCase checkAndAwardBadges,
    required HistoryRepository historyRepository,
  })  : _checkAndAwardBadges = checkAndAwardBadges,
        _historyRepository = historyRepository,
        super(const BadgesInitial()) {
    on<CheckForNewBadges>(_onCheckForNewBadges);
  }

  Future<void> _onCheckForNewBadges(
    CheckForNewBadges event,
    Emitter<BadgesState> emit,
  ) async {
    emit(const BadgeChecking());
    try {
      final records = await _historyRepository.getHistory();
      final newBadges = await _checkAndAwardBadges(records);

      if (newBadges.isNotEmpty) {
        // Tüm yeni rozetler tek seferde iletilir.
        // UI katmanı (BlocListener) sırayla animasyonla gösterme kararını verir.
        emit(NewBadgesEarned(newBadges));
      }
      emit(const BadgesChecked());
    } catch (_) {
      emit(const BadgesChecked()); // Hata olsa bile sessizce devam et
    }
  }
}
