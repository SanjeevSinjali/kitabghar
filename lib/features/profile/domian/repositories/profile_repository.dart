import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/profile/domian/entities/profile_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile({required String token});

  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String token,
    String? name,
    String? email,
    File? avatar,
  });

  Future<Either<Failure, String>> requestPasswordChange({
    required String token,
    required String currentPassword,
  });

  Future<Either<Failure, String>> confirmPasswordChange({
    required String token,
    required String code,
    required String newPassword,
  });
}