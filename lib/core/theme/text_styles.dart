import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

//////////////////////////////////////////////////////////////
// 🔤 FRESHIO — TEXT STYLE SYSTEM
// All typography is Poppins via Google Fonts.
// Do NOT use raw TextStyle in screens — always import here.
//////////////////////////////////////////////////////////////

class AppTextStyles {
  AppTextStyles._(); // prevent instantiation

  // ─── DISPLAY ───────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.poppins(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.1,
  );

  static TextStyle get displayMedium => GoogleFonts.poppins(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.15,
  );

  static TextStyle get displaySmall => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  // ─── HEADLINE ──────────────────────────────────────────
  static TextStyle get headlineLarge => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.25,
  );

  static TextStyle get headlineMedium => GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle get headlineSmall => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.35,
  );

  // ─── TITLE ─────────────────────────────────────────────
  static TextStyle get titleLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle get titleMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static TextStyle get titleSmall => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ─── BODY ──────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.6,
  );

  static TextStyle get bodySmall => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ─── LABEL ─────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 1.0,
  );

  // ─── SPECIAL STYLES ────────────────────────────────────

  /// Section chips / tags (ALL CAPS, bold)
  static TextStyle get sectionTag => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: AppColors.textSecondary,
    letterSpacing: 1.5,
  );

  /// Button text (medium weight, slightly large)
  static TextStyle get button => GoogleFonts.poppins(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  /// White text variants for dark/gradient backgrounds
  static TextStyle get displaySmallWhite => displaySmall.copyWith(color: AppColors.textWhite);
  static TextStyle get headlineLargeWhite => headlineLarge.copyWith(color: AppColors.textWhite);
  static TextStyle get headlineMediumWhite => headlineMedium.copyWith(color: AppColors.textWhite);
  static TextStyle get headlineSmallWhite => headlineSmall.copyWith(color: AppColors.textWhite);
  static TextStyle get bodyLargeWhite => bodyLarge.copyWith(color: AppColors.textWhite);
  static TextStyle get bodyMediumWhite => bodyMedium.copyWith(color: AppColors.textWhite);
  static TextStyle get bodySmallWhite => bodySmall.copyWith(color: AppColors.textWhite.withOpacity(0.75));
  static TextStyle get buttonWhite => button.copyWith(color: AppColors.textWhite);
  static TextStyle get sectionTagWhite => sectionTag.copyWith(color: AppColors.textWhite.withOpacity(0.7));
}
