import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:kitabghar/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:kitabghar/features/profile/domian/usecases/confirm_password_change_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/get_profile_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/request_password_change_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/update_profile_usecase.dart';
import 'package:kitabghar/features/profile/presentation/state/profile_state.dart';

// ── Providers ─────────────────────────────────────────────────

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

final profileRepositoryProvider = Provider<ProfileRepositoryImpl>((ref) {
  return ProfileRepositoryImpl(
    remoteDataSource: ref.read(profileRemoteDataSourceProvider),
  );
});

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(repository: ref.read(profileRepositoryProvider));
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(repository: ref.read(profileRepositoryProvider));
});

final requestPasswordChangeUseCaseProvider =
    Provider<RequestPasswordChangeUseCase>((ref) {
  return RequestPasswordChangeUseCase(
      repository: ref.read(profileRepositoryProvider));
});

final confirmPasswordChangeUseCaseProvider =
    Provider<ConfirmPasswordChangeUseCase>((ref) {
  return ConfirmPasswordChangeUseCase(
      repository: ref.read(profileRepositoryProvider));
});

final profileViewModelProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(
    getProfileUseCase: ref.read(getProfileUseCaseProvider),
    updateProfileUseCase: ref.read(updateProfileUseCaseProvider),
    requestPasswordChangeUseCase: ref.read(requestPasswordChangeUseCaseProvider),
    confirmPasswordChangeUseCase: ref.read(confirmPasswordChangeUseCaseProvider),
  );
});

// ── Notifier ──────────────────────────────────────────────────

class ProfileNotifier extends StateNotifier<ProfileState> {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final RequestPasswordChangeUseCase _requestPasswordChangeUseCase;
  final ConfirmPasswordChangeUseCase _confirmPasswordChangeUseCase;

  ProfileNotifier({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required RequestPasswordChangeUseCase requestPasswordChangeUseCase,
    required ConfirmPasswordChangeUseCase confirmPasswordChangeUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _requestPasswordChangeUseCase = requestPasswordChangeUseCase,
        _confirmPasswordChangeUseCase = confirmPasswordChangeUseCase,
        super(const ProfileState());

  Future<void> getProfile({required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getProfileUseCase(token);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (profile) => state = state.copyWith(isLoading: false, profile: profile),
    );
  }

  /// Returns null on success, or an error message on failure.
  Future<String?> updateProfile({
    required String token,
    String? name,
    String? email,
    File? avatar,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _updateProfileUseCase(
      UpdateProfileParams(token: token, name: name, email: email, avatar: avatar),
    );

    String? errorMessage;
    result.fold(
      (failure) {
        errorMessage = failure.message;
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (profile) {
        state = state.copyWith(isLoading: false, profile: profile);
      },
    );
    return errorMessage;
  }

  /// Step 1 of password change. Returns null on success (code sent), or
  /// an error message.
  Future<String?> requestPasswordChange({
    required String token,
    required String currentPassword,
  }) async {
    state = state.copyWith(isChangingPassword: true, passwordChangeError: null);
    final result = await _requestPasswordChangeUseCase(
      RequestPasswordChangeParams(token: token, currentPassword: currentPassword),
    );

    String? errorMessage;
    result.fold(
      (failure) {
        errorMessage = failure.message;
        state = state.copyWith(
          isChangingPassword: false,
          passwordChangeError: failure.message,
        );
      },
      (_) {
        state = state.copyWith(isChangingPassword: false, codeSent: true);
      },
    );
    return errorMessage;
  }

  /// Step 2 of password change. Returns null on success, or an error message.
  Future<String?> confirmPasswordChange({
    required String token,
    required String code,
    required String newPassword,
  }) async {
    state = state.copyWith(isChangingPassword: true, passwordChangeError: null);
    final result = await _confirmPasswordChangeUseCase(
      ConfirmPasswordChangeParams(token: token, code: code, newPassword: newPassword),
    );

    String? errorMessage;
    result.fold(
      (failure) {
        errorMessage = failure.message;
        state = state.copyWith(
          isChangingPassword: false,
          passwordChangeError: failure.message,
        );
      },
      (_) {
        state = state.copyWith(
          isChangingPassword: false,
          passwordChangeSuccess: true,
        );
      },
    );
    return errorMessage;
  }

  void resetPasswordChangeFlow() {
    state = state.copyWith(
      codeSent: false,
      passwordChangeSuccess: false,
      passwordChangeError: null,
    );
  }
}