import 'package:flutter/material.dart';

class AppColors {
  static const Color snowBackground = Color(0xFFFFF7EF);
  static const Color snowSurface = Color(0xFFF9F0E3);
  static const Color snowSurfaceHigh = Color(0xFFECDCC5);
  static const Color hollyRed = Color(0xFFC81D25);
  static const Color hollyRedDark = Color(0xFF8F0E1A);
  static const Color pineGreen = Color(0xFF1E6F43);
  static const Color pineGreenDark = Color(0xFF0F4B2D);
  static const Color warmGold = Color(0xFFE0C06B);
  static const Color outline = Color(0xFFD6C6B1);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.hollyRed,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFF4C7CF),
      onPrimaryContainer: AppColors.hollyRedDark,
      secondary: AppColors.pineGreen,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFD2E8DA),
      onSecondaryContainer: AppColors.pineGreenDark,
      tertiary: AppColors.warmGold,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFF1DFB0),
      onTertiaryContainer: Color(0xFF4A3C12),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      background: AppColors.snowBackground,
      onBackground: AppColors.pineGreenDark,
      surface: AppColors.snowSurface,
      onSurface: AppColors.pineGreenDark,
      surfaceTint: AppColors.hollyRed,
      surfaceVariant: AppColors.snowSurfaceHigh,
      onSurfaceVariant: AppColors.pineGreenDark,
      outline: AppColors.outline,
      outlineVariant: Color(0xFFDCC6A9),
      shadow: Colors.black12,
      scrim: Colors.black54,
      inverseSurface: Color(0xFF243224),
      onInverseSurface: AppColors.snowBackground,
      inversePrimary: AppColors.hollyRedDark,
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
