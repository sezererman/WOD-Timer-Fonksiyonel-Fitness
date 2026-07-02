import 'package:flutter/material.dart';

/// Uygulama renk paletine göre renk döndüren yardımcı.
/// Ayrıca design_system/constants/app_colors.dart'ı re-export eder.
export '../constants/app_colors.dart';

/// Renk temalı extension'lar.
extension AppColorsX on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
}
