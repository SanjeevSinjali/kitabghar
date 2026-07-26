import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/presentation/view_model/books_view_model.dart';

import '../../../../mocks/mocks.mocks.dart';

void main() {
  late MockGetAllBooksUseCase mockGetAllBooksUseCase;
  late MockGetMyBooksUseCase mockGetMyBooksUseCase;
  late MockCreateBooksUseCase mockCreateBooksUseCase;
  late MockUpdateBookUseCase mockUpdateBookUseCase;
  late MockDeleteBooksUseCase mockDeleteBooksUseCase;
  late BooksNotifier notifier;

  const tToken = 'test-token';

  final tBooks = <BooksEntity>[
    const BooksEntity(
      id: '1',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      price: '500',
      description: 'A handbook of agile software craftsmanship',
      category: 'Other',
      condition: 'Good',
    ),
    const BooksEntity(
      id: '2',
      title: 'Atomic Habits',
      author: 'James Clear',
      price: '350',
      description: 'An easy and proven way to build good habits',
      category: 'Self-Help',
      condition: 'Like New',
    ),
  ];

  setUp(() {
    mockGetAllBooksUseCase = MockGetAllBooksUseCase();
    mockGetMyBooksUseCase = MockGetMyBooksUseCase();
    mockCreateBooksUseCase = MockCreateBooksUseCase();
    mockUpdateBookUseCase = MockUpdateBookUseCase();
    mockDeleteBooksUseCase = MockDeleteBooksUseCase();
    notifier = BooksNotifier(
      getAllBooksUseCase: mockGetAllBooksUseCase,
      getMyBooksUseCase: mockGetMyBooksUseCase,
      createBooksUseCase: mockCreateBooksUseCase,
      updateBookUseCase: mockUpdateBookUseCase,
      deleteBooksUseCase: mockDeleteBooksUseCase,
    );
  });

  test('getAllBooks() should populate the state with the fetched books',
      () async {
    when(mockGetAllBooksUseCase.call(any))
        .thenAnswer((_) async => Right(tBooks));

    await notifier.getAllBooks(token: tToken);

    expect(notifier.state.isLoading, false);
    expect(notifier.state.error, null);
    expect(notifier.state.books.length, 2);
    expect(notifier.state.books.first.title, 'Clean Code');
  });

  test('deleteBook() should remove the deleted book from the state',
      () async {
    when(mockGetAllBooksUseCase.call(any))
        .thenAnswer((_) async => Right(tBooks));
    await notifier.getAllBooks(token: tToken);

    when(mockDeleteBooksUseCase.call(any))
        .thenAnswer((_) async => const Right(true));

    await notifier.deleteBook(id: '1', token: tToken);

    expect(notifier.state.isLoading, false);
    expect(notifier.state.error, null);
    expect(notifier.state.books.length, 1);
    expect(notifier.state.books.any((b) => b.id == '1'), false);
  });
}