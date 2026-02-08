import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF90CAF9);
  static const Color primaryDark = Color(0xFF5D99C6);

  // Dark Theme Colors (Internal use for Theme construction)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceLightDark = Color(0xFF2A2A2A);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xB3FFFFFF);
  static const Color textHintDark = Color(0xFF9E9E9E);
  static const Color textDisabledDark = Color(0xFF757575);
  static const Color dividerDark = Color(0xFF424242);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // Light Theme Colors (Internal use for Theme construction)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Colors.white;
  static const Color surfaceLightLight = Color(0xFFEEEEEE);
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textHintLight = Color(0xFF9E9E9E);
  static const Color textDisabledLight = Color(0xFFBDBDBD);
  static const Color dividerLight = Color(0xFFE0E0E0);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);

  // Legacy Constants (Restored for compilation stability)
  static const Color background = backgroundDark;
  static const Color surface = surfaceDark;
  static const Color surfaceLightDefault = surfaceLightDark; // Renamed to avoid conflict
  static const Color surfaceVariant = surfaceVariantDark;
  static const Color textPrimary = textPrimaryDark;
  static const Color textSecondary = textSecondaryDark;
  static const Color textHint = textHintDark;
  static const Color textDisabled = textDisabledDark;
  static const Color divider = dividerDark;

  // Status
  static const Color error = Colors.redAccent;
  static const Color success = Colors.green;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;

  // Misc
  static const Color cardShadow = Colors.black26;
}
