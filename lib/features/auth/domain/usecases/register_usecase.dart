import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/core/usecases/app_usecase.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/repositories/auth_reposity.dart';

class RegisterUseCase implements UseCase<Either<Failure, bool>, AuthEntity> {
  final IAuthRepository _repository;

  RegisterUseCase({required IAuthRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, bool>> call(AuthEntity params) =>
      _repository.register(params);
}