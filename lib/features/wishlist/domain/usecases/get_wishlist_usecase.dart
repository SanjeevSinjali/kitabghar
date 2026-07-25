import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:kitabghar/features/wishlist/domain/repositories/wishlist_repository.dart';

class GetWishlistUseCase {
  final IWishlistRepository _repository;

  GetWishlistUseCase({required IWishlistRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<WishlistEntity>>> call(String token) {
    return _repository.getWishlist(token: token);
  }
}