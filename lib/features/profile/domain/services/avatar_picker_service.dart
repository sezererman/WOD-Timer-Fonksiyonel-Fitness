import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Avatar seçme ve kırpma işlemini soyutlayan domain servis arayüzü.
///
/// Domain katmanı bu interface'e bağımlıdır; hiçbir platform detayı
/// (ImagePicker, ImageCropper, AndroidUiSettings vb.) buraya sızmaz.
///
/// [pickAndCropAvatar] başarısız olursa `null` döner:
///  - Kullanıcı seçimi iptal ettiyse
///  - Kullanıcı kırpmayı iptal ettiyse
abstract class AvatarPickerService {
  /// Kullanıcıya fotoğraf seçtirip 1:1 kare olarak kırpar.
  ///
  /// [source] → [ImageSource.gallery] veya [ImageSource.camera]
  ///
  /// Döndürülen [File] doğrudan [UploadAvatarUseCase]'e geçirilebilir.
  Future<File?> pickAndCropAvatar(ImageSource source);
}
