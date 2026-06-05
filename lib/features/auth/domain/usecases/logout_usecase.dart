import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/core/usecases/app_usecase.dart';
import 'package:kitabghar/features/auth/domain/repositories/auth_reposity.dart';

class LogoutUseCase implements UseCase<Either<Failure, bool>, String> {
  final IAuthRepository _repository;

  LogoutUseCase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(String email) =>
      _repository.logout(email);
}