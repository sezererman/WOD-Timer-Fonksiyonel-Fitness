import 'package:equatable/equatable.dart';
import '../../../community/domain/entities/comment_entity.dart';
import '../../../community/domain/entities/workout_share_entity.dart';
import '../../domain/entities/user_profile_entity.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfileEntity userProfile;
  final List<WorkoutShareEntity> sharedWorkouts;
  final List<CommentEntity> userComments;
  final List<WorkoutShareEntity> likedWorkouts;

  const ProfileLoaded({
    required this.userProfile,
    required this.sharedWorkouts,
    required this.userComments,
    required this.likedWorkouts,
  });

  /// Avatar URL güncellenmiş yeni bir kopya döndürür —
  /// diğer alanlar değişmez (immutable update).
  ProfileLoaded copyWithAvatarUrl(String newUrl) => ProfileLoaded(
        userProfile: UserProfileEntity(
          id: userProfile.id,
          name: userProfile.name,
          avatarUrl: newUrl,
          bio: userProfile.bio,
          favoriteMove: userProfile.favoriteMove,
          totalWorkouts: userProfile.totalWorkouts,
          totalLikes: userProfile.totalLikes,
          totalComments: userProfile.totalComments,
        ),
        sharedWorkouts: sharedWorkouts,
        userComments: userComments,
        likedWorkouts: likedWorkouts,
      );

  ProfileLoaded copyWithDetails({String? bio, String? favoriteMove}) => ProfileLoaded(
        userProfile: UserProfileEntity(
          id: userProfile.id,
          name: userProfile.name,
          avatarUrl: userProfile.avatarUrl,
          bio: bio ?? userProfile.bio,
          favoriteMove: favoriteMove ?? userProfile.favoriteMove,
          totalWorkouts: userProfile.totalWorkouts,
          totalLikes: userProfile.totalLikes,
          totalComments: userProfile.totalComments,
        ),
        sharedWorkouts: sharedWorkouts,
        userComments: userComments,
        likedWorkouts: likedWorkouts,
      );

  @override
  List<Object?> get props => [
        userProfile,
        sharedWorkouts,
        userComments,
        likedWorkouts,
      ];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// ─── Avatar Yükleme State'leri ────────────────────────────────────────────────

/// ImagePicker açıldıktan / kırpma başladıktan sonra emit edilir.
/// UI: profil fotoğrafı üzerinde dönen bir yükleme göstergesi gösterir.
class AvatarUploading extends ProfileState {
  /// Yükleme sürerken görüntülenen mevcut profil verisi.
  final ProfileLoaded currentData;
  const AvatarUploading(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

/// Storage yükleme + DB güncellemesi başarıyla tamamlandı.
/// [updatedState]: avatarUrl güncellenmiş ProfileLoaded — Bloc bunu
/// son geçerli state olarak kullanır.
class AvatarUploadSuccess extends ProfileState {
  final ProfileLoaded updatedState;
  const AvatarUploadSuccess(this.updatedState);

  @override
  List<Object?> get props => [updatedState];
}

/// Herhangi bir adımda (picker / cropper / upload / DB) hata oluştu.
/// [previousData]: hata sonrasında UI'ın geri döneceği profil verisi.
class AvatarUploadFailure extends ProfileState {
  final String message;
  final ProfileLoaded previousData;

  const AvatarUploadFailure({
    required this.message,
    required this.previousData,
  });

  @override
  List<Object?> get props => [message, previousData];
}

// ─── Profil Detayları (Bio & Favori Hareket) State'leri ──────────────────────

class ProfileDetailsUpdating extends ProfileState {
  final ProfileLoaded currentData;
  const ProfileDetailsUpdating(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

class ProfileDetailsUpdateSuccess extends ProfileState {
  final ProfileLoaded updatedState;
  const ProfileDetailsUpdateSuccess(this.updatedState);

  @override
  List<Object?> get props => [updatedState];
}

class ProfileDetailsUpdateFailure extends ProfileState {
  final String message;
  final ProfileLoaded previousData;

  const ProfileDetailsUpdateFailure({
    required this.message,
    required this.previousData,
  });

  @override
  List<Object?> get props => [message, previousData];
}

