import 'package:flutter/material.dart';

/// Visual tokens for the game surfaces.
///
/// Keep this file dependency-free so Home, Game Hub and Boss Battle can share
/// the same visual language without pulling in a game engine.
abstract final class GameVisualTokens {
  static const cream = Color(0xFFFFF8ED);
  static const creamStrong = Color(0xFFFFEED4);
  static const ink = Color(0xFF231B1B);
  static const muted = Color(0xFF776A67);

  static const blue = Color(0xFF2E93E8);
  static const green = Color(0xFF22B868);
  static const gold = Color(0xFFFFB62E);
  static const orange = Color(0xFFF47B2D);
  static const red = Color(0xFFE44737);
  static const burgundy = Color(0xFF7D1D24);
  static const night = Color(0xFF241728);

  static const radiusS = 12.0;
  static const radiusM = 18.0;
  static const radiusL = 24.0;
  static const radiusXL = 30.0;

  static const pagePadding = 16.0;
  static const sectionGap = 18.0;
  static const cardGap = 12.0;

  static const softShadow = [
    BoxShadow(
      color: Color(0x16000000),
      blurRadius: 18,
      offset: Offset(0, 8),
    ),
  ];

  static const gameShadow = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
  ];

  static const battleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF2C4A83),
      Color(0xFF8A4260),
      Color(0xFFF07B45),
      Color(0xFF211521),
    ],
    stops: [0, .42, .72, 1],
  );
}
