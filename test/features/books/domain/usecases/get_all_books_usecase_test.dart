import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/usecases/get_all_books_usecase.dart';

import '../../../../mocks/mocks.mocks.dart';

void main() {
  late MockIBooksRepository mockRepository;
  late GetAllBooksUseCase useCase;

  final tBooks = <BooksEntity>[
    const BooksEntity(
      id: '1',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      price: '500',
      description: 'A handbook of agile software craftsmanship',
      category: 'Programming',
    ),
    const BooksEntity(
      id: '2',
      title: 'The Pragmatic Programmer',
      author: 'Andrew Hunt',
      price: '450',
      description: 'From journeyman to master',
      category: 'Programming',
    ),
  ];

  setUp(() {
    mockRepository = MockIBooksRepository();
    useCase = GetAllBooksUseCase(repository: mockRepository);
  });

  test('should return a list of books when the repository call succeeds',
      () async {
    when(mockRepository.getAllBooks())
        .thenAnswer((_) async => Right(tBooks));

    final result = await useCase();

    result.fold(
      (failure) => fail('Expected Right, got Left($failure)'),
      (books) {
        expect(books.length, 2);
        expect(books.first.title, 'Clean Code');
      },
    );
    verify(mockRepository.getAllBooks()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return a Failure when the repository call fails', () async {
    const tFailure = ApiFailure(message: 'Unable to fetch books');
    when(mockRepository.getAllBooks())
        .thenAnswer((_) async => const Left(tFailure));

    final result = await useCase();

    result.fold(
      (failure) => expect(failure.message, tFailure.message),
      (books) => fail('Expected Left, got Right($books)'),
    );
    verify(mockRepository.getAllBooks()).called(1);
  });
}