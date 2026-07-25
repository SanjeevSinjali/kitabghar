import 'package:flutter/material.dart';

/// Central color palette for Kitabghar.
///
/// Every screen should read colors from `Theme.of(context)` (via
/// [AppTheme.light] / [AppTheme.dark]) rather than hardcoding
/// `Colors.white` / `Colors.black` — that's what makes dark mode
/// actually apply everywhere instead of just on one page.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF6C4EF2);
  static const Color primaryDark = Color(0xFF8B75FF);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightDivider = Color(0xFFEEEEEE);

  // Light theme text
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0x8A000000); // black54
  static const Color lightTextTertiary = Color(0x61000000); // black38

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF232323);
  static const Color darkDivider = Color(0xFF2E2E2E);

  // Dark theme text
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xB3FFFFFF); // white70
  static const Color darkTextTertiary = Color(0x80FFFFFF); // white50

  // Status
  static const Color error = Color(0xFFE24C4C);
  static const Color success = Color(0xFF2ECC71);
}