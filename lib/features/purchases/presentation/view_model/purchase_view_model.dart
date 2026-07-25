import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/purchases/data/datasources/purchase_remote_datasource.dart';
import 'package:kitabghar/features/purchases/data/repositories/purchase_repository_impl.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/usecases/buy_book_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/get_purchases_usecase.dart';
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

final purchaseViewModelProvider =
    StateNotifierProvider<PurchaseNotifier, PurchaseState>((ref) {
  return PurchaseNotifier(
    getPurchasesUseCase: ref.read(getPurchasesUseCaseProvider),
    buyBookUseCase: ref.read(buyBookUseCaseProvider),
  );
});

// ── Notifier ──────────────────────────────────────────────────

class PurchaseNotifier extends StateNotifier<PurchaseState> {
  final GetPurchasesUseCase _getPurchasesUseCase;
  final BuyBookUseCase _buyBookUseCase;

  PurchaseNotifier({
    required GetPurchasesUseCase getPurchasesUseCase,
    required BuyBookUseCase buyBookUseCase,
  })  : _getPurchasesUseCase = getPurchasesUseCase,
        _buyBookUseCase = buyBookUseCase,
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

  /// Returns null on success, or an error message on failure — e.g. the
  /// book was already sold, or you tried to buy your own listing.
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
}