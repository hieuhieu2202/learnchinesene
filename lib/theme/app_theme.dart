import 'package:flutter/material.dart';

class AppColorsVer1Ne {
  // Tết-inspired colors
  static const Color tetRed = Color(0xFFFF2D2D); // Bright festive red
  static const Color tetRedDark = Color(0xFFD7263D); // Slightly darker red
  static const Color tetGold = Color(0xFFFFD700); // Gold/yellow
  static const Color tetGreen = Color(0xFF228B22); // Prosperity green
  static const Color background = Color(0xFFFFF8E1); // Light gold background
  static const Color surface = Color(0xFFFFFDE7); // Lighter gold surface
  static const Color surfaceHigh = Color(0xFFFFF9C4); // High surface gold
  static const Color outline = Color(0xFFE1B700); // Gold outline

  // Backwards-compat aliases (some screens still reference these names)
  static const Color snowBackground = background;
  static const Color snowSurface = surface;
  static const Color snowSurfaceHigh = surfaceHigh;
}

class AppThemeVer1Ne {
  const AppThemeVer1Ne._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColorsVer1Ne.tetRed,
      onPrimary: Colors.white,
      primaryContainer: AppColorsVer1Ne.tetGold,
      onPrimaryContainer: AppColorsVer1Ne.tetGreen,
      secondary: AppColorsVer1Ne.tetGreen,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFC5E3D3), // Optional: keep for contrast
      onSecondaryContainer: AppColorsVer1Ne.tetRedDark,
      tertiary: AppColorsVer1Ne.tetGold,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFE8B9),
      onTertiaryContainer: AppColorsVer1Ne.tetGreen,
      error: Color(0xFFC62828),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: AppColorsVer1Ne.surface,
      onSurface: AppColorsVer1Ne.tetRedDark,
      surfaceTint: AppColorsVer1Ne.tetGold,
      surfaceContainerHighest: AppColorsVer1Ne.surfaceHigh,
      onSurfaceVariant: AppColorsVer1Ne.tetGreen,
      outline: AppColorsVer1Ne.outline,
      outlineVariant: Color(0xFFFFECB3),
      shadow: Colors.black12,
      scrim: Colors.black54,
      inverseSurface: AppColorsVer1Ne.tetRedDark,
      onInverseSurface: AppColorsVer1Ne.background,
      inversePrimary: AppColorsVer1Ne.tetRedDark,
    );

    final textTheme = Typography.englishLike2021.apply(
      displayColor: scheme.onSurface,
      bodyColor: scheme.onSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      cardColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withAlpha(46),
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurface.withAlpha(179),
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurface.withAlpha(153),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary.withAlpha(38),
        labelStyle: textTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outline.withAlpha(77)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withAlpha(77)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withAlpha(64)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary.withAlpha(153)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.secondary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

@Deprecated('Use AppColorsVer1Ne')
typedef AppColors = AppColorsVer1Ne;

@Deprecated('Use AppThemeVer1Ne')
typedef AppTheme = AppThemeVer1Ne;
