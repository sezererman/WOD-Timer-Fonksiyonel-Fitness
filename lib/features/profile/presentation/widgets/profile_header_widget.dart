import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/level_badge.dart';
import '../../../../../core/widgets/user_level_badge.dart';
import '../../domain/entities/user_profile_entity.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

// =============================================================================
// ProfileHeaderWidget — Profil Sayfası Üst Bölümü
//
// Bağımsız, yeniden kullanılabilir widget. ProfileBloc'u dışarıdan alır,
// doğrudan BlocProvider oluşturmaz (test edilebilirlik için).
//
// İçerik:
//   1. Avatar (düzenle butonu, yükleme göstergesi, glow efekti)
//   2. Ad-Soyad + e-posta
//   3. UserLevelBadge satırı
//   4. İstatistik satırı (antrenman / beğeni / yorum)
// =============================================================================

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfileEntity profile;
  final ProfileLoaded profileState;

  /// Level bilgisi: leveling feature'dan gelebilir,
  /// yoksa 0 döner → Rookie gösterilir.
  final int currentLevel;

  const ProfileHeaderWidget({
    super.key,
    required this.profile,
    required this.profileState,
    this.currentLevel = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      // Avatar upload state değişikliklerini dinle; sadece hata/başarı snackbar.
      listenWhen: (previous, current) =>
          current is AvatarUploadSuccess ||
          current is AvatarUploadFailure ||
          current is ProfileDetailsUpdateSuccess ||
          current is ProfileDetailsUpdateFailure,
      listener: (context, state) {
        if (state is AvatarUploadSuccess || state is ProfileDetailsUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state is AvatarUploadSuccess ? 'Profil fotoğrafı güncellendi ✅' : 'Profil güncellendi ✅'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        } else if (state is AvatarUploadFailure || state is ProfileDetailsUpdateFailure) {
          final message = state is AvatarUploadFailure ? state.message : (state as ProfileDetailsUpdateFailure).message;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        // Sadece avatar durumu değişince yeniden build et.
        buildWhen: (previous, current) =>
            current is ProfileLoaded ||
            current is AvatarUploading ||
            current is AvatarUploadSuccess ||
            current is AvatarUploadFailure ||
            current is ProfileDetailsUpdating ||
            current is ProfileDetailsUpdateSuccess ||
            current is ProfileDetailsUpdateFailure,
        builder: (context, state) {
          final isUploading = state is AvatarUploading;

          // AvatarUploadSuccess/Failure durumunda güncel profil verisini koru.
          final displayProfile = switch (state) {
            final AvatarUploadSuccess s => s.updatedState.userProfile,
            final AvatarUploading s     => s.currentData.userProfile,
            final AvatarUploadFailure s => s.previousData.userProfile,
            final ProfileDetailsUpdating s => s.currentData.userProfile,
            final ProfileDetailsUpdateSuccess s => s.updatedState.userProfile,
            final ProfileDetailsUpdateFailure s => s.previousData.userProfile,
            _                           => profile,
          };

          return Column(
            children: [
              const SizedBox(height: 8),

              // ── 1. Avatar ──────────────────────────────────────────────────
              _AvatarSection(
                profile: displayProfile,
                isUploading: isUploading,
                onEditTap: () => _showSourcePicker(context),
              ),

              const SizedBox(height: 18),

              // ── 2. Ad-Soyad + E-posta ───────────────────────────────────────
              _UserInfoSection(
                profile: displayProfile,
                onEditDetailsTap: () => _showEditDetailsSheet(context, displayProfile),
              ),

              const SizedBox(height: 14),

              // ── 3. Seviye Rozeti ────────────────────────────────────────────
              _LevelSection(level: currentLevel),

              // ── 3.1. Biyografi & Favori Hareket ──────────────────────────────
              if (displayProfile.bio != null && displayProfile.bio!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _BioSection(bio: displayProfile.bio!),
              ],

              if (displayProfile.favoriteMove != null && displayProfile.favoriteMove!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _FavoriteMoveSection(favoriteMove: displayProfile.favoriteMove!),
              ],

              const SizedBox(height: 24),

              // ── 4. İstatistik Satırı ────────────────────────────────────────
              _StatsRow(profile: displayProfile),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }

  /// Kaynak seçim alt menüsünü göster (Galeri / Kamera).
  void _showSourcePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tutma çubuğu
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Profil Fotoğrafı',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Fotoğrafı 1:1 kare olarak kırpacaksın.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 20),
              _SourceTile(
                icon: Icons.photo_library_outlined,
                label: 'Galeriden Seç',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  context.read<ProfileBloc>().add(
                        PickAndUploadAvatar(
                          source: ImageSource.gallery,
                          currentState: profileState,
                        ),
                      );
                },
              ),
              const SizedBox(height: 8),
              _SourceTile(
                icon: Icons.camera_alt_outlined,
                label: 'Kamerayla Çek',
                onTap: () {
                  Navigator.of(sheetCtx).pop();
                  context.read<ProfileBloc>().add(
                        PickAndUploadAvatar(
                          source: ImageSource.camera,
                          currentState: profileState,
                        ),
                      );
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDetailsSheet(BuildContext context, UserProfileEntity currentProfile) {
    final bioController = TextEditingController(text: currentProfile.bio);
    final favMoveController = TextEditingController(text: currentProfile.favoriteMove);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Profili Düzenle',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                // Bio Field
                TextField(
                  controller: bioController,
                  maxLength: 150,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Kısa Biyografi',
                    labelStyle: const TextStyle(color: AppColors.textHint),
                    hintText: 'Kendinden bahset...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Favorite Move Field
                TextField(
                  controller: favMoveController,
                  maxLength: 50,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Favori Hareket',
                    labelStyle: const TextStyle(color: AppColors.textHint),
                    hintText: 'Örn: Muscle-Up',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    filled: true,
                    fillColor: AppColors.backgroundDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      // XSS sanitization (very basic HTML removal)
                      String sanitize(String input) {
                        return input.replaceAll(RegExp(r'<[^>]*>'), '').trim();
                      }

                      final newBio = sanitize(bioController.text);
                      final newFavMove = sanitize(favMoveController.text);

                      Navigator.of(sheetCtx).pop();
                      context.read<ProfileBloc>().add(
                            UpdateProfileDetails(
                              bio: newBio.isNotEmpty ? newBio : null,
                              favoriteMove: newFavMove.isNotEmpty ? newFavMove : null,
                              currentState: profileState,
                            ),
                          );
                    },
                    child: Text(
                      'Kaydet',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// _AvatarSection
// =============================================================================

class _AvatarSection extends StatelessWidget {
  final UserProfileEntity profile;
  final bool isUploading;
  final VoidCallback onEditTap;

  const _AvatarSection({
    required this.profile,
    required this.isUploading,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    const double radius = 52;
    const double editBtnSize = 32;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // ── Dış parlama halkası ──────────────────────────────────────────────
        Container(
          width: radius * 2 + 12,
          height: radius * 2 + 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.6),
                AppColors.secondary.withValues(alpha: 0.4),
                AppColors.primary.withValues(alpha: 0.6),
              ],
            ),
          ),
        ),

        // ── Avatar ──────────────────────────────────────────────────────────
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
          ),
          child: ClipOval(
            child: profile.avatarUrl != null && !isUploading
                ? Image.network(
                    // Cache-bust: yeni yükleme sonrası URL aynı olsa bile taze göster.
                    '${profile.avatarUrl}?v=${DateTime.now().millisecondsSinceEpoch ~/ 60000}',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _defaultAvatar(),
                    loadingBuilder: (ctx, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _loadingIndicator();
                    },
                  )
                : isUploading
                    ? _loadingIndicator()
                    : _defaultAvatar(),
          ),
        ),

        // ── Düzenle Butonu (sağ-alt) ─────────────────────────────────────────
        Positioned(
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: isUploading ? null : onEditTap,
            child: Container(
              width: editBtnSize,
              height: editBtnSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isUploading
                    ? const LinearGradient(
                        colors: [AppColors.surfaceLight, AppColors.surface],
                      )
                    : AppColors.primaryGradient,
                border: Border.all(
                  color: AppColors.backgroundDark,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                color: isUploading ? AppColors.textHint : Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultAvatar() => const Icon(
        Icons.person,
        size: 52,
        color: AppColors.textHint,
      );

  Widget _loadingIndicator() => const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.primary,
          ),
        ),
      );
}

// =============================================================================
// _UserInfoSection
// =============================================================================

class _UserInfoSection extends StatelessWidget {
  final UserProfileEntity profile;
  final VoidCallback? onEditDetailsTap;

  const _UserInfoSection({
    required this.profile,
    this.onEditDetailsTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasName =
        profile.name != null && profile.name!.trim().isNotEmpty;

    return Column(
      children: [
        // Ad-Soyad
        Text(
          hasName ? profile.name! : 'İsimsiz Sporcu',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: 0.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        // UID'den oluşturulan anonimleştirilmiş kullanıcı kodu (e-posta yok)
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '#${profile.id.substring(0, 8).toUpperCase()}',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textHint,
                letterSpacing: 1.5,
              ),
            ),
            if (onEditDetailsTap != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onEditDetailsTap,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// _LevelSection
// =============================================================================

class _LevelSection extends StatelessWidget {
  final int level;

  const _LevelSection({required this.level});

  @override
  Widget build(BuildContext context) {
    final displayLevel = level.clamp(1, 999);
    final badge = LevelBadgeX.fromLevel(displayLevel);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: badge.backgroundColor,
        border: Border.all(
          color: badge.color.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: badge.glowColor,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini ikon rozeti (small constructor: ikon only, etiket yok)
          UserLevelBadge.small(level: displayLevel),
          const SizedBox(width: 10),
          // "Seviye 14 · Beginner" metni
          RichText(
            text: TextSpan(
              style: GoogleFonts.inter(fontSize: 14),
              children: [
                TextSpan(
                  text: 'Seviye $displayLevel',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: badge.color,
                  ),
                ),
                TextSpan(
                  text: '  ·  ',
                  style: TextStyle(
                    color: badge.color.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                TextSpan(
                  text: badge.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: badge.color.withValues(alpha: 0.85),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _BioSection
// =============================================================================

class _BioSection extends StatelessWidget {
  final String bio;

  const _BioSection({required this.bio});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        '"$bio"',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.grey[400],
          height: 1.4,
        ),
      ),
    );
  }
}

// =============================================================================
// _FavoriteMoveSection
// =============================================================================

class _FavoriteMoveSection extends StatelessWidget {
  final String favoriteMove;

  const _FavoriteMoveSection({required this.favoriteMove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 6),
          Text(
            'Favori Hareket: ',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
            ),
          ),
          Text(
            favoriteMove,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// _StatsRow — Antrenman / Beğeni / Yorum İstatistikleri
// =============================================================================

class _StatsRow extends StatelessWidget {
  final UserProfileEntity profile;

  const _StatsRow({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.backgroundCard, AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppColors.surfaceLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _StatCell(
              icon: Icons.fitness_center,
              label: 'Antrenman',
              value: profile.totalWorkouts,
              color: AppColors.primary,
            ),
            const _VerticalDivider(),
            _StatCell(
              icon: Icons.thumb_up_alt_outlined,
              label: 'Beğeni',
              value: profile.totalLikes,
              color: AppColors.secondary,
            ),
            const _VerticalDivider(),
            _StatCell(
              icon: Icons.chat_bubble_outline,
              label: 'Yorum',
              value: profile.totalComments,
              color: AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _StatCell({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            _formatValue(value),
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textHint,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 1000+ değerleri kısalt: 1250 → "1.2K".
  String _formatValue(int v) {
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toString();
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppColors.surfaceLight,
    );
  }
}

// =============================================================================
// _SourceTile — Bottom Sheet kaynak seçim satırı
// =============================================================================

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: AppColors.surfaceLight,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHint,
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
