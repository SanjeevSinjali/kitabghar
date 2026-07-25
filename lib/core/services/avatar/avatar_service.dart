import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Saves each user's profile photo to a permanent file on disk, named
/// after their email, so it survives logout/login and app restarts —
/// unlike the temp path image_picker originally gives you.
class AvatarService {
  Future<Directory> _avatarsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/avatars');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileNameFor(String email) {
    final safe = email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    return '$safe.jpg';
  }

  /// Returns the saved avatar file for this user, or null if they
  /// haven't uploaded one yet.
  Future<File?> getAvatar(String email) async {
    final dir = await _avatarsDir();
    final file = File('${dir.path}/${_fileNameFor(email)}');
    return await file.exists() ? file : null;
  }

  /// Copies [source] (the freshly-picked image) into permanent storage
  /// for this user, overwriting any previous avatar.
  Future<File> saveAvatar(String email, File source) async {
    final dir = await _avatarsDir();
    final dest = File('${dir.path}/${_fileNameFor(email)}');
    return source.copy(dest.path);
  }

  Future<void> deleteAvatar(String email) async {
    final dir = await _avatarsDir();
    final file = File('${dir.path}/${_fileNameFor(email)}');
    if (await file.exists()) {
      await file.delete();
    }
  }
}