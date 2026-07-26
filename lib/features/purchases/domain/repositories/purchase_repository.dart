import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/purchases/domain/entities/khalti_session.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';

abstract class IPurchaseRepository {
  Future<Either<Failure, List<PurchaseEntity>>> getPurchases({
    required String token,
  });

  /// Buys a book directly (no payment gateway) — kept for completeness,
  /// though the app now always goes through Khalti.
  Future<Either<Failure, PurchaseEntity>> buyBook({
    required String token,
    required PurchaseEntity item,
  });

  /// Starts a Khalti payment session for a book. Returns the pidx +
  /// payment_url to open in a checkout WebView.
  Future<Either<Failure, KhaltiSession>> initiateKhaltiPayment({
    required String token,
    required PurchaseEntity item,
  });

  /// Verifies a completed Khalti payment server-side and, only if truly
  /// completed, creates the purchase.
  Future<Either<Failure, PurchaseEntity>> verifyKhaltiPayment({
    required String token,
    required String pidx,
    required PurchaseEntity item,
  });
}