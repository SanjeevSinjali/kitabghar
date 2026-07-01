import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';

import '../../../../mocks/mocks.mocks.dart';

void main() {
  late MockGetAllBooksUseCase mockGetAllBooksUseCase;
  late MockCreateBooksUseCase mockCreateBooksUseCase;
  late MockDeleteBooksUseCase mockDeleteBooksUseCase;
  late BooksNotifier notifier;

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
      title: 'Atomic Habits',
      author: 'James Clear',
      price: '350',
      description: 'An easy and proven way to build good habits',
      category: 'Self-help',
    ),
  ];

  setUp(() {
    mockGetAllBooksUseCase = MockGetAllBooksUseCase();
    mockCreateBooksUseCase = MockCreateBooksUseCase();
    mockDeleteBooksUseCase = MockDeleteBooksUseCase();
    notifier = BooksNotifier(
      getAllBooksUseCase: mockGetAllBooksUseCase,
      createBooksUseCase: mockCreateBooksUseCase,
      deleteBooksUseCase: mockDeleteBooksUseCase,
    );
  });

  test('getAllBooks() should populate the state with the fetched books',
      () async {
    when(mockGetAllBooksUseCase.call()).thenAnswer((_) async => Right(tBooks));

    await notifier.getAllBooks();

    expect(notifier.state.isLoading, false);
    expect(notifier.state.error, null);
    expect(notifier.state.books.length, 2);
    expect(notifier.state.books.first.title, 'Clean Code');
  });

  test('deleteBook() should remove the deleted book from the state',
      () async {
    when(mockGetAllBooksUseCase.call()).thenAnswer((_) async => Right(tBooks));
    await notifier.getAllBooks();

    when(mockDeleteBooksUseCase.call(any))
        .thenAnswer((_) async => const Right(true));

    await notifier.deleteBook(id: '1', token: 'tok');

    expect(notifier.state.isLoading, false);
    expect(notifier.state.error, null);
    expect(notifier.state.books.length, 1);
    expect(notifier.state.books.any((b) => b.id == '1'), false);
  });
}