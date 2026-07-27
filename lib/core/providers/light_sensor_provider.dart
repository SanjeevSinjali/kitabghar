import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/providers/theme_provider.dart';
import 'package:kitabghar/core/services/sensors/light_sensor_service.dart';

/// Whether the auto-brightness feature is currently enabled.
final autoLightProvider =
    StateNotifierProvider<AutoLightNotifier, bool>((ref) {
  return AutoLightNotifier(ref);
});

class AutoLightNotifier extends StateNotifier<bool> {
  final Ref _ref;
  final LightSensorService _service = LightSensorService();
  StreamSubscription<BrightnessLevel>? _subscription;

  AutoLightNotifier(this._ref) : super(false);

  /// Toggle the auto-brightness/dark-mode feature on or off.
  void toggle() {
    if (state) {
      _stop();
    } else {
      _start();
    }
    state = !state;
  }

  void _start() {
    // Fire-and-forget: start() is async (camera init takes a moment), but
    // the toggle should flip immediately in the UI regardless.
    _service.start();
    _subscription = _service.brightnessLevelStream.listen((level) {
      // Automatically switch dark/light mode based on ambient light.
      final shouldBeDark = level == BrightnessLevel.dark;
      _ref.read(themeModeProvider.notifier).setDarkMode(shouldBeDark);
    });
  }

  void _stop() {
    _subscription?.cancel();
    _subscription = null;
    _service.stop();
  }

  @override
  void dispose() {
    _stop();
    _service.dispose();
    super.dispose();
  }
}