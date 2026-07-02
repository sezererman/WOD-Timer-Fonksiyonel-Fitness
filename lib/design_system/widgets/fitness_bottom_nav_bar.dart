import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../../core/routing/app_tab.dart';

class FitnessBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const FitnessBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    return _NavBarItem(
      icon: icon,
      activeIcon: activeIcon,
      label: label,
      isSelected: selectedIndex == index,
      onTap: () => onItemSelected(index),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CrossFit temasına uygun: Koyu arkaplan, yüksek kontrast
    return Container(
      padding: const EdgeInsets.only(bottom: 12, top: 12),
      decoration: const BoxDecoration(
        color: AppColors.backgroundDark,
        border: Border(
          top: BorderSide(
          color: AppColors.surfaceLight,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(AppTab.timer.index, Icons.timer_outlined, Icons.timer_rounded, 'Timer'),
            _buildNavItem(AppTab.challenges.index, Icons.local_fire_department_outlined, Icons.local_fire_department, 'WOD'),
            _buildNavItem(AppTab.community.index, Icons.public_outlined, Icons.public, 'Topluluk'),
            _buildNavItem(AppTab.history.index, Icons.calendar_month_outlined, Icons.calendar_month_rounded, 'Geçmiş'),
            _buildNavItem(AppTab.settings.index, Icons.person_outline, Icons.person_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Expanded + HitTestBehavior.opaque: terli eller için geniş dokunma alanı.
    // onTap: gesture arena tamamlandıktan sonra tetiklenir — scroll / swipe
    // hareketleriyle çakışma olmaz (onTapDown ile yaşanan double-tap bug'u giderildi).
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutBack,
              scale: isSelected ? 1.2 : 1.0,
              child: Icon(
                isSelected ? activeIcon : icon,
                size: 28,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Inter',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textHint,
              ),
              child: Text(label),
            ),
            const SizedBox(height: 4),
            // Seçili sekme için parlayan neon nokta indikatörü
            AnimatedOpacity(
              opacity: isSelected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.8),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
