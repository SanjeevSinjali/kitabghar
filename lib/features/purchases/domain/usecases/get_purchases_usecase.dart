import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/repositories/purchase_repository.dart';

class GetPurchasesUseCase {
  final IPurchaseRepository _repository;

  GetPurchasesUseCase({required IPurchaseRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<PurchaseEntity>>> call(String token) {
    return _repository.getPurchases(token: token);
  }
}