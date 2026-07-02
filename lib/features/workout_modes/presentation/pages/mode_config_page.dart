import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../design_system/constants/app_colors.dart';
import '../../../../core/routing/route_constants.dart';
import '../../../../design_system/constants/app_durations.dart';
import '../../../../design_system/widgets/gradient_background.dart';
import '../../../../design_system/widgets/primary_button.dart';
import '../../../timer/domain/entities/timer_config.dart';
import '../../domain/entities/workout_mode.dart';
import '../widgets/config_slider.dart';

/// Seçilen modu yapılandırma sayfası.
class ModeConfigPage extends StatefulWidget {
  final WorkoutMode mode;

  const ModeConfigPage({super.key, required this.mode});

  @override
  State<ModeConfigPage> createState() => _ModeConfigPageState();
}

class _ModeConfigPageState extends State<ModeConfigPage> {
  late int _rounds;
  late int _workSeconds;
  late int _restSeconds;
  late int _prepareSeconds;

  @override
  void initState() {
    super.initState();
    _setDefaults();
  }

  void _setDefaults() {
    switch (widget.mode) {
      case WorkoutMode.tabata:
        _rounds = AppDurations.tabataDefaultRounds;
        _workSeconds = AppDurations.tabataWorkSeconds;
        _restSeconds = AppDurations.tabataRestSeconds;
        _prepareSeconds = AppDurations.defaultPrepareSeconds;
      case WorkoutMode.emom:
        _rounds = AppDurations.emomDefaultRounds;
        _workSeconds = AppDurations.emomDefaultMinutes * 60;
        _restSeconds = 0;
        _prepareSeconds = AppDurations.defaultPrepareSeconds;
      case WorkoutMode.amrap:
        _rounds = 1;
        _workSeconds = AppDurations.amrapDefaultMinutes * 60;
        _restSeconds = 0;
        _prepareSeconds = AppDurations.defaultPrepareSeconds;
      case WorkoutMode.forTime:
        _rounds = 1;
        _workSeconds = AppDurations.forTimeDefaultSeconds;
        _restSeconds = 0;
        _prepareSeconds = AppDurations.defaultPrepareSeconds;
      case WorkoutMode.custom:
        _rounds = AppDurations.defaultRounds;
        _workSeconds = AppDurations.defaultWorkSeconds;
        _restSeconds = AppDurations.defaultRestSeconds;
        _prepareSeconds = AppDurations.defaultPrepareSeconds;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          widget.mode.displayName,
          style: const TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      const SizedBox(height: 16),
                      if (widget.mode != WorkoutMode.amrap &&
                          widget.mode != WorkoutMode.forTime)
                        ConfigSlider(
                          label: 'Tur Sayısı',
                          value: _rounds,
                          min: 1,
                          max: 50,
                          suffix: 'tur',
                          onChanged: (v) => setState(() => _rounds = v),
                        ),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final isAmrapOrForTime = widget.mode == WorkoutMode.amrap ||
                              widget.mode == WorkoutMode.forTime;
                          return ConfigSlider(
                            label: isAmrapOrForTime ? 'Toplam Süre' : 'Çalışma Süresi',
                            value: isAmrapOrForTime ? _workSeconds ~/ 60 : _workSeconds,
                            min: isAmrapOrForTime ? 1 : 5,
                            max: isAmrapOrForTime ? 60 : 300,
                            suffix: isAmrapOrForTime ? 'dk' : 'sn',
                            onChanged: (v) => setState(() => _workSeconds = isAmrapOrForTime ? v * 60 : v),
                          );
                        },
                      ),
                      if (widget.mode == WorkoutMode.tabata ||
                          widget.mode == WorkoutMode.custom) ...[
                        const SizedBox(height: 12),
                        ConfigSlider(
                          label: 'Dinlenme Süresi',
                          value: _restSeconds,
                          min: 0,
                          max: 120,
                          onChanged: (v) => setState(() => _restSeconds = v),
                        ),
                      ],
                      const SizedBox(height: 12),
                      ConfigSlider(
                        label: 'Hazırlık Süresi',
                        value: _prepareSeconds,
                        min: 0,
                        max: 30,
                        onChanged: (v) => setState(() => _prepareSeconds = v),
                      ),
                      const SizedBox(height: 24),
                      // Toplam süre bilgisi
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Toplam: ${_formatTotal()} dk',
                              style: const TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    text: 'BAŞLA',
                    icon: Icons.play_arrow_rounded,
                    isLarge: true,
                    onPressed: _startTimer,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTotal() {
    final total =
        _prepareSeconds +
        (_workSeconds * _rounds) +
        (_restSeconds * (_rounds > 1 ? _rounds - 1 : 0));
    final minutes = total ~/ 60;
    final seconds = total % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    final config = TimerConfig(
      rounds: _rounds,
      workSeconds: _workSeconds,
      restSeconds: _restSeconds,
      prepareSeconds: _prepareSeconds,
      mode: widget.mode,
    );

    context.go('${Routes.timer}/active', extra: config);
  }
}
