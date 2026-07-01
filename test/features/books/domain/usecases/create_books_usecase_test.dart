import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/usecases/create_books_usecase.dart';

import '../../../../mocks/mocks.mocks.dart';

void main() {
  late MockIBooksRepository mockRepository;
  late CreateBooksUseCase useCase;

  const tBook = BooksEntity(
    title: 'Atomic Habits',
    author: 'James Clear',
    price: '350',
    description: 'An easy and proven way to build good habits',
    category: 'Self-help',
  );
  const tToken = 'auth-token-123';

  setUp(() {
    mockRepository = MockIBooksRepository();
    useCase = CreateBooksUseCase(repository: mockRepository);
  });

  test('should return the created BooksEntity when creation succeeds',
      () async {
    const tCreatedBook = BooksEntity(
      id: '99',
      title: 'Atomic Habits',
      author: 'James Clear',
      price: '350',
      description: 'An easy and proven way to build good habits',
      category: 'Self-help',
    );
    when(mockRepository.createBook(tBook, image: null, token: tToken))
        .thenAnswer((_) async => const Right(tCreatedBook));

    final result = await useCase(
      CreateBooksParams(book: tBook, token: tToken),
    );

    result.fold(
      (failure) => fail('Expected Right, got Left($failure)'),
      (book) {
        expect(book.id, '99');
        expect(book.title, tBook.title);
      },
    );
    verify(mockRepository.createBook(tBook, image: null, token: tToken))
        .called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return a Failure when the token is invalid', () async {
    const tFailure = ApiFailure(message: 'Unauthorized');
    when(mockRepository.createBook(tBook, image: null, token: tToken))
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase(
      CreateBooksParams(book: tBook, token: tToken),
    );

    result.fold(
      (failure) => expect(failure.message, tFailure.message),
      (book) => fail('Expected Left, got Right($book)'),
    );
    verify(mockRepository.createBook(tBook, image: null, token: tToken))
        .called(1);
  });
}