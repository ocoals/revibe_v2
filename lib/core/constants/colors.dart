import 'package:flutter/material.dart';

/// ClosetIQ Design System Colors
/// Based on UI/UX Design Document Section 6.1
class AppColors {
  AppColors._();

  // Primary (Brand / Action)
  static const Color primary = Color(0xFF4F46E5);       // Indigo 600
  static const Color primaryHover = Color(0xFF4338CA);   // Indigo 700
  static const Color primaryLight = Color(0xFFEEF2FF);   // Indigo 50
  static const Color primaryText = Color(0xFF4338CA);    // Indigo 700

  // Semantic (Status)
  static const Color success = Color(0xFF10B981);        // Emerald 500
  static const Color warning = Color(0xFFF59E0B);        // Amber 500
  static const Color error = Color(0xFFF43F5E);          // Rose 500
  static const Color premium = Color(0xFF9333EA);        // Purple 600

  // Neutral (Text / Background)
  static const Color textTitle = Color(0xFF1E293B);      // Slate 800
  static const Color textBody = Color(0xFF475569);       // Slate 600
  static const Color textCaption = Color(0xFF94A3B8);    // Slate 400
  static const Color background = Color(0xFFF8FAFC);     // Slate 50
  static const Color cardBackground = Color(0xFFFFFFFF); // White
  static const Color divider = Color(0xFFE2E8F0);        // Slate 200

  // Chip
  static const Color chipActive = primary;
  static const Color chipInactive = Color(0xFFF1F5F9);   // Slate 100
  static const Color chipInactiveText = Color(0xFF475569);// Slate 600

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
