import 'package:flutter/material.dart';

class AppColors {
  static const Color creamBackground = Color(0xFFF7E9D7);
  static const Color creamSurface = Color(0xFFF0DDC2);
  static const Color creamSurfaceHigh = Color(0xFFE6D0B2);
  static const Color accentGreen = Color(0xFF6DA77B);
  static const Color accentGreenDark = Color(0xFF4F8C69);
  static const Color accentBrown = Color(0xFFC48F64);
  static const Color accentDark = Color(0xFF4E3B31);
  static const Color outline = Color(0xFFBDA687);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.accentGreen,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF9EC9A5),
      onPrimaryContainer: AppColors.accentDark,
      secondary: AppColors.accentBrown,
      onSecondary: AppColors.accentDark,
      secondaryContainer: Color(0xFFDDC2A1),
      onSecondaryContainer: AppColors.accentDark,
      tertiary: Color(0xFFB07850),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE4B89A),
      onTertiaryContainer: AppColors.accentDark,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      background: AppColors.creamBackground,
      onBackground: AppColors.accentDark,
      surface: AppColors.creamSurface,
      onSurface: AppColors.accentDark,
      surfaceTint: AppColors.accentGreen,
      surfaceVariant: AppColors.creamSurfaceHigh,
      onSurfaceVariant: AppColors.accentDark,
      outline: AppColors.outline,
      outlineVariant: Color(0xFFDCC6A9),
      shadow: Colors.black12,
      scrim: Colors.black54,
      inverseSurface: Color(0xFF3D2F24),
      onInverseSurface: AppColors.creamBackground,
      inversePrimary: AppColors.accentGreenDark,
    );

    final textTheme = Typography.englishLike2021.apply(
      displayColor: scheme.onBackground,
      bodyColor: scheme.onBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.background,
      cardColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.background,
        foregroundColor: scheme.onBackground,
        elevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: scheme.onBackground,
          fontWeight: FontWeight.w700,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withOpacity(0.18),
        height: 72,
        labelTextStyle: MaterialStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: states.contains(MaterialState.selected)
                ? scheme.primary
                : scheme.onSurface.withOpacity(0.7),
          ),
        ),
        iconTheme: MaterialStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(MaterialState.selected)
                ? scheme.primary
                : scheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surface,
        selectedColor: scheme.primary.withOpacity(0.15),
        labelStyle: textTheme.bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outline.withOpacity(0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.outline.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary.withOpacity(0.6)),
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
