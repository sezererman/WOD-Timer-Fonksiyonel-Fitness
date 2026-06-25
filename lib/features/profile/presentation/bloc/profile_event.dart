import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_state.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileData extends ProfileEvent {
  final String userId;
  const LoadProfileData(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Kullanıcı avatar fotoğrafını seçip yükleme sürecini başlatır.
///
/// [source]: ImageSource.gallery veya ImageSource.camera
/// [currentState]: Bloc, yükleme sonrası mevcut profil state'ini korumak için
///   bu referansı kullanır — ProfileLoaded'ın diğer alanları sıfırlanmaz.
class PickAndUploadAvatar extends ProfileEvent {
  final ImageSource source;
  final ProfileLoaded currentState;

  const PickAndUploadAvatar({
    required this.source,
    required this.currentState,
  });

  @override
  List<Object?> get props => [source, currentState];
}

class UpdateProfileDetails extends ProfileEvent {
  final String? bio;
  final String? favoriteMove;
  final ProfileLoaded currentState;

  const UpdateProfileDetails({
    this.bio,
    this.favoriteMove,
    required this.currentState,
  });

  @override
  List<Object?> get props => [bio, favoriteMove, currentState];
}

