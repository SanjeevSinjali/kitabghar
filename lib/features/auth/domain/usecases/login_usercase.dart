import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/core/usecases/app_usecase.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/repositories/auth_reposity.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<Either<Failure, AuthEntity>, LoginParams> {
  final IAuthRepository _repository;

  LoginUseCase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, AuthEntity>> call(LoginParams params) =>
      _repository.login(params.email, params.password);
}