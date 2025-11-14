import 'package:flutter/material.dart';

class HskPalette {
  static const Map<int, List<Color>> _levelGradients = {
    1: [Color(0xFFFEF0F3), Color(0xFFF8DDE1)],
    2: [Color(0xFFEFF8FF), Color(0xFFD9EFFE)],
    3: [Color(0xFFF0FFF4), Color(0xFFDAF5E5)],
    4: [Color(0xFFF9F3FF), Color(0xFFE8DDF9)],
  };

  static const List<Color> _fallbackGradient = [
    Color(0xFFF4F4F4),
    Color(0xFFE2E2E2),
  ];

  static List<Color> gradientForLevel(int level) {
    return _levelGradients[level] ?? _fallbackGradient;
  }

  static Color badgeColor(int level, ColorScheme scheme) {
    switch (level) {
      case 1:
        return const Color(0xFFFB7185);
      case 2:
        return const Color(0xFF0EA5E9);
      case 3:
        return const Color(0xFF22C55E);
      case 4:
        return const Color(0xFF8B5CF6);
      default:
        return scheme.primary;
    }
  }

  static Color accentForLevel(int level, ColorScheme scheme) {
    switch (level) {
      case 1:
        return const Color(0xFFEF4444);
      case 2:
        return const Color(0xFF2563EB);
      case 3:
        return const Color(0xFF16A34A);
      case 4:
        return const Color(0xFF7C3AED);
      default:
        return scheme.primary;
    }
  }
}
