import 'package:kitabghar/core/services/hive/hive_service.dart';
import 'package:kitabghar/features/auth/data/datasources/auth_datasource.dart';
import 'package:kitabghar/features/auth/data/models/auth_hive_model.dart';

class AuthLocalDataSource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDataSource({required HiveService hiveService})
      : _hiveService = hiveService;

  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      // save or update — don't throw if already exists
      await _hiveService.registerUser(user);
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    final user = _hiveService.getUser(email);
    if (user == null) throw Exception('User not found');
    if (user.password != password) throw Exception('Incorrect password');
    return user;
  }

  @override
  Future<bool> logout(String email) async => true;
}