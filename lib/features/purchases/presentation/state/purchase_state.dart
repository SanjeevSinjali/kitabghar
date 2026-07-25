import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';

class PurchaseState {
  final bool isLoading;
  final String? error;
  final List<PurchaseEntity> purchases;

  const PurchaseState({
    this.isLoading = false,
    this.error,
    this.purchases = const [],
  });

  PurchaseState copyWith({
    bool? isLoading,
    String? error,
    List<PurchaseEntity>? purchases,
  }) {
    return PurchaseState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      purchases: purchases ?? this.purchases,
    );
  }

  bool hasBought(String bookId) => purchases.any((p) => p.bookId == bookId);
}