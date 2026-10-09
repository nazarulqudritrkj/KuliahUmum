import 'package:flutter/material.dart';

class AppColors {
  // Vibrant Bright Purple Palette
  static const Color primaryPurple = Color(0xFF7C3AED); // Bright Electric Violet
  static const Color primaryPurpleLight = Color(0xFF8B5CF6); // Soft Purple
  static const Color primaryPurpleDark = Color(0xFF5B21B6); // Deep Royal Violet
  static const Color purpleSurface = Color(0xFFF5F3FF); // Very Light Purple Tint
  static const Color purpleGlow = Color(0x337C3AED); // Glow Shadow
  static const Color darkSidebar = Color(0xFF1E1B4B); // Midnight Purple/Blue

  // Radiant Sun Yellow (Kuning Matahari) Palette
  static const Color sunYellow = Color(0xFFFBBF24); // Warm Sun Yellow
  static const Color sunYellowDark = Color(0xFFD97706); // Amber Gold
  static const Color sunYellowLight = Color(0xFFFEF3C7); // Soft Golden Cream
  static const Color yellowGlow = Color(0x40FBBF24); // Sun Glow
  static const Color sunGold = Color(0xFFF59E0B); // Vibrant Golden Amber

  // Neutrals & Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Clean Canvas Slate 50
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color cardShadow = Color(0x0C000000);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981); // Emerald Green
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color danger = Color(0xFFEF4444); // Rose Red
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6); // Sky Blue
  static const Color infoLight = Color(0xFFDBEAFE);

  // Gradient Presets
  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF5B21B6), Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldBadgeGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFFCD34D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
