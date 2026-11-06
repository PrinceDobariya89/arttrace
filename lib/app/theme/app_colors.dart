import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette (Purple & Blue accents)
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5344CA);
  static const Color primaryLight = Color(0xFFA29BFE);

  static const Color secondary = Color(0xFF0984E3);
  static const Color secondaryLight = Color(0xFF74B9FF);

  // Gradient definitions
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C5CE7), Color(0xFF0984E3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient premiumGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFF8000), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF232530), Color(0xFF1B1C24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Accent & Status
  static const Color accent = Color(0xFF00CEC9);
  static const Color warning = Color(0xFFFFB300);
  static const Color success = Color(0xFF00B894);
  static const Color error = Color(0xFFD63031);

  // Light theme neutrals
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1A24);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textMutedLight = Color(0xFFB2BEC3);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark theme neutrals
  static const Color backgroundDark = Color(0xFF0F1016);
  static const Color surfaceDark = Color(0xFF1A1C24);
  static const Color cardDark = Color(0xFF232530);
  static const Color textPrimaryDark = Color(0xFFF5F6FA);
  static const Color textSecondaryDark = Color(0xFFA4B0BE);
  static const Color textMutedDark = Color(0xFF57606F);
  static const Color borderDark = Color(0xFF2E3240);

  // AR Tracing canvas overlays
  static const Color canvasLocked = Color(0xFFE74C3C);
  static const Color canvasActive = Color(0xFF00B894);
}

