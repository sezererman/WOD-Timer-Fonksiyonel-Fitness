import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../design_system/constants/app_strings.dart';
import '../../../../design_system/widgets/gradient_background.dart';
import '../../domain/entities/app_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_constants.dart';

/// Ayarlar sayfası.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (context.canPop()) ...[
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(height: 8),
                ],
                Expanded(
                  child: BlocSelector<AuthBloc, AuthState, bool>(
                    selector: (state) => state is Authenticated,
                    builder: (context, isAuthenticated) {
                      if (!isAuthenticated) {
                        return _buildGuestView(context);
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            AppStrings.settings,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Expanded(
                            child: BlocBuilder<SettingsBloc, SettingsState>(
                        builder: (context, state) {
                          if (state is SettingsLoaded) {
                            return _buildSettings(context, state.settings);
                          }
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    ),
  ),
),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_outline, size: 64, color: AppColors.textHint),
          const SizedBox(height: 16),
          const Text(
            'Profil',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Ayarlarınızı yönetmek ve profilinize erişmek için giriş yapmalısınız.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textHint),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.push(Routes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Giriş Yap / Üye Ol',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings(BuildContext context, AppSettings settings) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _SettingsTile(
          icon: Icons.volume_up_rounded,
          title: AppStrings.soundEnabled,
          subtitle: 'Geri sayım ve faz geçiş sesleri',
          value: settings.soundEnabled,
          onChanged: (v) =>
              _update(context, settings.copyWith(soundEnabled: v)),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.vibration_rounded,
          title: AppStrings.vibrationEnabled,
          subtitle: 'Faz geçişlerinde titreşim',
          value: settings.vibrationEnabled,
          onChanged: (v) =>
              _update(context, settings.copyWith(vibrationEnabled: v)),
        ),
        const SizedBox(height: 8),
        _SettingsTile(
          icon: Icons.screen_lock_portrait_rounded,
          title: 'Ekran Açık Kalsın',
          subtitle: 'Antrenman sırasında ekranı kapat',
          value: settings.keepScreenOn,
          onChanged: (v) =>
              _update(context, settings.copyWith(keepScreenOn: v)),
        ),
        const SizedBox(height: 32),
        // Uygulama bilgisi
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.fitness_center_rounded,
                color: AppColors.primary,
                size: 32,
              ),
              SizedBox(height: 8),
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'v1.0.0',
                style: TextStyle(fontSize: 12, color: AppColors.textHint),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _update(BuildContext context, AppSettings settings) {
    context.read<SettingsBloc>().add(SettingsUpdated(settings));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
