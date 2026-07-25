import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:kitabghar/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/remove_wishlist_usecase.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/toggle_wishlist_usecase.dart';
import 'package:kitabghar/features/wishlist/presentation/state/wishlist_state.dart';

// ── Providers ─────────────────────────────────────────────────

final wishlistRemoteDataSourceProvider = Provider<WishlistRemoteDataSource>((ref) {
  return WishlistRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

final wishlistRepositoryProvider = Provider<WishlistRepositoryImpl>((ref) {
  return WishlistRepositoryImpl(
    remoteDataSource: ref.read(wishlistRemoteDataSourceProvider),
  );
});

final getWishlistUseCaseProvider = Provider<GetWishlistUseCase>((ref) {
  return GetWishlistUseCase(repository: ref.read(wishlistRepositoryProvider));
});

final toggleWishlistUseCaseProvider = Provider<ToggleWishlistUseCase>((ref) {
  return ToggleWishlistUseCase(repository: ref.read(wishlistRepositoryProvider));
});

final removeWishlistUseCaseProvider = Provider<RemoveWishlistUseCase>((ref) {
  return RemoveWishlistUseCase(repository: ref.read(wishlistRepositoryProvider));
});

final wishlistViewModelProvider =
    StateNotifierProvider<WishlistNotifier, WishlistState>((ref) {
  return WishlistNotifier(
    getWishlistUseCase: ref.read(getWishlistUseCaseProvider),
    toggleWishlistUseCase: ref.read(toggleWishlistUseCaseProvider),
    removeWishlistUseCase: ref.read(removeWishlistUseCaseProvider),
  );
});

// ── Notifier ──────────────────────────────────────────────────

class WishlistNotifier extends StateNotifier<WishlistState> {
  final GetWishlistUseCase _getWishlistUseCase;
  final ToggleWishlistUseCase _toggleWishlistUseCase;
  final RemoveWishlistUseCase _removeWishlistUseCase;

  WishlistNotifier({
    required GetWishlistUseCase getWishlistUseCase,
    required ToggleWishlistUseCase toggleWishlistUseCase,
    required RemoveWishlistUseCase removeWishlistUseCase,
  })  : _getWishlistUseCase = getWishlistUseCase,
        _toggleWishlistUseCase = toggleWishlistUseCase,
        _removeWishlistUseCase = removeWishlistUseCase,
        super(const WishlistState());

  Future<void> getWishlist({required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getWishlistUseCase(token);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (items) => state = state.copyWith(isLoading: false, items: items),
    );
  }

  /// Returns null on success, or an error message on failure — e.g. the
  /// backend's hard 5-item wishlist limit. The caller (UI) should show
  /// this message to the user if non-null.
  Future<String?> toggleWishlist({
    required String token,
    required WishlistEntity item,
  }) async {
    final result = await _toggleWishlistUseCase(
      ToggleWishlistParams(token: token, item: item),
    );

    String? errorMessage;
    result.fold(
      (failure) => errorMessage = failure.message,
      (wishlisted) {
        if (wishlisted) {
          state = state.copyWith(items: [item, ...state.items]);
        } else {
          state = state.copyWith(
            items: state.items.where((i) => i.bookId != item.bookId).toList(),
          );
        }
      },
    );
    return errorMessage;
  }

  Future<void> removeFromWishlist({
    required String token,
    required String bookId,
  }) async {
    final result = await _removeWishlistUseCase(
      RemoveWishlistParams(token: token, bookId: bookId),
    );
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(
        items: state.items.where((i) => i.bookId != bookId).toList(),
      ),
    );
  }
}