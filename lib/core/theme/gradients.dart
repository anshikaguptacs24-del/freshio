import 'package:flutter/material.dart';
import 'colors.dart';

//////////////////////////////////////////////////////////////
// 🌈 FRESHIO — GRADIENT SYSTEM
// All gradients are defined here. No inline gradients allowed
// in screens — always import from this file.
//////////////////////////////////////////////////////////////

class AppGradients {
  AppGradients._(); // prevent instantiation

  // ─── 1. PRIMARY (Cherry) ───────────────────────────────
  /// Main CTA gradient — buttons, headers, FABs.
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cherry, AppColors.deepMaroon],
  );

  /// Vertical variant for hero banners.
  static const LinearGradient primaryVertical = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.cherry, AppColors.deepMaroon],
  );

  /// Subtle tint for card backgrounds.
  static LinearGradient primarySoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.cherry.withOpacity(0.08), AppColors.cherry.withOpacity(0.02)],
  );

  // ─── 2. FRESH (Matcha) ─────────────────────────────────
  /// Fresh / nature accent — fresh food tags, success states.
  static const LinearGradient fresh = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.matcha, AppColors.softGreen],
  );

  static LinearGradient freshSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.matcha.withOpacity(0.15), AppColors.softGreen.withOpacity(0.05)],
  );

  // ─── 3. FOOD (Peach/Orange) ────────────────────────────
  /// Warm accent — food cards, highlights, expiring items.
  static const LinearGradient food = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.peach, AppColors.orange],
  );

  static LinearGradient foodSoft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.peach.withOpacity(0.15), AppColors.orange.withOpacity(0.05)],
  );

  // ─── 4. DARK BACKGROUND ────────────────────────────────
  /// Full-screen dark bg — splash, onboarding, overlays.
  static const LinearGradient darkBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.backgroundDark, AppColors.greenBlack],
  );

  static const LinearGradient darkBackgroundDiagonal = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.backgroundDark, AppColors.greenBlack],
  );

  // ─── 5. STATUS GRADIENTS ───────────────────────────────
  static const LinearGradient success = LinearGradient(
    colors: [Color(0xFF6BCB77), Color(0xFF4CAF61)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warning = LinearGradient(
    colors: [Color(0xFFFFD166), Color(0xFFFFB830)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient danger = LinearGradient(
    colors: [Color(0xFFEF476F), Color(0xFFCC2E50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── 6. GLASS OVERLAY ──────────────────────────────────
  /// Overlay on images/backgrounds for glassmorphism layers.
  static const LinearGradient glassOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
  );

  /// Dark image overlay (bottom fade on FoodCards).
  static const LinearGradient imageScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC000000)],
  );

  // ─── Helper: expiry gradient by days left ──────────────
  static LinearGradient forExpiryDays(int days) {
    if (days < 0) return danger;
    if (days <= 2) return warning;
    if (days <= 5) return food;
    return fresh;
  }
}
