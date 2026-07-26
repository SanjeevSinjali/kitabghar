import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/purchases/domain/entities/khalti_session.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/repositories/purchase_repository.dart';

class InitiateKhaltiPaymentParams {
  final String token;
  final PurchaseEntity item;

  const InitiateKhaltiPaymentParams({required this.token, required this.item});
}

class InitiateKhaltiPaymentUseCase {
  final IPurchaseRepository _repository;

  InitiateKhaltiPaymentUseCase({required IPurchaseRepository repository})
      : _repository = repository;

  Future<Either<Failure, KhaltiSession>> call(InitiateKhaltiPaymentParams params) {
    return _repository.initiateKhaltiPayment(token: params.token, item: params.item);
  }
}