import 'package:equatable/equatable.dart';

abstract class BadgesEvent extends Equatable {
  const BadgesEvent();

  @override
  List<Object?> get props => [];
}

class CheckForNewBadges extends BadgesEvent {
  const CheckForNewBadges();
}
