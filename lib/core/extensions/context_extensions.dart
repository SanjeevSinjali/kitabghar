import 'package:flutter/material.dart';

/// Small convenience helpers so pages don't have to type
/// `Theme.of(context).colorScheme...` everywhere.
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colors => Theme.of(this).colorScheme;
  TextTheme get textStyles => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Background used for cards / settings groups / list tiles.
  Color get cardColor => Theme.of(this).cardColor;

  /// Primary page background.
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  Color get textPrimary => colors.onSurface;
  Color get textSecondary =>
      isDarkMode ? const Color(0xB3FFFFFF) : const Color(0x8A000000);
  Color get textTertiary =>
      isDarkMode ? const Color(0x80FFFFFF) : const Color(0x61000000);
}