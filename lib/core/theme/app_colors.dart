import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const red = Color(0xFFE53935);
  static const redDark = Color(0xFFB71C1C);
  static const coral = Color(0xFFFF6B5F);
  static const orange = Color(0xFFFF9F43);
  static const gold = Color(0xFFFFC857);

  // Learning states
  static const success = Color(0xFF18A56F);
  static const warning = Color(0xFFF4A340);
  static const error = Color(0xFFE5484D);
  static const info = Color(0xFF4A7DFF);

  // Light surfaces
  static const background = Color(0xFFF7F8FC);
  static const surfaceSoft = Color(0xFFF0F2F8);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF191B24);
  static const muted = Color(0xFF737887);
  static const outline = Color(0xFFE2E5EE);

  // Dark surfaces
  static const darkBackground = Color(0xFF101116);
  static const darkSurface = Color(0xFF181A21);
  static const darkSurfaceSoft = Color(0xFF22252E);
  static const darkOutline = Color(0xFF303440);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE53935), Color(0xFFFF765F)],
  );

  static const rewardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB547), Color(0xFFFF7A45)],
  );
}
