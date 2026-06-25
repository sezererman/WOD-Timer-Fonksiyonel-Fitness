import 'package:equatable/equatable.dart';
import '../../domain/entities/badge.dart';

abstract class BadgesState extends Equatable {
  const BadgesState();

  @override
  List<Object?> get props => [];
}

class BadgesInitial extends BadgesState {
  const BadgesInitial();
}

class BadgeChecking extends BadgesState {
  const BadgeChecking();
}

/// Yeni rozetler kazanıldı.
/// UI katmanı (BlocListener) listeyi alıp sırayla animasyonla gösterir.
/// Animasyon zamanlama sorumluluğu BLoC'ta değil, UI'dadır.
class NewBadgesEarned extends BadgesState {
  final List<Badge> badges;

  const NewBadgesEarned(this.badges);

  @override
  List<Object?> get props => [badges];
}

class BadgesChecked extends BadgesState {
  const BadgesChecked();
}
