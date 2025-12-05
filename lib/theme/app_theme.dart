import 'package:flutter/material.dart';

class AppColors {
  static const Color snowBackground = Color(0xFFF7FAFD);
  static const Color snowSurface = Color(0xFFE8F0F6);
  static const Color snowSurfaceHigh = Color(0xFFDCE7F0);
  static const Color hollyRed = Color(0xFFD7263D);
  static const Color hollyRedDark = Color(0xFFB01F32);
  static const Color firGreen = Color(0xFF0F5132);
  static const Color pineGreen = Color(0xFF0A3F26);
  static const Color candleGold = Color(0xFFF4CE73);
  static const Color outline = Color(0xFFB5C6D8);
}

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.hollyRed,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFFFD0D6),
      onPrimaryContainer: AppColors.pineGreen,
      secondary: AppColors.firGreen,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFC5E3D3),
      onSecondaryContainer: AppColors.pineGreen,
      tertiary: AppColors.candleGold,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFE8B9),
      onTertiaryContainer: AppColors.pineGreen,
      error: Color(0xFFC62828),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      background: AppColors.snowBackground,
      onBackground: AppColors.pineGreen,
      surface: AppColors.snowSurface,
      onSurface: AppColors.pineGreen,
      surfaceTint: AppColors.hollyRed,
      surfaceVariant: AppColors.snowSurfaceHigh,
      onSurfaceVariant: AppColors.pineGreen,
      outline: AppColors.outline,
      outlineVariant: Color(0xFFD1DEE9),
      shadow: Colors.black12,
      scrim: Colors.black54,
      inverseSurface: Color(0xFF0F2C1D),
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
