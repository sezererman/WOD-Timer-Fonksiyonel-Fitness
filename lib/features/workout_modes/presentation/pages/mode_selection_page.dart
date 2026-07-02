import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../design_system/constants/app_strings.dart';
import '../../../../design_system/widgets/gradient_background.dart';
import '../bloc/workout_mode_bloc.dart';
import '../bloc/workout_mode_event.dart';
import '../bloc/workout_mode_state.dart';
import '../../domain/entities/workout_mode.dart';
import '../widgets/mode_card.dart';
import 'mode_config_page.dart';
import 'wod_builder_page.dart';

/// Ana mod seçim ekranı.
class ModeSelectionPage extends StatelessWidget {
  const ModeSelectionPage({super.key});

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
                const SizedBox(height: 8),
                const Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppStrings.appTagline,
                  style: TextStyle(fontSize: 14, color: AppColors.textHint),
                ),
                const SizedBox(height: 32),
                const Text(
                  'ANTRENMAN MODU SEÇ',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<WorkoutModeBloc, WorkoutModeState>(
                    builder: (context, state) {
                      if (state is WorkoutModeLoaded) {
                        return _buildModeGrid(context, state);
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeGrid(BuildContext context, WorkoutModeLoaded state) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.95,
      ),
      itemCount: state.modes.length,
      itemBuilder: (context, index) {
        final mode = state.modes[index];
        return ModeCard(
          mode: mode,
          isSelected: state.selectedMode == mode,
          onTap: () {
            context.read<WorkoutModeBloc>().add(WorkoutModeSelected(mode));
            
            if (mode == WorkoutMode.custom) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WodBuilderPage()),
              );
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ModeConfigPage(mode: mode)),
              );
            }
          },
        );
      },
    );
  }
}
