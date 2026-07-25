import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';

abstract class IPurchaseRepository {
  Future<Either<Failure, List<PurchaseEntity>>> getPurchases({
    required String token,
  });

  /// Buys a book. The backend enforces this atomically — if another buyer
  /// already bought it (or the seller marked it sold), or if you try to
  /// buy your own listing, this returns a Failure with an explanatory
  /// message instead of succeeding.
  Future<Either<Failure, PurchaseEntity>> buyBook({
    required String token,
    required PurchaseEntity item,
  });
}