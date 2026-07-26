import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:kitabghar/features/profile/domian/entities/profile_entity.dart';
import 'package:kitabghar/features/profile/domian/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  ProfileRepositoryImpl({required ProfileRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ProfileEntity>> getProfile({
    required String token,
  }) async {
    try {
      final profile = await _remoteDataSource.getProfile(token: token);
      return Right(profile.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String token,
    String? name,
    String? email,
    File? avatar,
  }) async {
    try {
      final profile = await _remoteDataSource.updateProfile(
        token: token,
        name: name,
        email: email,
        avatar: avatar,
      );
      return Right(profile.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> requestPasswordChange({
    required String token,
    required String currentPassword,
  }) async {
    try {
      final message = await _remoteDataSource.requestPasswordChange(
        token: token,
        currentPassword: currentPassword,
      );
      return Right(message);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> confirmPasswordChange({
    required String token,
    required String code,
    required String newPassword,
  }) async {
    try {
      final message = await _remoteDataSource.confirmPasswordChange(
        token: token,
        code: code,
        newPassword: newPassword,
      );
      return Right(message);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}