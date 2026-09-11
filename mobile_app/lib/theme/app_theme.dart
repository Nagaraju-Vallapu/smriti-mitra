import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds a ThemeData from the given palette and text scale. Called with
/// AppColors.standard/highContrast and the user's AppTextSize scale
/// factor, so both accessibility settings ("Text Size" and "High
/// Contrast") flow through one place.
ThemeData buildAppTheme({required AppColors colors, required double textScale}) {
  final baseTextTheme = ThemeData.light().textTheme;

  TextStyle scaled(TextStyle style) =>
      style.copyWith(fontSize: (style.fontSize ?? 14) * textScale);

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: colors.background,
    fontFamily: 'Roboto',
    colorScheme: ColorScheme.light(
      primary: colors.primary,
      secondary: colors.secondary,
      error: colors.danger,
      surface: colors.surface,
      onPrimary: colors.textOnPrimary,
      onSurface: colors.textPrimary,
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: scaled(baseTextTheme.displayLarge!.copyWith(
          fontSize: 40, fontWeight: FontWeight.bold, color: colors.textPrimary, letterSpacing: -0.5)),
      headlineMedium: scaled(baseTextTheme.headlineMedium!.copyWith(
          fontSize: 28, fontWeight: FontWeight.bold, color: colors.textPrimary, letterSpacing: -0.3)),
      titleLarge: scaled(baseTextTheme.titleLarge!.copyWith(
          fontSize: 22, fontWeight: FontWeight.bold, color: colors.textPrimary)),
      bodyLarge: scaled(baseTextTheme.bodyLarge!.copyWith(
          fontSize: 18, color: colors.textPrimary)),
      bodyMedium: scaled(baseTextTheme.bodyMedium!.copyWith(
          fontSize: 16, color: colors.textSecondary)),
      labelLarge: scaled(baseTextTheme.labelLarge!.copyWith(
          fontSize: 16, fontWeight: FontWeight.bold)),
    ),
    appBarTheme: AppBarTheme(
      // Transparent so every screen's NeBackground shows straight
      // through the app bar area for a seamless, immersive look.
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: scaled(TextStyle(
          fontSize: 22, fontWeight: FontWeight.bold, color: colors.textPrimary)),
      iconTheme: IconThemeData(color: colors.primaryDark),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 6,
      shadowColor: colors.primaryDark.withOpacity(0.16),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        side: BorderSide(color: colors.border, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        minimumSize: const Size.fromHeight(kMinTouchTarget),
        elevation: 3,
        shadowColor: colors.primaryDark.withOpacity(0.35),
        textStyle: scaled(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        backgroundColor: colors.surface,
        minimumSize: const Size.fromHeight(kMinTouchTarget),
        side: BorderSide(color: colors.primary, width: 2),
        textStyle: scaled(const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.pill)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colors.border, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colors.border, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.surface,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.textMuted,
      selectedLabelStyle: scaled(const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      unselectedLabelStyle: scaled(const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerColor: colors.border,
    extensions: [AppColorsExtension(colors)],
  );
}
