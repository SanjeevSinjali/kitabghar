import 'package:kitabghar/features/auth/data/models/auth_hive_model.dart';

abstract class IAuthDataSource {
  Future<bool> register(AuthHiveModel user);
  Future<AuthHiveModel> login(String email, String password);
  Future<bool> logout(String email);
}