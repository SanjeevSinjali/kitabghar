import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/auth/domain/entities/auth_entity.dart';
import 'package:kitabghar/features/auth/presentation/state/auth_state.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/widgets/book_card.dart';
import 'package:kitabghar/features/wishlist/domain/usecases/toggle_wishlist_usecase.dart';
import 'package:kitabghar/features/wishlist/presentation/state/wishlist_state.dart';
import 'package:kitabghar/features/wishlist/presentation/view_model/wishlist_view_model.dart';

import '../mocktail_mocks.dart';

class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier(AuthState initial)
      : super(
          registerUseCase: MockRegisterUseCase(),
          loginUseCase: MockLoginUseCase(),
          logoutUseCase: MockLogoutUseCase(),
          apiClient: ApiClient(),
          onUserAuthenticated: (_) async {},
          onUserLoggedOut: () {},
        ) {
    state = initial;
  }
}

void main() {
  late MockGetWishlistUseCase mockGetWishlistUseCase;
  late MockToggleWishlistUseCase mockToggleWishlistUseCase;
  late MockRemoveWishlistUseCase mockRemoveWishlistUseCase;

  const loggedInState = AuthState(
    isSuccess: true,
    user: AuthEntity(
      id: 'user-1',
      name: 'Test User',
      email: 'test@example.com',
      password: '',
      token: 'sample-token',
    ),
  );

  setUpAll(() {
    registerAllFallbackValues();
    registerFallbackValue(tWishlistEntity);
    registerFallbackValue(
        ToggleWishlistParams(token: '', item: tWishlistEntity));
  });

  setUp(() {
    mockGetWishlistUseCase = MockGetWishlistUseCase();
    mockToggleWishlistUseCase = MockToggleWishlistUseCase();
    mockRemoveWishlistUseCase = MockRemoveWishlistUseCase();
  });

  Widget buildTestable({
    BooksEntity book = tBooksEntity,
    AuthState authState = loggedInState,
    WishlistState wishlistState = const WishlistState(),
    VoidCallback? onTap,
  }) {
    return ProviderScope(
      overrides: [
        authViewModelProvider
            .overrideWith((ref) => _FakeAuthNotifier(authState)),
        wishlistViewModelProvider.overrideWith((ref) {
          final notifier = WishlistNotifier(
            getWishlistUseCase: mockGetWishlistUseCase,
            toggleWishlistUseCase: mockToggleWishlistUseCase,
            removeWishlistUseCase: mockRemoveWishlistUseCase,
          );
          return notifier;
        }),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: BookCard(book: book, onTap: onTap ?? () {}),
          ),
        ),
      ),
    );
  }

  group('BookCard widget tests', () {
    testWidgets('renders the book title, author and price', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Clean Code'), findsOneWidget);
      expect(find.text('Robert C. Martin'), findsOneWidget);
      expect(find.text('Rs. 450'), findsOneWidget);
    });

    testWidgets('renders the category badge', (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Technology'), findsOneWidget);
    });

    testWidgets('renders the condition badge when the book is not sold',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Sold'), findsNothing);
    });

    testWidgets('renders a "Sold" badge instead of the condition when sold',
        (tester) async {
      const soldBook = BooksEntity(
        id: 'book-2',
        title: 'Sold Book',
        author: 'Author X',
        price: '300',
        description: 'desc',
        category: 'Fiction',
        status: 'Sold',
      );

      await tester.pumpWidget(buildTestable(book: soldBook));

      expect(find.text('Sold'), findsOneWidget);
    });

    testWidgets('hides the wishlist heart icon once the book is sold',
        (tester) async {
      const soldBook = BooksEntity(
        id: 'book-2',
        title: 'Sold Book',
        author: 'Author X',
        price: '300',
        description: 'desc',
        category: 'Fiction',
        status: 'Sold',
      );

      await tester.pumpWidget(buildTestable(book: soldBook));

      expect(find.byIcon(Icons.favorite_border_rounded), findsNothing);
      expect(find.byIcon(Icons.favorite_rounded), findsNothing);
    });

    testWidgets('shows an outlined heart when the book is not wishlisted',
        (tester) async {
      await tester.pumpWidget(buildTestable());

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });

    testWidgets('shows a filled heart after successfully toggling the wishlist on',
        (tester) async {
      when(() => mockToggleWishlistUseCase.call(any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });

    testWidgets('calls onTap when the card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTestable(onTap: () => tapped = true));

      await tester.tap(find.byType(BookCard));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('calls ToggleWishlistUseCase when the heart icon is tapped',
        (tester) async {
      when(() => mockToggleWishlistUseCase.call(any()))
          .thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pump();

      verify(() => mockToggleWishlistUseCase.call(any())).called(1);
    });

    testWidgets('shows a "wishlist is full" dialog when the limit is reached',
        (tester) async {
      when(() => mockToggleWishlistUseCase.call(any())).thenAnswer(
          (_) async => const Left(
              ApiFailure(message: 'Wishlist limit of 5 reached')));

      await tester.pumpWidget(buildTestable());

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Your wishlist is full'), findsOneWidget);
    });

    testWidgets('does nothing when tapping the heart while logged out',
        (tester) async {
      await tester.pumpWidget(
          buildTestable(authState: const AuthState(), onTap: () {}));

      await tester.tap(find.byIcon(Icons.favorite_border_rounded));
      await tester.pump();

      verifyNever(() => mockToggleWishlistUseCase.call(any()));
    });

    testWidgets('truncates a very long title to a single line',
        (tester) async {
      const longTitleBook = BooksEntity(
        id: 'book-3',
        title:
            'An Extremely Long Book Title That Should Definitely Be Truncated',
        author: 'Author Y',
        price: '199',
        description: 'desc',
        category: 'Fiction',
      );

      await tester.pumpWidget(buildTestable(book: longTitleBook));

      final titleWidget = tester.widget<Text>(find.text(longTitleBook.title));
      expect(titleWidget.maxLines, 1);
      expect(titleWidget.overflow, TextOverflow.ellipsis);
    });
  });
}
