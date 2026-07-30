import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/features/auth/presentation/state/password_recovery_state.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';

final passwordRecoveryViewModelProvider =
    StateNotifierProvider<PasswordRecoveryNotifier, PasswordRecoveryState>((ref) {
  return PasswordRecoveryNotifier(apiClient: ref.read(apiClientProvider));
});

/// Handles the logged-OUT "Forgot Password" flow — separate from
/// SecurityPrivacyPage's change-password flow, which requires an existing
/// session. This one only needs the user's email, since they can't prove
/// who they are any other way at this point.
class PasswordRecoveryNotifier extends StateNotifier<PasswordRecoveryState> {
  final ApiClient _apiClient;

  PasswordRecoveryNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const PasswordRecoveryState());

  /// Step 1: request a 6-digit code be emailed to this address.
  /// Returns null on success, or an error message.
  Future<String?> requestCode(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.post(
        ApiEndpoints.forgotPassword,
        body: {'email': email},
      );
      state = state.copyWith(isLoading: false, codeSent: true);
      return null;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: message);
      return message;
    }
  }

  /// Step 2: confirm the code and set a new password.
  /// Returns null on success, or an error message.
  Future<String?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _apiClient.post(
        ApiEndpoints.resetPasswordWithCode,
        body: {'email': email, 'code': code, 'newPassword': newPassword},
      );
      state = state.copyWith(isLoading: false, resetSuccess: true);
      return null;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: message);
      return message;
    }
  }

  void reset() => state = const PasswordRecoveryState();
}