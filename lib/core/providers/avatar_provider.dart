import 'dart:io';
import 'package:flutter/painting.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/services/avatar/avatar_service.dart';

final avatarServiceProvider = Provider<AvatarService>((ref) => AvatarService());

/// Holds the currently logged-in user's avatar file (or null if they
/// haven't set one).
final avatarProvider = StateNotifierProvider<AvatarNotifier, File?>(
  (ref) => AvatarNotifier(ref.read(avatarServiceProvider)),
);

class AvatarNotifier extends StateNotifier<File?> {
  final AvatarService _service;
  String? _currentEmail;

  AvatarNotifier(this._service) : super(null);

  /// Call right after login/registration to load this user's saved photo.
  Future<void> loadForUser(String email) async {
    _currentEmail = email;
    final file = await _service.getAvatar(email);
    if (file != null) {
      // Make sure we're not showing a stale cached bitmap from a
      // previous session at this same file path.
      await FileImage(file).evict();
    }
    state = file;
  }

  /// Call when the user picks a new photo from gallery/camera.
  Future<void> setAvatar(String email, File source) async {
    final saved = await _service.saveAvatar(email, source);

    // IMPORTANT: Flutter's image cache keys FileImage by file path, not
    // by file content. Since the same user always saves to the same
    // path, without this eviction the old (stale) image stays cached
    // and the UI won't visually update even though the file changed.
    await FileImage(saved).evict();

    if (_currentEmail == email) {
      state = saved;
    }
  }

  void clear() {
    _currentEmail = null;
    state = null;
  }
}