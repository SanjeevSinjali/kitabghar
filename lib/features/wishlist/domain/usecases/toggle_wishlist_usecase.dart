import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:kitabghar/features/wishlist/domain/repositories/wishlist_repository.dart';

class ToggleWishlistParams {
  final String token;
  final WishlistEntity item;

  const ToggleWishlistParams({required this.token, required this.item});
}

class ToggleWishlistUseCase {
  final IWishlistRepository _repository;

  ToggleWishlistUseCase({required IWishlistRepository repository})
      : _repository = repository;

  Future<Either<Failure, bool>> call(ToggleWishlistParams params) {
    return _repository.toggleWishlist(token: params.token, item: params.item);
  }
}