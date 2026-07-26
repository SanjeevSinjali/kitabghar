import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/repositories/purchase_repository.dart';

class VerifyKhaltiPaymentParams {
  final String token;
  final String pidx;
  final PurchaseEntity item;

  const VerifyKhaltiPaymentParams({
    required this.token,
    required this.pidx,
    required this.item,
  });
}

class VerifyKhaltiPaymentUseCase {
  final IPurchaseRepository _repository;

  VerifyKhaltiPaymentUseCase({required IPurchaseRepository repository})
      : _repository = repository;

  Future<Either<Failure, PurchaseEntity>> call(VerifyKhaltiPaymentParams params) {
    return _repository.verifyKhaltiPayment(
      token: params.token,
      pidx: params.pidx,
      item: params.item,
    );
  }
}