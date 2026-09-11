import 'package:flutter/material.dart';

/// Standard palette — warm cream surfaces with a deep forest teal-green
/// primary and a terracotta/amber accent, echoing the woven textiles and
/// hills of Northeast India. Chosen to stay calm and easy on aging eyes
/// while giving the app a distinct, professional, regional identity.
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

  // Decorative accent set used for the colourful rounded icon tiles seen
  // throughout the reference UI (feature grids, activity chips, etc.).
  // Purely cosmetic — never used for status/meaning.
  final Color accentRose;
  final Color accentRoseLight;
  final Color accentViolet;
  final Color accentVioletLight;
  final Color accentSky;
  final Color accentSkyLight;
  final Color accentPeach;
  final Color accentPeachLight;

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
    required this.accentRose,
    required this.accentRoseLight,
    required this.accentViolet,
    required this.accentVioletLight,
    required this.accentSky,
    required this.accentSkyLight,
    required this.accentPeach,
    required this.accentPeachLight,
  });

  /// Standard-contrast palette.
  static const standard = AppColors(
    background: Color(0xFFFAF3E7),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF0E9D8),
    primary: Color(0xFF0C6B54),
    primaryDark: Color(0xFF07473A),
    primaryLight: Color(0xFFDCEFE5),
    secondary: Color(0xFF1D6B86),
    accentAmber: Color(0xFFC96A1D),
    accentAmberLight: Color(0xFFFBE6D2),
    success: Color(0xFF1E8E5A),
    warning: Color(0xFFC96A1D),
    danger: Color(0xFFB3261E),
    dangerLight: Color(0xFFFBE4E2),
    textPrimary: Color(0xFF1B2621),
    textSecondary: Color(0xFF4C5C55),
    textMuted: Color(0xFF7C8C84),
    textOnPrimary: Color(0xFFFFFFFF),
    border: Color(0xFFE6DAC0),
    borderStrong: Color(0xFFB8A67E),
    caregiverAccent: Color(0xFF1D6B86),
    caregiverAccentLight: Color(0xFFDCEAF1),
    accentRose: Color(0xFFC4497B),
    accentRoseLight: Color(0xFFF8E1EB),
    accentViolet: Color(0xFF6E5AA8),
    accentVioletLight: Color(0xFFE7E1F5),
    accentSky: Color(0xFF2E7FB0),
    accentSkyLight: Color(0xFFDCEDF7),
    accentPeach: Color(0xFFDB8A3B),
    accentPeachLight: Color(0xFFFBEBD6),
  );

  /// High-contrast palette — pure black/white with saturated accents,
  /// used when the user turns on "High Contrast" in Settings. This
  /// actually swaps the theme, not just a filter. Decorative background
  /// art is suppressed on this palette (see NeBackground) so contrast
  /// is never compromised.
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
    accentRose: Color(0xFF7A0033),
    accentRoseLight: Color(0xFFFFD6E6),
    accentViolet: Color(0xFF2E2066),
    accentVioletLight: Color(0xFFE1D6FF),
    accentSky: Color(0xFF00324A),
    accentSkyLight: Color(0xFFCFE3F0),
    accentPeach: Color(0xFF7A3A00),
    accentPeachLight: Color(0xFFFFE1B0),
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
