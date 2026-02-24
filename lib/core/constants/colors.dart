import 'package:flutter/material.dart';

/// RE:VIBE Design System Colors
class AppColors {
  AppColors._();

  // Primary (Brand / Action)
  static const Color primary = Color(0xFF4F46E5);       // Indigo 600
  static const Color primaryHover = Color(0xFF4338CA);   // Indigo 700
  static const Color primaryLight = Color(0xFFEEF2FF);   // Indigo 50
  static const Color primaryText = Color(0xFF4338CA);    // Indigo 700
  static const Color violet = Color(0xFF7C3AED);         // Violet 600

  // Semantic (Status)
  static const Color success = Color(0xFF10B981);        // Emerald 500
  static const Color warning = Color(0xFFF59E0B);        // Amber 500
  static const Color error = Color(0xFFF43F5E);          // Rose 500
  static const Color premium = Color(0xFF9333EA);        // Purple 600

  // Neutral (Text / Background)
  static const Color textTitle = Color(0xFF262626);      // ink
  static const Color textBody = Color(0xFF555555);       // sec
  static const Color textCaption = Color(0xFF8E8E8E);    // ter
  static const Color mute = Color(0xFFC7C7CC);           // mute
  static const Color background = Color(0xFFFAFAFA);     // bg
  static const Color cardBackground = Color(0xFFFFFFFF); // White
  static const Color divider = Color(0xFFEFEFEF);        // line
  static const Color lineDark = Color(0xFFDBDBDB);       // lineDark

  // Chip
  static const Color chipActive = primary;
  static const Color chipInactive = Color(0xFFF5F5F5);   // Neutral 100
  static const Color chipInactiveText = Color(0xFF555555);

  // Tag
  static const Color tagBackground = Color(0xFFECFDF5);  // Emerald 50
  static const Color tagText = Color(0xFF047857);         // Emerald 700

  // Card variants
  static const Color resultCardBorder = Color(0xFFC7D2FE);  // Indigo 200
  static const Color resultCardBackground = Color(0xFFEEF2FF); // Indigo 50
  static const Color gapCardBorder = Color(0xFFFECDD3);      // Rose 200
  static const Color gapCardBackground = Color(0xFFFFF1F2);  // Rose 50

  // Offline banner
  static const Color offlineBanner = Color(0xFFF59E0B);  // Amber 500
}
