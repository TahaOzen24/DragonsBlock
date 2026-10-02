import 'package:flutter/material.dart';

/// Central design system for Block Survivor.
///
/// All colors, typography, spacing, radii and glows should be defined here and
/// consumed by widgets instead of hard-coded values. This keeps the visual
/// identity consistent and makes global restyling a one-file change.
class GameTheme {
  GameTheme._();

  // ─── Font Families ────────────────────────────────────────────────────────
  static const String fontOutfit = 'Outfit';
  static const String fontSpaceGrotesk = 'SpaceGrotesk';

  // ─── Vibrant Cosmic Royal Background Colors ────────────────────────────────
  static const Color bgDarkest = Color(0xFF0C1427);
  static const Color bgDark = Color(0xFF111D38);
  static const Color bgSurface = Color(0xFF162548);
  static const Color bgSurfaceLight = Color(0xFF1E3A8A);
  static const Color bgDeep = Color(0xFF030712);
  static const Color gridEmptyCell = Color(0xFF13203E);
  static const Color gridBorder = Color(0xFF2563EB);
  static const Color divider = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF0F172A);

  // ─── Elemental & Neon Accent Colors ───────────────────────────────────────
  static const Color neonCyan = Color(0xFF00F2FE);
  static const Color neonBlue = Color(0xFF4FACFE);
  static const Color fireOrange = Color(0xFFFF5E3A);
  static const Color fireYellow = Color(0xFFFF9500);
  static const Color lightningYellow = Color(0xFFFFD200);
  static const Color lightningWhite = Color(0xFFFFF9E6);
  static const Color frostCyan = Color(0xFF38E8FF);
  static const Color frostDeep = Color(0xFF0091FF);
  static const Color voidPurple = Color(0xFFB026FF);
  static const Color voidDeep = Color(0xFF6B11B2);
  static const Color goldAccent = Color(0xFFFFB800);
  static const Color emeraldGreen = Color(0xFF00E676);
  static const Color earthGreen = Color(0xFF4CAF50);
  static const Color success = Color(0xFF00E676);
  static const Color danger = Color(0xFFFF5E3A);

  // ─── Text Colors ──────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9EABB8);
  static const Color textMuted = Color(0xFF5A667A);

  // ─── Typography ───────────────────────────────────────────────────────────
  // Primary typeface (Outfit) — used for the vast majority of UI text.
  static TextStyle outfit({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: fontOutfit,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Secondary typeface (Space Grotesk) — used for big numeric/score displays.
  static TextStyle spaceGrotesk({
    double? size,
    FontWeight? weight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: fontSpaceGrotesk,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Legacy text styles — kept with their original sizes so existing call sites
  // do not regress. New code should prefer the semantic scale below.
  static TextStyle get titleLarge => outfit(size: 32, weight: FontWeight.w900, letterSpacing: 1.2, color: textPrimary);
  static TextStyle get scoreHuge => spaceGrotesk(size: 44, weight: FontWeight.w900, letterSpacing: -0.5, color: textPrimary);
  static TextStyle get labelBold => outfit(size: 16, weight: FontWeight.w700, letterSpacing: 0.5, color: textPrimary);
  static TextStyle get bodyMedium => outfit(size: 14, weight: FontWeight.w500, color: textSecondary);
  static TextStyle get comboText => spaceGrotesk(size: 22, weight: FontWeight.w900, letterSpacing: 1.0, color: lightningYellow);

  /// Semantic text style scale. Use these instead of raw sizes to keep a
  /// consistent hierarchy across the app.
  static TextStyle get displayLarge => outfit(size: 32, weight: FontWeight.w900, letterSpacing: 1.2, color: textPrimary);
  static TextStyle get displayMedium => outfit(size: 24, weight: FontWeight.w900, letterSpacing: 0.8, color: textPrimary);
  static TextStyle get titleMedium => outfit(size: 18, weight: FontWeight.w800, color: textPrimary);
  static TextStyle get titleSmall => outfit(size: 14, weight: FontWeight.w700, color: textPrimary);
  static TextStyle get bodyLarge => outfit(size: 15, weight: FontWeight.w500, color: textSecondary);
  static TextStyle get bodySmall => outfit(size: 12, weight: FontWeight.w500, color: textSecondary);
  static TextStyle get labelLarge => outfit(size: 13, weight: FontWeight.w700, letterSpacing: 0.3, color: textPrimary);
  static TextStyle get labelMedium => outfit(size: 11, weight: FontWeight.w700, letterSpacing: 0.3, color: textSecondary);
  static TextStyle get labelSmall => outfit(size: 9, weight: FontWeight.w700, letterSpacing: 0.5, color: textMuted);
  static TextStyle get caption => outfit(size: 10, weight: FontWeight.w600, color: textMuted);

  // Numeric / score display styles.
  static TextStyle get scoreLarge => spaceGrotesk(size: 28, weight: FontWeight.w900, color: textPrimary);

  // ─── Spacing Scale ────────────────────────────────────────────────────────
  // A 4-point scale. Prefer these over arbitrary SizedBox values.
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 20;
  static const double space6 = 24;
  static const double space8 = 32;
  static const double space10 = 40;

  // ─── Radius Scale ─────────────────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radius2Xl = 24;
  static const double radiusPill = 999;

  // ─── Elevation & Opacity Tokens ───────────────────────────────────────────
  static const double borderSubtle = 0.35;
  static const double borderStrong = 0.6;
  static const double borderEmphasis = 1.5;

  // ─── Glow Shadows ─────────────────────────────────────────────────────────
  static List<BoxShadow> cyanGlow({double blur = 16, double spread = 2}) => [
        BoxShadow(
          color: neonCyan.withValues(alpha: 0.5),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  static List<BoxShadow> fireGlow({double blur = 16, double spread = 2}) => [
        BoxShadow(
          color: fireOrange.withValues(alpha: 0.6),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  static List<BoxShadow> purpleGlow({double blur = 16, double spread = 2}) => [
        BoxShadow(
          color: voidPurple.withValues(alpha: 0.6),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  static List<BoxShadow> goldGlow({double blur = 18, double spread = 3}) => [
        BoxShadow(
          color: goldAccent.withValues(alpha: 0.7),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];
}
