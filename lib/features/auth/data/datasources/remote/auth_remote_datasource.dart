import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/features/auth/data/datasources/auth_datasource.dart';
import 'package:kitabghar/features/auth/data/models/auth_hive_model.dart';

class AuthRemoteDataSource implements IAuthDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<bool> register(AuthHiveModel user) async {
    try {
      await _apiClient.post(
        ApiEndpoints.register,
        body: {
          'name': user.name,
          'email': user.email,
          'password': user.password,
          'phoneNumber': user.phoneNumber,
        },
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthHiveModel> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      return AuthHiveModel(
        name: response['data']['name'],
        email: response['data']['email'],
        password: password,
        phoneNumber: response['data']['phoneNumber'] ?? '',
        token: response['token'],
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> logout(String email) async {
    return true;
  }
}