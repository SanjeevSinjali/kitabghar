import 'package:hive_flutter/hive_flutter.dart';

/// Persists the user's dark-mode preference in a small Hive box
/// (separate from the auth box), so the choice survives app restarts.
class ThemeService {
  static const String _settingsBox = 'settings_box';
  static const String _isDarkModeKey = 'is_dark_mode';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_settingsBox)) {
      await Hive.openBox(_settingsBox);
    }
  }

  Box get _box => Hive.box(_settingsBox);

  /// Returns the saved preference, or `null` if the user has never set one
  /// (in which case the app should fall back to the OS/system setting).
  bool? getIsDarkMode() {
    return _box.get(_isDarkModeKey) as bool?;
  }

  Future<void> setIsDarkMode(bool isDarkMode) async {
    await _box.put(_isDarkModeKey, isDarkMode);
  }
}