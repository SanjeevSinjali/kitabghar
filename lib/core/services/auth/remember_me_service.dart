import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final rememberMeServiceProvider = Provider<RememberMeService>((ref) {
  return RememberMeService();
});

/// Persists login credentials securely — using the iOS Keychain / Android
/// Keystore-backed encrypted storage, never plain SharedPreferences or
/// Hive, since these are real account credentials and deserve to be
/// handled with the same care as a password manager would.
class RememberMeService {
  static const _emailKey = 'remembered_email';
  static const _passwordKey = 'remembered_password';

  final _storage = const FlutterSecureStorage();

  Future<void> save({required String email, required String password}) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  /// Returns the saved credentials, or null if nothing is stored.
  Future<({String email, String password})?> load() async {
    final email = await _storage.read(key: _emailKey);
    final password = await _storage.read(key: _passwordKey);
    if (email == null || password == null) return null;
    return (email: email, password: password);
  }

  Future<void> clear() async {
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _passwordKey);
  }
}