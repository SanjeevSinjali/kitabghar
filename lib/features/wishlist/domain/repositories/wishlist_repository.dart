import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';

abstract class IWishlistRepository {
  Future<Either<Failure, List<WishlistEntity>>> getWishlist({
    required String token,
  });

  /// Toggles the given book on/off the user's wishlist.
  /// Returns Right(true) if it was just added, Right(false) if just removed.
  /// The backend enforces a hard limit of 5 items — trying to add a 6th
  /// returns a Failure with a message describing the limit.
  Future<Either<Failure, bool>> toggleWishlist({
    required String token,
    required WishlistEntity item,
  });

  Future<Either<Failure, bool>> removeFromWishlist({
    required String token,
    required String bookId,
  });
}