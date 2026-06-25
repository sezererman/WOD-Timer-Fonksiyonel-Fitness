import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../community/domain/entities/comment_entity.dart';
import '../../../community/domain/entities/workout_share_entity.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/services/avatar_picker_service.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';
import '../../domain/usecases/update_profile_details_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;
  final UploadAvatarUseCase _uploadAvatarUseCase;
  final UpdateProfileDetailsUseCase _updateProfileDetailsUseCase;

  /// Platform UI detayları (ImagePicker, ImageCropper, kırpma ayarları) bu
  /// servis içinde kapsüllenir. BLoC sadece döndürülen [File?]'ı kullanır.
  final AvatarPickerService _avatarPickerService;

  ProfileBloc({
    required ProfileRepository profileRepository,
    required UploadAvatarUseCase uploadAvatarUseCase,
    required UpdateProfileDetailsUseCase updateProfileDetailsUseCase,
    required AvatarPickerService avatarPickerService,
  })  : _profileRepository = profileRepository,
        _uploadAvatarUseCase = uploadAvatarUseCase,
        _updateProfileDetailsUseCase = updateProfileDetailsUseCase,
        _avatarPickerService = avatarPickerService,
        super(ProfileInitial()) {
    on<LoadProfileData>(_onLoadProfileData);

    // avatar yükleme event'leri sıralı işlensin — örtüşme önlenir.
    on<PickAndUploadAvatar>(
      _onPickAndUploadAvatar,
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );

    on<UpdateProfileDetails>(_onUpdateProfileDetails);
  }

  // ─── LoadProfileData ────────────────────────────────────────────────────────

  Future<void> _onLoadProfileData(
    LoadProfileData event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final userId = event.userId;

      // Dart 3 record destructuring — tip güvenli paralel fetch.
      final (
        UserProfileEntity profile,
        List<WorkoutShareEntity> sharedWorkouts,
        List<CommentEntity> comments,
        List<WorkoutShareEntity> likedWorkouts,
      ) = await (
        _profileRepository.getUserProfile(userId),
        _profileRepository.getSharedWorkouts(userId),
        _profileRepository.getUserComments(userId),
        _profileRepository.getLikedWorkouts(userId),
      ).wait;

      emit(ProfileLoaded(
        userProfile: profile,
        sharedWorkouts: sharedWorkouts,
        userComments: comments,
        likedWorkouts: likedWorkouts,
      ));
    } catch (e) {
      emit(ProfileError('Profil verileri yüklenirken hata oluştu:\n$e'));
    }
  }

  // ─── PickAndUploadAvatar ────────────────────────────────────────────────────

  /// Avatar yükleme akışı (platform UI detayları serviste kapsüllü):
  ///
  /// 1. **AvatarPickerService.pickAndCropAvatar** → Kullanıcı seçer ve kırpar.
  /// 2. **UploadAvatarUseCase** → Storage'a yüklenir, DB güncellenir.
  Future<void> _onPickAndUploadAvatar(
    PickAndUploadAvatar event,
    Emitter<ProfileState> emit,
  ) async {
    final currentData = event.currentState;

    // ── ADIM 1: Fotoğraf seçimi + kırpma (servis üzerinden) ─────────────────
    final imageFile = await _avatarPickerService.pickAndCropAvatar(event.source);

    if (imageFile == null) {
      // Kullanıcı seçimi veya kırpmayı iptal etti → state değişmez.
      return;
    }

    // Yükleme başladığını UI'a bildir.
    emit(AvatarUploading(currentData));

    // ── ADIM 2: Storage yükleme + DB güncelleme ──────────────────────────────
    try {
      final newUrl = await _uploadAvatarUseCase(
        userId: currentData.userProfile.id,
        imageFile: imageFile,
      );

      final updatedState = currentData.copyWithAvatarUrl(newUrl);

      // Başarı → güncellenmiş profil state'ini yayınla.
      emit(AvatarUploadSuccess(updatedState));

      // Hemen ardından ProfileLoaded'a geç, böylece UI tutarlı state'te kalır.
      emit(updatedState);
    } catch (e) {
      emit(AvatarUploadFailure(
        message: 'Avatar yüklenirken hata oluştu:\n$e',
        previousData: currentData,
      ));
    }
  }

  // ─── UpdateProfileDetails ───────────────────────────────────────────────────

  Future<void> _onUpdateProfileDetails(
    UpdateProfileDetails event,
    Emitter<ProfileState> emit,
  ) async {
    final currentData = event.currentState;

    emit(ProfileDetailsUpdating(currentData));

    try {
      final updatedProfile = await _updateProfileDetailsUseCase(
        UpdateProfileDetailsParams(
          userId: currentData.userProfile.id,
          bio: event.bio,
          favoriteMove: event.favoriteMove,
        ),
      );

      final updatedState = currentData.copyWithDetails(
        bio: updatedProfile.bio,
        favoriteMove: updatedProfile.favoriteMove,
      );
      emit(ProfileDetailsUpdateSuccess(updatedState));
      emit(updatedState);
    } catch (e) {
      emit(ProfileDetailsUpdateFailure(
        message: e.toString(),
        previousData: currentData,
      ));
    }
  }
}
