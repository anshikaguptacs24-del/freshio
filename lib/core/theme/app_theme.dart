import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
// 🎨 FRESHIO — "PEACH & SAGE" PALETTE
//
//  Primary     → Terracotta   #D4775A
//  Secondary   → Sage Green   #7BA05B
//  Background  → Warm Linen   #FDF6ED
//  Card        → Soft Peach   #FFF1E8
//  Accent      → Honey Yellow #F4C542
//  Danger      → Dusty Rose   #E07070
//  Text        → Espresso     #2D1B10
//////////////////////////////////////////////////////////////

class AppColors {
  // Core palette
  static const Color primary     = Color(0xFFD4775A); // Terracotta
  static const Color secondary   = Color(0xFF7BA05B); // Sage Green
  static const Color accent      = Color(0xFFF4C542); // Honey Yellow
  static const Color danger      = Color(0xFFE07070); // Dusty Rose

  // Surfaces
  static const Color background  = Color(0xFFFDF6ED); // Warm Linen
  static const Color card        = Color(0xFFFFF1E8); // Soft Peach
  static const Color surface     = Color(0xFFFFFFFF); // White

  // Text
  static const Color textDark    = Color(0xFF2D1B10); // Espresso
  static const Color textMuted   = Color(0xFF8C6D5A); // Muted brown
  static const Color textOnPrimary = Colors.white;

  // Status colors (for freshness indicators)
  static const Color fresh       = Color(0xFF7BA05B); // Sage Green
  static const Color expiring    = Color(0xFFF4C542); // Honey Yellow
  static const Color expired     = Color(0xFFE07070); // Dusty Rose
  static const Color waste       = Color(0xFFBDAEA5); // Warm grey
}

class AppTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,

    ////////////////////////////////////////////////////////////
    // 🌈 COLOR SCHEME — Terracotta seed
    ////////////////////////////////////////////////////////////

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.card,
      error: AppColors.danger,
      brightness: Brightness.light,
    ),

    scaffoldBackgroundColor: AppColors.background,

    ////////////////////////////////////////////////////////////
    // 🧭 APP BAR
    ////////////////////////////////////////////////////////////

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textDark,
      titleTextStyle: TextStyle(
        color: AppColors.textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),

    ////////////////////////////////////////////////////////////
    // 📦 CARD
    ////////////////////////////////////////////////////////////

    cardTheme: const CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    ////////////////////////////////////////////////////////////
    // 🔘 ELEVATED BUTTON
    ////////////////////////////////////////////////////////////

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(double.infinity, 50),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    ////////////////////////////////////////////////////////////
    // ✏️ INPUT FIELDS
    ////////////////////////////////////////////////////////////

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      labelStyle: const TextStyle(color: AppColors.textMuted),
      hintStyle: const TextStyle(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8D5C8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE8D5C8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    ),

    ////////////////////////////////////////////////////////////
    // 🔤 TEXT
    ////////////////////////////////////////////////////////////

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark),
      bodyMedium: TextStyle(color: AppColors.textDark),
      bodySmall: TextStyle(color: AppColors.textMuted),
      titleLarge: TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: AppColors.textDark,
        fontWeight: FontWeight.w600,
      ),
    ),

    ////////////////////////////////////////////////////////////
    // 🗂️ BOTTOM NAV BAR
    ////////////////////////////////////////////////////////////

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),

    ////////////////////////////////////////////////////////////
    // 💬 SNACKBAR
    ////////////////////////////////////////////////////////////

    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textDark,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      behavior: SnackBarBehavior.floating,
    ),

    ////////////////////////////////////////////////////////////
    // 📅 DATE PICKER
    ////////////////////////////////////////////////////////////

    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.background,
      headerBackgroundColor: AppColors.primary,
      headerForegroundColor: Colors.white,
    ),

    ////////////////////////////////////////////////////////////
    // 🎭 FLOATING ACTION BUTTON
    ////////////////////////////////////////////////////////////

    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
    ),
  );
}