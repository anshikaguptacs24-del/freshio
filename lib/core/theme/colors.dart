import 'package:flutter/material.dart';

//////////////////////////////////////////////////////////////
// 🎨 FRESHIO — DESIGN SYSTEM COLORS
// Single source of truth for all app colors.
//////////////////////////////////////////////////////////////

class AppColors {
  AppColors._(); // prevent instantiation

  // ─── PRIMARY ───────────────────────────────────────────
  static const Color cherry        = Color(0xFF670626); // Primary
  static const Color deepMaroon    = Color(0xFF3A0415); // Primary dark (gradient end)

  // ─── SECONDARY ─────────────────────────────────────────
  static const Color matcha        = Color(0xFFBAD797); // Secondary
  static const Color softGreen     = Color(0xFF8FCB81); // Secondary dark (gradient end)

  // ─── ACCENT ────────────────────────────────────────────
  static const Color peach         = Color(0xFFFF9B71); // Accent warm
  static const Color orange        = Color(0xFFFF6A3D); // Accent dark (gradient end)

  // ─── BACKGROUNDS ───────────────────────────────────────
  static const Color backgroundDark  = Color(0xFF0F2E2E);
  static const Color backgroundLight = Color(0xFFF5F7F2);
  static const Color greenBlack      = Color(0xFF092020); // dark bg gradient end
  static const Color surfaceWhite    = Color(0xFFFFFFFF);
  static const Color cardLight       = Color(0xFFFAFCF7); // card surface on light bg

  // ─── TEXT ──────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textWhite     = Color(0xFFFFFFFF);
  static const Color textOnCherry  = Color(0xFFFFFFFF);

  // ─── STATUS ────────────────────────────────────────────
  static const Color success  = Color(0xFF6BCB77); // Consumed
  static const Color warning  = Color(0xFFFFD166); // Expiring soon
  static const Color danger   = Color(0xFFEF476F); // Waste / Expired

  // ─── GLASSMORPHISM ─────────────────────────────────────
  static const Color glassWhite = Color(0x26FFFFFF); // white at 15% opacity
  static const Color glassDark  = Color(0x260F2E2E); // dark at 15% opacity

  // ─── BORDERS / DIVIDERS ────────────────────────────────
  static const Color borderLight = Color(0xFFE8EDE5);
  static const Color borderDark  = Color(0xFF1A3A3A);

  // ─── ALIASES (for backward compat with theme) ──────────
  static const Color primary    = cherry;
  static const Color secondary  = matcha;
  static const Color accent     = peach;
  static const Color background = backgroundLight;
  static const Color textMuted  = textSecondary;

  // ─── STATUS ALIASES ────────────────────────────────────
  static const Color waste    = danger;
  static const Color expired  = danger;
  static const Color expiring = warning;
  static const Color fresh    = success;

  // ─── EXPIRY STATUS helpers ─────────────────────────────
  /// Returns a color based on how many days remain.
  static Color expiryColor(int daysLeft) {
    if (daysLeft < 0) return danger;
    if (daysLeft <= 2) return warning;
    if (daysLeft <= 5) return peach;
    return success;
  }
}
