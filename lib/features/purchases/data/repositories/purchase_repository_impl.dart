import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/purchases/data/datasources/purchase_remote_datasource.dart';
import 'package:kitabghar/features/purchases/data/models/purchase_model.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/repositories/purchase_repository.dart';

class PurchaseRepositoryImpl implements IPurchaseRepository {
  final PurchaseRemoteDataSource _remoteDataSource;

  PurchaseRepositoryImpl({required PurchaseRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<PurchaseEntity>>> getPurchases({
    required String token,
  }) async {
    try {
      final purchases = await _remoteDataSource.getPurchases(token: token);
      return Right(purchases.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, PurchaseEntity>> buyBook({
    required String token,
    required PurchaseEntity item,
  }) async {
    try {
      final purchase = await _remoteDataSource.buyBook(
        token: token,
        item: PurchaseModel.fromEntity(item),
      );
      return Right(purchase.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}