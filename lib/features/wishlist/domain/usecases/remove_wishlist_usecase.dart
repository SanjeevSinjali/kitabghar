import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/wishlist/domain/repositories/wishlist_repository.dart';

class RemoveWishlistParams {
  final String token;
  final String bookId;

  const RemoveWishlistParams({required this.token, required this.bookId});
}

class RemoveWishlistUseCase {
  final IWishlistRepository _repository;

  RemoveWishlistUseCase({required IWishlistRepository repository})
      : _repository = repository;

  Future<Either<Failure, bool>> call(RemoveWishlistParams params) {
    return _repository.removeFromWishlist(
      token: params.token,
      bookId: params.bookId,
    );
  }
}