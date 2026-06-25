import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Yapılandırma değeri ayarlama slider'ı.
class ConfigSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final String suffix;
  final ValueChanged<int> onChanged;

  const ConfigSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix = 'sn',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value $suffix',
                  style: const TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              activeColor: AppColors.primary,
              inactiveColor: AppColors.surfaceLight,
              onChanged: (v) => onChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}
