import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';

/// Estimates ambient brightness using the camera, since iOS deliberately
/// does not expose a real ambient light sensor to third-party apps (only
/// Apple's own system apps get that access). This is the same technique
/// real light-meter apps use on iOS: sample the average luminance (Y
/// plane) of live camera frames as a proxy for how bright the room is.
///
/// Frames are throttled (processed roughly once per second) rather than
/// analyzing every single frame, to keep this affordable on battery/CPU.
///
/// - Dark   (avg luminance < 40)     → dims screen to ~30%, signals "dark"
/// - Medium (40-180)                 → sets screen to ~60%
/// - Bright (> 180)                  → sets screen to ~90%, signals "bright"
///
/// Hysteresis (different up/down trigger points) prevents flickering
/// when the reading hovers near a boundary.
class LightSensorService {
  CameraController? _controller;
  final _brightnessLevelController = StreamController<BrightnessLevel>.broadcast();

  DateTime _lastSampleTime = DateTime.fromMillisecondsSinceEpoch(0);
  static const _sampleInterval = Duration(milliseconds: 800);

  int _lastLuminance = -1;
  BrightnessLevel _currentLevel = BrightnessLevel.medium;
  bool _isActive = false;

  Stream<BrightnessLevel> get brightnessLevelStream =>
      _brightnessLevelController.stream;

  BrightnessLevel get currentLevel => _currentLevel;
  int get lastLuminance => _lastLuminance;
  bool get isActive => _isActive;

  Future<void> start() async {
    if (_isActive) return;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('No cameras available for light sensing.');
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        camera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _controller!.initialize();
      _isActive = true;

      await _controller!.startImageStream(_onFrame);
    } catch (e) {
      debugPrint('Light sensor (camera) not available: $e');
      _isActive = false;
      _controller = null;
    }
  }

  void _onFrame(CameraImage image) {
    final now = DateTime.now();
    if (now.difference(_lastSampleTime) < _sampleInterval) return;
    _lastSampleTime = now;

    try {
      // For YUV420, planes[0] is the Y (luminance) plane — its average
      // byte value (0-255) is a solid proxy for how bright the scene is.
      final yPlane = image.planes[0].bytes;
      int sum = 0;
      // Sampling every 10th byte is plenty accurate for this purpose and
      // much cheaper than averaging every single pixel.
      const step = 10;
      int count = 0;
      for (int i = 0; i < yPlane.length; i += step) {
        sum += yPlane[i];
        count++;
      }
      final avgLuminance = count > 0 ? (sum / count).round() : 0;
      _lastLuminance = avgLuminance;
      _processLuminance(avgLuminance);
    } catch (e) {
      debugPrint('Error processing camera frame for light sensing: $e');
    }
  }

  Future<void> stop() async {
    try {
      if (_controller != null && _controller!.value.isStreamingImages) {
        await _controller!.stopImageStream();
      }
      await _controller?.dispose();
    } catch (e) {
      debugPrint('Error stopping light sensor camera: $e');
    }
    _controller = null;
    _isActive = false;
    await _resetBrightness();
  }

  void _processLuminance(int avgLuminance) {
    BrightnessLevel newLevel;

    // Hysteresis: different thresholds going up vs. down to prevent
    // rapid toggling when the reading hovers near a boundary.
    switch (_currentLevel) {
      case BrightnessLevel.dark:
        if (avgLuminance > 55) {
          newLevel =
              avgLuminance > 195 ? BrightnessLevel.bright : BrightnessLevel.medium;
        } else {
          newLevel = BrightnessLevel.dark;
        }
        break;
      case BrightnessLevel.medium:
        if (avgLuminance < 25) {
          newLevel = BrightnessLevel.dark;
        } else if (avgLuminance > 195) {
          newLevel = BrightnessLevel.bright;
        } else {
          newLevel = BrightnessLevel.medium;
        }
        break;
      case BrightnessLevel.bright:
        if (avgLuminance < 165) {
          newLevel =
              avgLuminance < 25 ? BrightnessLevel.dark : BrightnessLevel.medium;
        } else {
          newLevel = BrightnessLevel.bright;
        }
        break;
    }

    if (newLevel != _currentLevel) {
      _currentLevel = newLevel;
      _brightnessLevelController.add(newLevel);
      _adjustScreenBrightness(newLevel);
    }
  }

  Future<void> _adjustScreenBrightness(BrightnessLevel level) async {
    try {
      switch (level) {
        case BrightnessLevel.dark:
          await ScreenBrightness().setScreenBrightness(0.3);
          break;
        case BrightnessLevel.medium:
          await ScreenBrightness().setScreenBrightness(0.6);
          break;
        case BrightnessLevel.bright:
          await ScreenBrightness().setScreenBrightness(0.9);
          break;
      }
    } catch (e) {
      debugPrint('Could not adjust screen brightness: $e');
    }
  }

  Future<void> _resetBrightness() async {
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (e) {
      debugPrint('Could not reset screen brightness: $e');
    }
  }

  void dispose() {
    stop();
    _brightnessLevelController.close();
  }
}

enum BrightnessLevel { dark, medium, bright }