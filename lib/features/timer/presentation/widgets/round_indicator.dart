import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Mevcut tur / toplam tur göstergesi.
class RoundIndicator extends StatelessWidget {
  final int currentRound;
  final int totalRounds;

  const RoundIndicator({
    super.key,
    required this.currentRound,
    required this.totalRounds,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'TUR',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textHint,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$currentRound',
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              ' / $totalRounds',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Tur noktaları
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(totalRounds > 20 ? 20 : totalRounds, (index) {
            final isCompleted = index < currentRound;
            final isCurrent = index == currentRound - 1;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: isCurrent ? 12 : 8,
              height: isCurrent ? 12 : 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.primary : AppColors.surfaceLight,
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.6),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }
}
