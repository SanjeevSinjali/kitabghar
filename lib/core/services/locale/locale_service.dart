import 'package:hive_flutter/hive_flutter.dart';

/// Persists the user's language choice using the same small Hive box as
/// ThemeService, so it survives app restarts.
class LocaleService {
  static const String _settingsBox = 'settings_box';
  static const String _localeKey = 'app_locale';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_settingsBox)) {
      await Hive.openBox(_settingsBox);
    }
  }

  Box get _box => Hive.box(_settingsBox);

  /// Returns the saved language code ('en' or 'ne'), or null if never set
  /// (defaults to English in that case).
  String? getLocaleCode() => _box.get(_localeKey) as String?;

  Future<void> setLocaleCode(String code) async {
    await _box.put(_localeKey, code);
  }
}