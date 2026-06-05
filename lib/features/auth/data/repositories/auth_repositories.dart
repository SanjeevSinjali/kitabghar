import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:kitabghar/features/auth/data/models/auth_hive_model.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/repositories/auth_reposity.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthLocalDataSource _dataSource;

  AuthRepositoryImpl({required AuthLocalDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Either<Failure, bool>> register(AuthEntity entity) async {
    try {
      final result = await _dataSource.register(AuthHiveModel.fromEntity(entity));
      return Right(result);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> login(String email, String password) async {
    try {
      final model = await _dataSource.login(email, password);
      return Right(model.toEntity());
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout(String email) async {
    try {
      final result = await _dataSource.logout(email);
      return Right(result);
    } catch (e) {
      return Left(LocalFailure(e.toString()));
    }
  }
}