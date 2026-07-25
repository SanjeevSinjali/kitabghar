import 'package:flutter/material.dart';
import 'package:kitabghar/app/theme/app_colors.dart';

/// Builds the app's light and dark [ThemeData].
///
/// Wire both into [MaterialApp] (theme / darkTheme) and control which
/// one is active with `themeMode`, driven by `themeModeProvider`.
class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Montserrat';

  static ThemeData get light => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        card: AppColors.lightCard,
        divider: AppColors.lightDivider,
        textPrimary: AppColors.lightTextPrimary,
        textSecondary: AppColors.lightTextSecondary,
        primary: AppColors.primary,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        card: AppColors.darkCard,
        divider: AppColors.darkDivider,
        textPrimary: AppColors.darkTextPrimary,
        textSecondary: AppColors.darkTextSecondary,
        primary: AppColors.primaryDark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color card,
    required Color divider,
    required Color textPrimary,
    required Color textSecondary,
    required Color primary,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: primary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      dividerColor: divider,
      cardColor: card,
      splashFactory: InkRipple.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),

      textTheme: TextTheme(
        bodyLarge: TextStyle(color: textPrimary, fontFamily: fontFamily),
        bodyMedium: TextStyle(color: textPrimary, fontFamily: fontFamily),
        bodySmall: TextStyle(color: textSecondary, fontFamily: fontFamily),
        titleLarge: TextStyle(
            color: textPrimary,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700),
        titleMedium: TextStyle(
            color: textPrimary,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600),
        titleSmall: TextStyle(
            color: textSecondary,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600),
      ),

      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      listTileTheme: ListTileThemeData(
        iconColor: textPrimary,
        textColor: textPrimary,
      ),

      dividerTheme: DividerThemeData(
        color: divider,
        thickness: 0.5,
        space: 1,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : (isDark ? Colors.grey.shade400 : Colors.grey.shade100),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary.withValues(alpha: 0.5)
              : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        hintStyle: TextStyle(color: textSecondary, fontFamily: fontFamily),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      iconTheme: IconThemeData(color: textPrimary),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
      ),
    );
  }
}