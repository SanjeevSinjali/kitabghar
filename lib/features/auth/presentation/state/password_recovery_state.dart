class PasswordRecoveryState {
  final bool isLoading;
  final String? error;
  final bool codeSent;
  final bool resetSuccess;

  const PasswordRecoveryState({
    this.isLoading = false,
    this.error,
    this.codeSent = false,
    this.resetSuccess = false,
  });

  PasswordRecoveryState copyWith({
    bool? isLoading,
    String? error,
    bool? codeSent,
    bool? resetSuccess,
  }) {
    return PasswordRecoveryState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      codeSent: codeSent ?? this.codeSent,
      resetSuccess: resetSuccess ?? this.resetSuccess,
    );
  }
}