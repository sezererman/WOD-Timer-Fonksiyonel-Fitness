import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class FeedGlassCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  
  const FeedGlassCard({
    super.key, 
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}
