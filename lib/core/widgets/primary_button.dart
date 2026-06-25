import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Birincil aksiyon butonu — gradient arka plan ve animasyonlu.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final bool isLarge;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final btnColor = color ?? AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(isLarge ? 24 : 16),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isLarge ? 48 : 32,
              vertical: isLarge ? 20 : 14,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  btnColor,
                  btnColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(isLarge ? 24 : 16),
              boxShadow: [
                BoxShadow(
                  color: btnColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: Colors.white, size: isLarge ? 28 : 22),
                  SizedBox(width: isLarge ? 12 : 8),
                ],
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isLarge ? 18 : 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
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
