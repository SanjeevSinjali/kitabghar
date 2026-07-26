import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/profile/domian/entities/profile_entity.dart';
import 'package:kitabghar/features/profile/domian/repositories/profile_repository.dart';

class UpdateProfileParams {
  final String token;
  final String? name;
  final String? email;
  final File? avatar;

  const UpdateProfileParams({
    required this.token,
    this.name,
    this.email,
    this.avatar,
  });
}

class UpdateProfileUseCase {
  final IProfileRepository _repository;

  UpdateProfileUseCase({required IProfileRepository repository})
      : _repository = repository;

  Future<Either<Failure, ProfileEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      token: params.token,
      name: params.name,
      email: params.email,
      avatar: params.avatar,
    );
  }
}