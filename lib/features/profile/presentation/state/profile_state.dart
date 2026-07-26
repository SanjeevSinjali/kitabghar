import 'package:kitabghar/features/profile/domian/entities/profile_entity.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final ProfileEntity? profile;

  // Password-change flow state
  final bool isChangingPassword;
  final String? passwordChangeError;
  final bool codeSent;
  final bool passwordChangeSuccess;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.profile,
    this.isChangingPassword = false,
    this.passwordChangeError,
    this.codeSent = false,
    this.passwordChangeSuccess = false,
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    ProfileEntity? profile,
    bool? isChangingPassword,
    String? passwordChangeError,
    bool? codeSent,
    bool? passwordChangeSuccess,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      profile: profile ?? this.profile,
      isChangingPassword: isChangingPassword ?? this.isChangingPassword,
      passwordChangeError: passwordChangeError,
      codeSent: codeSent ?? this.codeSent,
      passwordChangeSuccess: passwordChangeSuccess ?? this.passwordChangeSuccess,
    );
  }
}