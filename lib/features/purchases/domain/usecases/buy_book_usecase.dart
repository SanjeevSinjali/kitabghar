import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/repositories/purchase_repository.dart';

class BuyBookParams {
  final String token;
  final PurchaseEntity item;

  const BuyBookParams({required this.token, required this.item});
}

class BuyBookUseCase {
  final IPurchaseRepository _repository;

  BuyBookUseCase({required IPurchaseRepository repository})
      : _repository = repository;

  Future<Either<Failure, PurchaseEntity>> call(BuyBookParams params) {
    return _repository.buyBook(token: params.token, item: params.item);
  }
}