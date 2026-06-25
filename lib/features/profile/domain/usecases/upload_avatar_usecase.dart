import 'dart:io';

import '../repositories/profile_repository.dart';

/// Avatar yükleme iş kuralı.
///
/// [Domain katmanı] — Yalnızca [ProfileRepository] sözleşmesine bağlıdır;
/// hiçbir altyapı detayı (Supabase, ImagePicker vb.) bu sınıfa sızmaz.
///
/// Geri dönüş: Yüklenen fotoğrafın public URL'i.
class UploadAvatarUseCase {
  final ProfileRepository repository;

  const UploadAvatarUseCase(this.repository);

  Future<String> call({
    required String userId,
    required File imageFile,
  }) =>
      repository.uploadAvatar(userId: userId, imageFile: imageFile);
}
