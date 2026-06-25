import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/services/avatar_picker_service.dart';

/// [AvatarPickerService] gerçek implementasyonu.
///
/// Platform'a özgü UI konfigürasyonu (AndroidUiSettings, IOSUiSettings,
/// renk, başlık, kilitli oran vb.) bu sınıfta toplanır.
/// [ProfileBloc] yalnızca [File?] dönen [pickAndCropAvatar] metodunu çağırır.
class AvatarPickerServiceImpl implements AvatarPickerService {
  final ImagePicker _imagePicker;
  final ImageCropper _imageCropper;

  AvatarPickerServiceImpl({
    ImagePicker? imagePicker,
    ImageCropper? imageCropper,
  })  : _imagePicker = imagePicker ?? ImagePicker(),
        _imageCropper = imageCropper ?? ImageCropper();

  @override
  Future<File?> pickAndCropAvatar(ImageSource source) async {
    // ── ADIM 1: Fotoğraf seçimi ───────────────────────────────────────────────
    final XFile? picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85, // Ağ bant genişliği optimizasyonu
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (picked == null) return null; // Kullanıcı seçimi iptal etti

    // ── ADIM 2: Kırpma (1:1 kare, zorunlu) ──────────────────────────────────
    final CroppedFile? cropped = await _imageCropper.cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Profil Fotoğrafını Kırp',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true, // ← 1:1 kilitli
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Profil Fotoğrafını Kırp',
          aspectRatioLockEnabled: true, // ← 1:1 kilitli
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
        ),
      ],
    );

    if (cropped == null) return null; // Kullanıcı kırpmayı iptal etti

    return File(cropped.path);
  }
}
