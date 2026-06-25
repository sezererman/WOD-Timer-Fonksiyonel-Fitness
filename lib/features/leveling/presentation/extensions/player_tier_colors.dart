import 'package:flutter/material.dart';
import '../../domain/models/user_level_model.dart';

/// [PlayerTier] için renk ve görsel stil bilgilerini presentation katmanında tutar.
///
/// Domain modeli Flutter'a bağımlı olmamalı — bu extension o bağımlılığı
/// presentation katmanına taşır (Clean Architecture + Separation of Concerns).
extension PlayerTierColors on PlayerTier {
  /// Tier'in birincil rengi (progress bar, rozet vb.).
  Color get primaryColor {
    switch (this) {
      case PlayerTier.rookie:
        return const Color(0xFF8B6914); // Kahve — bronz
      case PlayerTier.beginner:
        return const Color(0xFF2ECC71); // Yeşil
      case PlayerTier.intermediate:
        return const Color(0xFF3498DB); // Mavi
      case PlayerTier.advanced:
        return const Color(0xFF9B59B6); // Mor
      case PlayerTier.elite:
        return const Color(0xFFE74C3C); // Kırmızı / altın
    }
  }

  /// Tier'in ikincil/aksan rengi (gradient, glow vb.).
  Color get accentColor {
    switch (this) {
      case PlayerTier.rookie:
        return const Color(0xFFD4A017);
      case PlayerTier.beginner:
        return const Color(0xFF27AE60);
      case PlayerTier.intermediate:
        return const Color(0xFF2980B9);
      case PlayerTier.advanced:
        return const Color(0xFF8E44AD);
      case PlayerTier.elite:
        return const Color(0xFFF39C12);
    }
  }
}
