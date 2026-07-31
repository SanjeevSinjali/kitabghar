import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/remove_wishlist_usecase.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/toggle_wishlist_usecase.dart';

import '../../../../mocktail_mocks.dart';

void main() {
  late MockWishlistRepository mockRepository;
  late GetWishlistUseCase getWishlistUseCase;
  late RemoveWishlistUseCase removeWishlistUseCase;
  late ToggleWishlistUseCase toggleWishlistUseCase;

  const tToken = 'sample-token';

  setUpAll(() {
    registerAllFallbackValues();
    registerFallbackValue(tWishlistEntity);
  });

  setUp(() {
    mockRepository = MockWishlistRepository();
    getWishlistUseCase = GetWishlistUseCase(repository: mockRepository);
    removeWishlistUseCase = RemoveWishlistUseCase(repository: mockRepository);
    toggleWishlistUseCase = ToggleWishlistUseCase(repository: mockRepository);
  });

  group('GetWishlistUseCase', () {
    test('returns Right(List<WishlistEntity>) on success', () async {
      when(() => mockRepository.getWishlist(token: any(named: 'token')))
          .thenAnswer((_) async => const Right([tWishlistEntity]));

      final result = await getWishlistUseCase(tToken);

      expect(result, const Right([tWishlistEntity]));
    });

    test('returns Right(empty list) when the wishlist is empty', () async {
      when(() => mockRepository.getWishlist(token: any(named: 'token')))
          .thenAnswer((_) async => const Right(<WishlistEntity>[]));

      final result = await getWishlistUseCase(tToken);

      result.fold((_) => fail('expected Right'), (items) => expect(items, isEmpty));
    });

    test('returns Left(Failure) when fetching the wishlist fails', () async {
      when(() => mockRepository.getWishlist(token: any(named: 'token')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await getWishlistUseCase(tToken);

      expect(result, const Left(tApiFailure));
    });

    test('calls repository.getWishlist with the exact token', () async {
      when(() => mockRepository.getWishlist(token: any(named: 'token')))
          .thenAnswer((_) async => const Right([tWishlistEntity]));

      await getWishlistUseCase(tToken);

      verify(() => mockRepository.getWishlist(token: tToken)).called(1);
    });
  });

  group('ToggleWishlistUseCase', () {
    final params = ToggleWishlistParams(token: tToken, item: tWishlistEntity);

    test('returns Right(true) when a book is newly added to the wishlist',
        () async {
      when(() => mockRepository.toggleWishlist(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Right(true));

      final result = await toggleWishlistUseCase(params);

      expect(result, const Right(true));
    });

    test('returns Right(false) when a book is removed from the wishlist',
        () async {
      when(() => mockRepository.toggleWishlist(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Right(false));

      final result = await toggleWishlistUseCase(params);

      expect(result, const Right(false));
    });

    test('returns Left(Failure) when the 5-item wishlist limit is reached',
        () async {
      const limitFailure = ApiFailure(message: 'Wishlist limit of 5 reached');
      when(() => mockRepository.toggleWishlist(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Left(limitFailure));

      final result = await toggleWishlistUseCase(params);

      expect(result, const Left(limitFailure));
    });

    test('forwards the exact token and item to the repository', () async {
      when(() => mockRepository.toggleWishlist(
              token: any(named: 'token'), item: any(named: 'item')))
          .thenAnswer((_) async => const Right(true));

      await toggleWishlistUseCase(params);

      verify(() => mockRepository.toggleWishlist(
          token: tToken, item: tWishlistEntity)).called(1);
    });
  });

  group('RemoveWishlistUseCase', () {
    final params = RemoveWishlistParams(token: tToken, bookId: 'book-1');

    test('returns Right(true) when removal succeeds', () async {
      when(() => mockRepository.removeFromWishlist(
              token: any(named: 'token'), bookId: any(named: 'bookId')))
          .thenAnswer((_) async => const Right(true));

      final result = await removeWishlistUseCase(params);

      expect(result, const Right(true));
    });

    test('returns Left(Failure) when removal fails', () async {
      when(() => mockRepository.removeFromWishlist(
              token: any(named: 'token'), bookId: any(named: 'bookId')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await removeWishlistUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('calls repository.removeFromWishlist with the exact bookId',
        () async {
      when(() => mockRepository.removeFromWishlist(
              token: any(named: 'token'), bookId: any(named: 'bookId')))
          .thenAnswer((_) async => const Right(true));

      await removeWishlistUseCase(params);

      verify(() => mockRepository.removeFromWishlist(
          token: tToken, bookId: 'book-1')).called(1);
    });
  });
}
