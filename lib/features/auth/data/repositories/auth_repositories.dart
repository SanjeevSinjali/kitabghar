import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:kitabghar/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:kitabghar/features/auth/data/models/auth_hive_model.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/repositories/auth_reposity.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthLocalDataSource _localDataSource;
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthLocalDataSource localDataSource,
    required AuthRemoteDataSource remoteDataSource,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      // 1. Register on API first
      await _remoteDataSource.register(AuthHiveModel.fromEntity(entity));
      // 2. Save locally in Hive
      await _localDataSource.register(AuthHiveModel.fromEntity(entity));
      return const Right(true);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(
      String email, String password) async {
    try {
      // 1. Login via API
      final model = await _remoteDataSource.login(email, password);
      // 2. Save user locally in Hive
      await _localDataSource.register(model);
      return Right(model.toEntity());
    } catch (e) {
      // 3. If API fails, try local (offline mode)
      try {
        final localModel = await _localDataSource.login(email, password);
        return Right(localModel.toEntity());
      } catch (_) {
        return Left(LocalFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> logout(String email) async {
    try {
      await _localDataSource.logout(email);
      return const Right(true);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }
}