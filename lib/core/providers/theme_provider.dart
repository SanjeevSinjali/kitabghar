import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/services/theme/theme_service.dart';

final themeServiceProvider = Provider<ThemeService>((ref) {
  throw UnimplementedError(
    'themeServiceProvider must be overridden in main.dart after ThemeService().init()',
  );
});

/// Global source of truth for whether the app is in dark mode.
///
/// Read it with `ref.watch(themeModeProvider)` in [MaterialApp] to control
/// `themeMode`, and toggle it anywhere (e.g. the profile page switch) with
/// `ref.read(themeModeProvider.notifier).toggle()`.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(ref.read(themeServiceProvider)),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final ThemeService _themeService;

  ThemeModeNotifier(this._themeService) : super(_initialMode(_themeService));

  static ThemeMode _initialMode(ThemeService service) {
    final saved = service.getIsDarkMode();
    if (saved == null) return ThemeMode.system;
    return saved ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDarkMode => state == ThemeMode.dark;

  Future<void> toggle() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newMode;
    await _themeService.setIsDarkMode(newMode == ThemeMode.dark);
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await _themeService.setIsDarkMode(isDarkMode);
  }
}