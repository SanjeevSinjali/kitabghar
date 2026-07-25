import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';

class WishlistState {
  final bool isLoading;
  final String? error;
  final List<WishlistEntity> items;

  const WishlistState({
    this.isLoading = false,
    this.error,
    this.items = const [],
  });

  WishlistState copyWith({
    bool? isLoading,
    String? error,
    List<WishlistEntity>? items,
  }) {
    return WishlistState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
    );
  }

  bool isWishlisted(String bookId) => items.any((i) => i.bookId == bookId);
}