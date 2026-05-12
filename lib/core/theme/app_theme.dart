import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

// ─── Backward compat re-export ─────────────────────────
// Existing screens import AppColors/AppGradients/AppTextStyles from app_theme.dart.
// Re-export so those imports don't break.
export 'colors.dart' show AppColors;
export 'gradients.dart' show AppGradients;
export 'text_styles.dart' show AppTextStyles;

//////////////////////////////////////////////////////////////
// 🧱 FRESHIO — THEME DATA (main theme)
// Imports: colors.dart → text_styles.dart → app_theme.dart
//
// Usage in main.dart:
//   theme: AppTheme.light,
//////////////////////////////////////////////////////////////

class AppTheme {
  AppTheme._(); // prevent instantiation

  // ─── SOFT SHADOW RECIPE ───────────────────────────────
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cherryGlow(double opacity) => [
    BoxShadow(
      color: AppColors.cherry.withOpacity(opacity),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── POPPINS TEXT THEME ───────────────────────────────
  static TextTheme _buildTextTheme() {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: 48, fontWeight: FontWeight.w800,
        color: AppColors.textPrimary, letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 36, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -1.0,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 28, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.5,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: -0.3,
      ),
      headlineMedium: GoogleFonts.poppins(
        fontSize: 20, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary, letterSpacing: -0.2,
      ),
      headlineSmall: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.6,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w400,
        color: AppColors.textPrimary, height: 1.6,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w400,
        color: AppColors.textSecondary, height: 1.5,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 14, fontWeight: FontWeight.w700,
        color: AppColors.textPrimary, letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: AppColors.textSecondary, letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.poppins(
        fontSize: 10, fontWeight: FontWeight.w700,
        color: AppColors.textSecondary, letterSpacing: 1.0,
      ),
    );
  }

  // ─── LIGHT THEME ──────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,

    //── Color Scheme ──────────────────────────────────────
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.cherry,
      onPrimary: AppColors.textWhite,
      primaryContainer: AppColors.cherry.withOpacity(0.1),
      onPrimaryContainer: AppColors.cherry,
      secondary: AppColors.matcha,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.matcha.withOpacity(0.2),
      onSecondaryContainer: AppColors.textPrimary,
      tertiary: AppColors.peach,
      onTertiary: AppColors.textWhite,
      tertiaryContainer: AppColors.peach.withOpacity(0.15),
      onTertiaryContainer: AppColors.orange,
      error: AppColors.danger,
      onError: AppColors.textWhite,
      surface: AppColors.backgroundLight,
      onSurface: AppColors.textPrimary,
      surfaceContainerHighest: AppColors.surfaceWhite,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.borderLight.withOpacity(0.5),
    ),

    scaffoldBackgroundColor: AppColors.backgroundLight,

    //── Text ──────────────────────────────────────────────
    textTheme: _buildTextTheme(),

    //── App Bar ───────────────────────────────────────────
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimary,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    ),

    //── Card ──────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: AppColors.surfaceWhite,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
    ),

    //── Elevated Button ───────────────────────────────────
    // Note: primary buttons use PrimaryButton widget (gradient).
    // This theme covers fallback ElevatedButton usages.
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.cherry),
        foregroundColor: WidgetStateProperty.all(AppColors.textWhite),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
        elevation: WidgetStateProperty.all(0),
        shadowColor: WidgetStateProperty.all(Colors.transparent),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    ),

    //── Outlined Button ───────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColors.cherry),
        side: WidgetStateProperty.all(
          const BorderSide(color: AppColors.cherry, width: 1.5),
        ),
        minimumSize: WidgetStateProperty.all(const Size(double.infinity, 56)),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.3),
        ),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
    ),

    //── Text Button ───────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(AppColors.cherry),
        textStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    ),

    //── Input Fields ──────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary.withOpacity(0.6),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.cherry, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
    ),

    //── Bottom Navigation Bar ─────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceWhite,
      selectedItemColor: AppColors.cherry,
      unselectedItemColor: AppColors.textSecondary,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w400),
    ),

    //── FAB ───────────────────────────────────────────────
    // Use GradientFAB widget from reusable_widgets.dart for gradient FABs.
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.cherry,
      foregroundColor: AppColors.textWhite,
      elevation: 4,
      shape: CircleBorder(),
    ),

    //── Tab Bar ───────────────────────────────────────────
    tabBarTheme: TabBarThemeData(
      labelColor: AppColors.cherry,
      unselectedLabelColor: AppColors.textSecondary,
      indicatorColor: AppColors.cherry,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: Colors.transparent,
      labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
    ),

    //── Chip ──────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.backgroundLight,
      selectedColor: AppColors.cherry.withOpacity(0.12),
      labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: const BorderSide(color: AppColors.borderLight),
      elevation: 0,
      pressElevation: 0,
    ),

    //── Snackbar ──────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    //── Dialog ────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceWhite,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.6,
      ),
    ),

    //── Date Picker ───────────────────────────────────────
    datePickerTheme: const DatePickerThemeData(
      backgroundColor: AppColors.backgroundLight,
      headerBackgroundColor: AppColors.cherry,
      headerForegroundColor: Colors.white,
    ),

    //── Divider ───────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: AppColors.borderLight,
      thickness: 1,
      space: 1,
    ),

    //── ListTile ──────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    ),

    //── Icon ──────────────────────────────────────────────
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    primaryIconTheme: const IconThemeData(color: AppColors.textWhite, size: 24),
  );

  // ─── THEME alias (for backward compat with existing code)
  static ThemeData get theme => light;
}
