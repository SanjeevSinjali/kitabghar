import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/profile/domian/repositories/profile_repository.dart';

class ConfirmPasswordChangeParams {
  final String token;
  final String code;
  final String newPassword;

  const ConfirmPasswordChangeParams({
    required this.token,
    required this.code,
    required this.newPassword,
  });
}

class ConfirmPasswordChangeUseCase {
  final IProfileRepository _repository;

  ConfirmPasswordChangeUseCase({required IProfileRepository repository})
      : _repository = repository;

  Future<Either<Failure, String>> call(ConfirmPasswordChangeParams params) {
    return _repository.confirmPasswordChange(
      token: params.token,
      code: params.code,
      newPassword: params.newPassword,
    );
  }
}