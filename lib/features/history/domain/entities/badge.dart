import 'package:equatable/equatable.dart';

/// Kullanıcının kazandığı başarı rozeti.
class Badge extends Equatable {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final DateTime earnedDate;

  const Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.earnedDate,
  });

  @override
  List<Object?> get props => [id, title, description, iconAsset, earnedDate];
}
