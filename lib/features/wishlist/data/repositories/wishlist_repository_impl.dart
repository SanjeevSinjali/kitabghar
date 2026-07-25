import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:kitabghar/features/wishlist/data/models/wishlist_model.dart';
import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:kitabghar/features/wishlist/domain/repositories/wishlist_repository.dart';

class WishlistRepositoryImpl implements IWishlistRepository {
  final WishlistRemoteDataSource _remoteDataSource;

  WishlistRepositoryImpl({required WishlistRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, List<WishlistEntity>>> getWishlist({
    required String token,
  }) async {
    try {
      final items = await _remoteDataSource.getWishlist(token: token);
      return Right(items.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> toggleWishlist({
    required String token,
    required WishlistEntity item,
  }) async {
    try {
      final wishlisted = await _remoteDataSource.toggle(
        token: token,
        item: WishlistModel.fromEntity(item),
      );
      return Right(wishlisted);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> removeFromWishlist({
    required String token,
    required String bookId,
  }) async {
    try {
      final result =
          await _remoteDataSource.remove(token: token, bookId: bookId);
      return Right(result);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}