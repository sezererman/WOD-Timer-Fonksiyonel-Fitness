import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Gradient arka planlı Scaffold sarmalayıcı.
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors ?? [AppColors.backgroundDark, AppColors.backgroundCard],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: child,
    );
  }
}
