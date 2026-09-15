import 'package:flutter/material.dart';

/// Grevia Brand Colors and Design System Tokens
class AppColors {
  AppColors._();

  // Primary Palette
  static const Color primaryGreen = Color(0xFF18A957);
  static const Color darkGreen = Color(0xFF0F7C43);
  static const Color lightGreen = Color(0xFFEAF8F0);

  // Light Theme Surfaces & Backgrounds
  static const Color lightBackground = Color(0xFFF7F9F8);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color lightCardSurface = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE5EBE7);

  // Dark Theme Surfaces & Backgrounds
  static const Color darkBackground = Color(0xFF111614);
  static const Color darkSurface = Color(0xFF18201D);
  static const Color darkSecondarySurface = Color(0xFF202A26);
  static const Color darkDivider = Color(0xFF28342F);

  // Typography - Light Theme
  static const Color textLightPrimary = Color(0xFF17201C);
  static const Color textLightSecondary = Color(0xFF6D7872);

  // Typography - Dark Theme
  static const Color textDarkPrimary = Color(0xFFF4F7F5);
  static const Color textDarkSecondary = Color(0xFFAAB4AE);

  // Status & Utility Colors
  static const Color onlineGreen = Color(0xFF18A957);
  static const Color offlineGrey = Color(0xFF9EA8A3);
  static const Color errorRed = Color(0xFFE53935);
  static const Color warningOrange = Color(0xFFFFA000);
  static const Color infoBlue = Color(0xFF1E88E5);

  // Chat Bubble Tints (No Gradients)
  static const Color sentBubbleLight = Color(0xFFD8F3E5);
  static const Color receivedBubbleLight = Color(0xFFFFFFFF);
  static const Color sentBubbleDark = Color(0xFF164731);
  static const Color receivedBubbleDark = Color(0xFF1E2824);

  // Accent Tints
  static const Color badgeRed = Color(0xFFEE4036);
  static const Color iconMuted = Color(0xFF8B9891);
}
