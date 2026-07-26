import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/profile/domian/repositories/profile_repository.dart';

class RequestPasswordChangeParams {
  final String token;
  final String currentPassword;

  const RequestPasswordChangeParams({
    required this.token,
    required this.currentPassword,
  });
}

class RequestPasswordChangeUseCase {
  final IProfileRepository _repository;

  RequestPasswordChangeUseCase({required IProfileRepository repository})
      : _repository = repository;

  Future<Either<Failure, String>> call(RequestPasswordChangeParams params) {
    return _repository.requestPasswordChange(
      token: params.token,
      currentPassword: params.currentPassword,
    );
  }
}