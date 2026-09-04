import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds a ThemeData from the given palette and text scale.
ThemeData buildAppTheme({
  required AppColors colors,
  required double textScale,
}) {
  final baseTextTheme = ThemeData.light().textTheme;

  TextStyle scaled(TextStyle style) {
    return style.copyWith(
      fontSize: (style.fontSize ?? 14) * textScale,
    );
  }

  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: colors.background,
    colorScheme: ColorScheme.light(
      primary: colors.primary,
      secondary: colors.secondary,
      error: colors.danger,
      surface: colors.surface,
      onPrimary: colors.textOnPrimary,
      onSurface: colors.textPrimary,
    ),
    textTheme: baseTextTheme.copyWith(
      displayLarge: scaled(
        (baseTextTheme.displayLarge ?? const TextStyle()).copyWith(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
      headlineMedium: scaled(
        (baseTextTheme.headlineMedium ?? const TextStyle()).copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
      titleLarge: scaled(
        (baseTextTheme.titleLarge ?? const TextStyle()).copyWith(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
      bodyLarge: scaled(
        (baseTextTheme.bodyLarge ?? const TextStyle()).copyWith(
          fontSize: 18,
          color: colors.textPrimary,
        ),
      ),
      bodyMedium: scaled(
        (baseTextTheme.bodyMedium ?? const TextStyle()).copyWith(
          fontSize: 16,
          color: colors.textSecondary,
        ),
      ),
      labelLarge: scaled(
        (baseTextTheme.labelLarge ?? const TextStyle()).copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: scaled(
        TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: colors.textPrimary,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        side: BorderSide(
          color: colors.border,
          width: 1,
        ),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.textOnPrimary,
        minimumSize: const Size.fromHeight(kMinTouchTarget),
        textStyle: scaled(
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.primary,
        minimumSize: const Size.fromHeight(kMinTouchTarget),
        side: BorderSide(
          color: colors.primary,
          width: 2,
        ),
        textStyle: scaled(
          const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(
          color: colors.border,
          width: 2,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(
          color: colors.border,
          width: 2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide(
          color: colors.primary,
          width: 2,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.surface,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.textMuted,
      selectedLabelStyle: scaled(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      unselectedLabelStyle: scaled(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      type: BottomNavigationBarType.fixed,
    ),
    dividerColor: colors.border,
    extensions: [
      AppColorsExtension(colors),
    ],
  );
}
