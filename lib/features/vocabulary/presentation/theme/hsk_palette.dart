import 'package:flutter/material.dart';

class HskPalette {
  static const Map<int, List<Color>> _levelGradients = {
    1: [Color(0xFFF8E6D2), Color(0xFFEED3B3)],
    2: [Color(0xFFF6E2CF), Color(0xFFE8CCAA)],
    3: [Color(0xFFF3DDC7), Color(0xFFE4C4A0)],
    4: [Color(0xFFF1D9C4), Color(0xFFDEBD96)],
  };

  static const List<Color> _fallbackGradient = [
    Color(0xFFF2E1CC),
    Color(0xFFE0C6A4),
  ];

  static List<Color> gradientForLevel(int level) {
    return _levelGradients[level] ?? _fallbackGradient;
  }

  static Color badgeColor(int level, ColorScheme scheme) {
    switch (level) {
      case 1:
        return const Color(0xFF6DA77B);
      case 2:
        return const Color(0xFFC48F64);
      case 3:
        return const Color(0xFFB27A53);
      case 4:
        return const Color(0xFFA96A48);
      default:
        return scheme.primary;
    }
  }

  static Color accentForLevel(int level, ColorScheme scheme) {
    switch (level) {
      case 1:
        return const Color(0xFF4F8C69);
      case 2:
        return const Color(0xFFAA7A4E);
      case 3:
        return const Color(0xFF8D6747);
      case 4:
        return const Color(0xFF7F5137);
      default:
        return scheme.primary;
    }
  }
}
