import 'package:flutter/material.dart';

/// Standard palette — calm teal/sage, chosen to be easy on aging eyes.
/// A subtle amber accent (echoing North-East Indian textile motifs used
/// throughout the app's iconography) marks anything needing attention.
class AppColors {
  final Color background;
  final Color surface;
  final Color surfaceAlt;

  final Color primary;
  final Color primaryDark;
  final Color primaryLight;

  final Color secondary;
  final Color accentAmber;
  final Color accentAmberLight;

  final Color success;
  final Color warning;
  final Color danger;
  final Color dangerLight;

  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color textOnPrimary;

  final Color border;
  final Color borderStrong;

  final Color caregiverAccent;
  final Color caregiverAccentLight;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.secondary,
    required this.accentAmber,
    required this.accentAmberLight,
    required this.success,
    required this.warning,
    required this.danger,
    required this.dangerLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.textOnPrimary,
    required this.border,
    required this.borderStrong,
    required this.caregiverAccent,
    required this.caregiverAccentLight,
  });

  /// Standard-contrast palette.
  static const standard = AppColors(
    background: Color(0xFFF4F7F5),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEAF1EE),
    primary: Color(0xFF0E6E5C),
    primaryDark: Color(0xFF0A4F42),
    primaryLight: Color(0xFFDCEFE9),
    secondary: Color(0xFF1D5B79),
    accentAmber: Color(0xFFC77B12),
    accentAmberLight: Color(0xFFFBEBD5),
    success: Color(0xFF1E8E5A),
    warning: Color(0xFFC77B12),
    danger: Color(0xFFB3261E),
    dangerLight: Color(0xFFFBE4E2),
    textPrimary: Color(0xFF122622),
    textSecondary: Color(0xFF3F5750),
    textMuted: Color(0xFF6B8079),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFD3E2DC),
    borderStrong: Color(0xFF9FB8B0),
    caregiverAccent: Color(0xFF1D5B79),
    caregiverAccentLight: Color(0xFFDCEAF1),
  );

  /// High-contrast palette — pure black/white with saturated accents,
  /// used when the user turns on "High Contrast" in Settings. This
  /// actually swaps the theme, not just a filter.
  static const highContrast = AppColors(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0F0F0),
    primary: Color(0xFF00483A),
    primaryDark: Color(0xFF000000),
    primaryLight: Color(0xFFCFEFE6),
    secondary: Color(0xFF00324A),
    accentAmber: Color(0xFF7A4A00),
    accentAmberLight: Color(0xFFFFE1B0),
    success: Color(0xFF005C2E),
    warning: Color(0xFF7A4A00),
    danger: Color(0xFF7A0000),
    dangerLight: Color(0xFFFFD6D6),
    textPrimary: Color(0xFF000000),
    textSecondary: Color(0xFF000000),
    textMuted: Color(0xFF303030),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFF000000),
    borderStrong: Color(0xFF000000),
    caregiverAccent: Color(0xFF00324A),
    caregiverAccentLight: Color(0xFFCFE3F0),
  );
}

/// Wraps [AppColors] as a [ThemeExtension] so any widget can read the
/// currently-active palette (standard or high-contrast) via
/// `Theme.of(context).extension<AppColorsExtension>()`, without having to
/// thread AppColors through every constructor.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final AppColors colors;
  const AppColorsExtension(this.colors);

  @override
  AppColorsExtension copyWith({AppColors? colors}) =>
      AppColorsExtension(colors ?? this.colors);

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    // Palettes are discrete (standard vs. high-contrast), not
    // interpolated — snap to whichever side of the transition we're on.
    if (other is! AppColorsExtension) return this;
    return t < 0.5 ? this : other;
  }
}
