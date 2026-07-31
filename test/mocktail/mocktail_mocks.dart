// Shared mocktail mocks + fallback value registration used by every
// unit test and widget test in this suite. Using mocktail (instead of
// mockito) means we never need to run build_runner / generate .mocks.dart
// files — these mocks work directly against the abstract repository
// interfaces and concrete use case classes.
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';

import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/domain/repositories/auth_reposity.dart';
import 'package:kitabghar/features/auth/domain/usecases/login_usercase.dart';
import 'package:kitabghar/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kitabghar/features/auth/domain/usecases/register_usecase.dart';

import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';
import 'package:kitabghar/features/books/domain/usecases/create_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/delete_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/get_all_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/get_my_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/update_books_usecase.dart';

import 'package:kitabghar/features/wishlist/domain/entities/wishlist_entity.dart';
import 'package:kitabghar/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/get_wishlist_usecase.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/remove_wishlist_usecase.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/toggle_wishlist_usecase.dart';

import 'package:kitabghar/features/purchases/domain/entities/khalti_session.dart';
import 'package:kitabghar/features/purchases/domain/entities/purchase_entity.dart';
import 'package:kitabghar/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:kitabghar/features/purchases/domain/usecases/buy_book_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/get_purchases_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/initiate_khalti_payment_usecase.dart';
import 'package:kitabghar/features/purchases/domain/usecases/verify_khalti_payment_usecase.dart';

import 'package:kitabghar/features/profile/domian/entities/profile_entity.dart';
import 'package:kitabghar/features/profile/domian/repositories/profile_repository.dart';
import 'package:kitabghar/features/profile/domian/usecases/confirm_password_change_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/get_profile_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/request_password_change_usecase.dart';
import 'package:kitabghar/features/profile/domian/usecases/update_profile_usecase.dart';

import 'package:mocktail/mocktail.dart';

// ── Repository mocks ────────────────────────────────────────────
class MockAuthRepository extends Mock implements IAuthRepository {}

class MockBooksRepository extends Mock implements IBooksRepository {}

class MockWishlistRepository extends Mock implements IWishlistRepository {}

class MockPurchaseRepository extends Mock implements IPurchaseRepository {}

class MockProfileRepository extends Mock implements IProfileRepository {}

// ── Use case mocks (used directly by widget tests, which override the
// Riverpod providers that expose these use cases) ──────────────────
class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockGetAllBooksUseCase extends Mock implements GetAllBooksUseCase {}

class MockGetMyBooksUseCase extends Mock implements GetMyBooksUseCase {}

class MockCreateBooksUseCase extends Mock implements CreateBooksUseCase {}

class MockUpdateBookUseCase extends Mock implements UpdateBookUseCase {}

class MockDeleteBooksUseCase extends Mock implements DeleteBooksUseCase {}

class MockGetWishlistUseCase extends Mock implements GetWishlistUseCase {}

class MockToggleWishlistUseCase extends Mock implements ToggleWishlistUseCase {}

class MockRemoveWishlistUseCase extends Mock implements RemoveWishlistUseCase {}

class MockBuyBookUseCase extends Mock implements BuyBookUseCase {}

class MockGetPurchasesUseCase extends Mock implements GetPurchasesUseCase {}

class MockInitiateKhaltiPaymentUseCase extends Mock
    implements InitiateKhaltiPaymentUseCase {}

class MockVerifyKhaltiPaymentUseCase extends Mock
    implements VerifyKhaltiPaymentUseCase {}

class MockGetProfileUseCase extends Mock implements GetProfileUseCase {}

class MockUpdateProfileUseCase extends Mock implements UpdateProfileUseCase {}

class MockRequestPasswordChangeUseCase extends Mock
    implements RequestPasswordChangeUseCase {}

class MockConfirmPasswordChangeUseCase extends Mock
    implements ConfirmPasswordChangeUseCase {}

// ── Fixtures ─────────────────────────────────────────────────────
const tAuthEntity = AuthEntity(
  id: 'user-1',
  name: 'Test User',
  email: 'test@example.com',
  password: 'password123',
  role: 'user',
  token: 'sample-token',
);

const tBooksEntity = BooksEntity(
  id: 'book-1',
  title: 'Clean Code',
  author: 'Robert C. Martin',
  price: '450',
  description: 'A handbook of agile software craftsmanship.',
  category: 'Technology',
  condition: 'Good',
  image: 'clean_code.png',
  sellerId: 'user-1',
  sellerName: 'Test User',
);

const tWishlistEntity = WishlistEntity(
  id: 'wish-1',
  bookId: 'book-1',
  title: 'Clean Code',
  author: 'Robert C. Martin',
  price: '450',
  image: 'clean_code.png',
  condition: 'Good',
);

const tPurchaseEntity = PurchaseEntity(
  id: 'purchase-1',
  bookId: 'book-1',
  title: 'Clean Code',
  author: 'Robert C. Martin',
  price: '450',
  image: 'clean_code.png',
  condition: 'Good',
);

const tKhaltiSession = KhaltiSession(
  pidx: 'pidx-123',
  paymentUrl: 'https://khalti.com/pay/pidx-123',
);

const tProfileEntity = ProfileEntity(
  id: 'user-1',
  name: 'Test User',
  email: 'test@example.com',
  avatar: 'avatar.png',
  role: 'user',
);

const tApiFailure = ApiFailure(message: 'Something went wrong');
const tLocalFailure = LocalFailure('Local storage error');

/// Registers fallback values for every custom param/return type used
/// with mocktail's `any()` matcher across the whole suite. Call this
/// once in a `setUpAll` before any test that uses `any()` with these
/// types runs.
void registerAllFallbackValues() {
  registerFallbackValue(tAuthEntity);
  registerFallbackValue(tBooksEntity);
  registerFallbackValue(tWishlistEntity);
  registerFallbackValue(tPurchaseEntity);
  registerFallbackValue(LoginParams(email: '', password: ''));
  registerFallbackValue(_FakeFile());
  registerFallbackValue(const Left<Failure, bool>(tLocalFailure));
}

class _FakeFile extends Fake implements File {}
