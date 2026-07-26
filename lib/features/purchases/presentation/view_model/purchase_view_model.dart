import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/purchases/data/datasources/purchase_remote_datasource.dart';
import 'package:kitabghar/features/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:kitabghar/features/purchases/domain/entities/khalti_session.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/usecases/buy_book_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/get_purchases_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/initiate_khalti_payment_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/verify_khalti_payment_usecase.dart';
import 'package:kitabghar/features/purchases/presentation/state/purchase_state.dart';

// ── Providers ─────────────────────────────────────────────────

final purchaseRemoteDataSourceProvider = Provider<PurchaseRemoteDataSource>((ref) {
  return PurchaseRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

final purchaseRepositoryProvider = Provider<PurchaseRepositoryImpl>((ref) {
  return PurchaseRepositoryImpl(
    remoteDataSource: ref.read(purchaseRemoteDataSourceProvider),
  );
});

final getPurchasesUseCaseProvider = Provider<GetPurchasesUseCase>((ref) {
  return GetPurchasesUseCase(repository: ref.read(purchaseRepositoryProvider));
});

final buyBookUseCaseProvider = Provider<BuyBookUseCase>((ref) {
  return BuyBookUseCase(repository: ref.read(purchaseRepositoryProvider));
});

final initiateKhaltiPaymentUseCaseProvider = Provider<InitiateKhaltiPaymentUseCase>((ref) {
  return InitiateKhaltiPaymentUseCase(repository: ref.read(purchaseRepositoryProvider));
});

final verifyKhaltiPaymentUseCaseProvider = Provider<VerifyKhaltiPaymentUseCase>((ref) {
  return VerifyKhaltiPaymentUseCase(repository: ref.read(purchaseRepositoryProvider));
});

final purchaseViewModelProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  return PurchaseNotifier(
    getPurchasesUseCase: ref.read(getPurchasesUseCaseProvider),
    buyBookUseCase: ref.read(buyBookUseCaseProvider),
    initiateKhaltiPaymentUseCase: ref.read(initiateKhaltiPaymentUseCaseProvider),
    verifyKhaltiPaymentUseCase: ref.read(verifyKhaltiPaymentUseCaseProvider),
  );
});

// ── Notifier ──────────────────────────────────────────────────

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final GetPurchasesUseCase _getPurchasesUseCase;
  final BuyBookUseCase _buyBookUseCase;
  final InitiateKhaltiPaymentUseCase _initiateKhaltiPaymentUseCase;
  final VerifyKhaltiPaymentUseCase _verifyKhaltiPaymentUseCase;

  PurchaseNotifier({
    required GetPurchasesUseCase getPurchasesUseCase,
    required BuyBookUseCase buyBookUseCase,
    required InitiateKhaltiPaymentUseCase initiateKhaltiPaymentUseCase,
    required VerifyKhaltiPaymentUseCase verifyKhaltiPaymentUseCase,
  })  : _getPurchasesUseCase = getPurchasesUseCase,
        _buyBookUseCase = buyBookUseCase,
        _initiateKhaltiPaymentUseCase = initiateKhaltiPaymentUseCase,
        _verifyKhaltiPaymentUseCase = verifyKhaltiPaymentUseCase,
        super(const PurchaseState());

  Future<void> getPurchases({required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getPurchasesUseCase(token);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (purchases) =>
          state = state.copyWith(isLoading: false, purchases: purchases),
    );
  }

  /// Direct buy, no payment gateway — kept for completeness/testing.
  Future<String?> buyBook({
    required String token,
    required PurchaseEntity item,
  }) async {
    final result =
        await _buyBookUseCase(BuyBookParams(token: token, item: item));

    String? errorMessage;
    result.fold(
      (failure) => errorMessage = failure.message,
      (purchase) {
        state = state.copyWith(purchases: [purchase, ...state.purchases]);
      },
    );
    return errorMessage;
  }

  /// Step 1 of the Khalti flow: ask the backend to start a payment
  /// session. Returns Left(failure) or Right(session) — the caller opens
  /// session.paymentUrl in a checkout WebView next.
  Future<Either<Failure, KhaltiSession>> initiateKhaltiPayment({
    required String token,
    required PurchaseEntity item,
  }) {
    return _initiateKhaltiPaymentUseCase(
      InitiateKhaltiPaymentParams(token: token, item: item),
    );
  }

  /// Step 2 of the Khalti flow: after the WebView reports the user
  /// finished, verify server-side and (if genuinely completed) record
  /// the purchase. Returns null on success, or an error message.
  Future<String?> verifyKhaltiPayment({
    required String token,
    required String pidx,
    required PurchaseEntity item,
  }) async {
    final result = await _verifyKhaltiPaymentUseCase(
      VerifyKhaltiPaymentParams(token: token, pidx: pidx, item: item),
    );

    String? errorMessage;
    result.fold(
      (failure) => errorMessage = failure.message,
      (purchase) {
        state = state.copyWith(purchases: [purchase, ...state.purchases]);
      },
    );
    return errorMessage;
  }
}