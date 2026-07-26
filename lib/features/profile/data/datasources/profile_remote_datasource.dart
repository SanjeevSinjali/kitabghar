import 'dart:io';
import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/features/profile/data/models/profile_model.dart';

class ProfileRemoteDataSource {
  final ApiClient _apiClient;

  ProfileRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  Future<ProfileModel> getProfile({required String token}) async {
    final response = await _apiClient.get(ApiEndpoints.whoami, token: token);
    return ProfileModel.fromJson(response['data']);
  }

  Future<ProfileModel> updateProfile({
    required String token,
    String? name,
    String? email,
    File? avatar,
  }) async {
    final fields = <String, String>{};
    if (name != null) fields['name'] = name;
    if (email != null) fields['email'] = email;

    final response = await _apiClient.putMultipart(
      ApiEndpoints.updateProfile,
      fields: fields,
      file: avatar,
      fileField: avatar != null ? 'avatar' : null,
      token: token,
    );
    return ProfileModel.fromJson(response['data']);
  }

  Future<String> requestPasswordChange({
    required String token,
    required String currentPassword,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.requestPasswordChange,
      token: token,
      body: {'currentPassword': currentPassword},
    );
    return response['message'] ?? 'Verification code sent';
  }

  Future<String> confirmPasswordChange({
    required String token,
    required String code,
    required String newPassword,
  }) async {
    final response = await _apiClient.patch(
      ApiEndpoints.confirmPasswordChange,
      token: token,
      body: {'code': code, 'newPassword': newPassword},
    );
    return response['message'] ?? 'Password updated successfully';
  }
}