import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/profile/domian/entities/profile_entity.dart';
import 'package:kitabghar/features/profile/domian/repositories/profile_repository.dart';

class GetProfileUseCase {
  final IProfileRepository _repository;

  GetProfileUseCase({required IProfileRepository repository})
      : _repository = repository;

  Future<Either<Failure, ProfileEntity>> call(String token) {
    return _repository.getProfile(token: token);
  }
}