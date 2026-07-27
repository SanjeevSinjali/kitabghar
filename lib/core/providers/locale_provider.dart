import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/localization/app_strings.dart';
import 'package:kitabghar/core/services/locale/locale_service.dart';

final localeServiceProvider = Provider<LocaleService>((ref) {
  throw UnimplementedError(
    'localeServiceProvider must be overridden in main.dart after LocaleService().init()',
  );
});

/// Global source of truth for the app's current language. Any widget that
/// wants to show translated text must `ref.watch(localeProvider)` in its
/// build method so it rebuilds when the language changes.
final localeProvider = StateNotifierProvider<LocaleNotifier, AppLocale>(
  (ref) => LocaleNotifier(ref.read(localeServiceProvider)),
);

class LocaleNotifier extends StateNotifier<AppLocale> {
  final LocaleService _service;

  LocaleNotifier(this._service) : super(_initial(_service));

  static AppLocale _initial(LocaleService service) {
    final code = service.getLocaleCode();
    return code == 'ne' ? AppLocale.ne : AppLocale.en;
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    await _service.setLocaleCode(locale == AppLocale.ne ? 'ne' : 'en');
  }
}