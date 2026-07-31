import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/usecases/create_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/delete_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/get_all_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/get_my_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/update_books_usecase.dart';

import '../../../../mocktail_mocks.dart';

void main() {
  late MockBooksRepository mockRepository;
  late CreateBooksUseCase createBooksUseCase;
  late DeleteBooksUseCase deleteBooksUseCase;
  late GetAllBooksUseCase getAllBooksUseCase;
  late GetMyBooksUseCase getMyBooksUseCase;
  late UpdateBookUseCase updateBookUseCase;

  const tToken = 'sample-token';

  setUpAll(registerAllFallbackValues);

  setUp(() {
    mockRepository = MockBooksRepository();
    createBooksUseCase = CreateBooksUseCase(repository: mockRepository);
    deleteBooksUseCase = DeleteBooksUseCase(repository: mockRepository);
    getAllBooksUseCase = GetAllBooksUseCase(repository: mockRepository);
    getMyBooksUseCase = GetMyBooksUseCase(repository: mockRepository);
    updateBookUseCase = UpdateBookUseCase(repository: mockRepository);
  });

  group('CreateBooksUseCase', () {
    final params = CreateBooksParams(book: tBooksEntity, token: tToken);

    test('returns Right(BooksEntity) when repository createBook succeeds',
        () async {
      when(() => mockRepository.createBook(any(),
              image: any(named: 'image'), token: any(named: 'token')))
          .thenAnswer((_) async => const Right(tBooksEntity));

      final result = await createBooksUseCase(params);

      expect(result, const Right(tBooksEntity));
    });

    test('returns Left(Failure) when repository createBook fails', () async {
      when(() => mockRepository.createBook(any(),
              image: any(named: 'image'), token: any(named: 'token')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await createBooksUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('forwards the exact book entity and token to the repository',
        () async {
      when(() => mockRepository.createBook(any(),
              image: any(named: 'image'), token: any(named: 'token')))
          .thenAnswer((_) async => const Right(tBooksEntity));

      await createBooksUseCase(params);

      verify(() => mockRepository.createBook(tBooksEntity,
          image: null, token: tToken)).called(1);
    });

    test('works when no image is supplied (null image)', () async {
      when(() => mockRepository.createBook(any(),
              image: any(named: 'image'), token: any(named: 'token')))
          .thenAnswer((_) async => const Right(tBooksEntity));

      final result = await createBooksUseCase(
          CreateBooksParams(book: tBooksEntity, token: tToken));

      expect(result.isRight(), true);
    });
  });

  group('DeleteBooksUseCase', () {
    final params = DeleteBooksParams(id: 'book-1', token: tToken);

    test('returns Right(true) when repository deleteBook succeeds', () async {
      when(() => mockRepository.deleteBook(any(), token: any(named: 'token')))
          .thenAnswer((_) async => const Right(true));

      final result = await deleteBooksUseCase(params);

      expect(result, const Right(true));
    });

    test('returns Left(Failure) when repository deleteBook fails', () async {
      when(() => mockRepository.deleteBook(any(), token: any(named: 'token')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await deleteBooksUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('calls repository.deleteBook with the given id and token', () async {
      when(() => mockRepository.deleteBook(any(), token: any(named: 'token')))
          .thenAnswer((_) async => const Right(true));

      await deleteBooksUseCase(params);

      verify(() => mockRepository.deleteBook('book-1', token: tToken))
          .called(1);
    });

    test('propagates a LocalFailure from the repository unchanged', () async {
      when(() => mockRepository.deleteBook(any(), token: any(named: 'token')))
          .thenAnswer((_) async => const Left(tLocalFailure));

      final result = await deleteBooksUseCase(params);

      expect(result, const Left(tLocalFailure));
    });
  });

  group('GetAllBooksUseCase', () {
    const params = GetAllBooksParams(token: tToken);

    test('returns Right(List<BooksEntity>) on success', () async {
      when(() => mockRepository.getAllBooks(
              token: any(named: 'token'), category: any(named: 'category')))
          .thenAnswer((_) async => const Right([tBooksEntity]));

      final result = await getAllBooksUseCase(params);

      expect(result, const Right([tBooksEntity]));
    });

    test('returns Right(empty list) when there are no books', () async {
      when(() => mockRepository.getAllBooks(
              token: any(named: 'token'), category: any(named: 'category')))
          .thenAnswer((_) async => const Right(<BooksEntity>[]));

      final result = await getAllBooksUseCase(params);

      result.fold((_) => fail('expected Right'), (books) => expect(books, isEmpty));
    });

    test('returns Left(Failure) when the request fails', () async {
      when(() => mockRepository.getAllBooks(
              token: any(named: 'token'), category: any(named: 'category')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await getAllBooksUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('forwards an optional category filter to the repository', () async {
      when(() => mockRepository.getAllBooks(
              token: any(named: 'token'), category: any(named: 'category')))
          .thenAnswer((_) async => const Right([tBooksEntity]));

      await getAllBooksUseCase(
          const GetAllBooksParams(token: tToken, category: 'Technology'));

      verify(() => mockRepository.getAllBooks(
          token: tToken, category: 'Technology')).called(1);
    });
  });

  group('GetMyBooksUseCase', () {
    test('returns Right(List<BooksEntity>) with the seller\'s own listings',
        () async {
      when(() => mockRepository.getMyBooks(token: any(named: 'token')))
          .thenAnswer((_) async => const Right([tBooksEntity]));

      final result = await getMyBooksUseCase(tToken);

      expect(result, const Right([tBooksEntity]));
    });

    test('returns Left(Failure) when fetching own listings fails', () async {
      when(() => mockRepository.getMyBooks(token: any(named: 'token')))
          .thenAnswer((_) async => const Left(tApiFailure));

      final result = await getMyBooksUseCase(tToken);

      expect(result, const Left(tApiFailure));
    });

    test('calls repository.getMyBooks with the exact token', () async {
      when(() => mockRepository.getMyBooks(token: any(named: 'token')))
          .thenAnswer((_) async => const Right([tBooksEntity]));

      await getMyBooksUseCase(tToken);

      verify(() => mockRepository.getMyBooks(token: tToken)).called(1);
    });
  });

  group('UpdateBookUseCase', () {
    const params = UpdateBookParams(id: 'book-1', token: tToken, price: '500');

    test('returns Right(BooksEntity) when the update succeeds', () async {
      when(() => mockRepository.updateBook(
            id: any(named: 'id'),
            token: any(named: 'token'),
            title: any(named: 'title'),
            author: any(named: 'author'),
            price: any(named: 'price'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            condition: any(named: 'condition'),
            image: any(named: 'image'),
          )).thenAnswer((_) async => const Right(tBooksEntity));

      final result = await updateBookUseCase(params);

      expect(result, const Right(tBooksEntity));
    });

    test('returns Left(Failure) when the update fails', () async {
      when(() => mockRepository.updateBook(
            id: any(named: 'id'),
            token: any(named: 'token'),
            title: any(named: 'title'),
            author: any(named: 'author'),
            price: any(named: 'price'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            condition: any(named: 'condition'),
            image: any(named: 'image'),
          )).thenAnswer((_) async => const Left(tApiFailure));

      final result = await updateBookUseCase(params);

      expect(result, const Left(tApiFailure));
    });

    test('only sends the fields that were actually provided (partial update)',
        () async {
      when(() => mockRepository.updateBook(
            id: any(named: 'id'),
            token: any(named: 'token'),
            title: any(named: 'title'),
            author: any(named: 'author'),
            price: any(named: 'price'),
            description: any(named: 'description'),
            category: any(named: 'category'),
            condition: any(named: 'condition'),
            image: any(named: 'image'),
          )).thenAnswer((_) async => const Right(tBooksEntity));

      await updateBookUseCase(params);

      verify(() => mockRepository.updateBook(
            id: 'book-1',
            token: tToken,
            title: null,
            author: null,
            price: '500',
            description: null,
            category: null,
            condition: null,
            image: null,
          )).called(1);
    });
  });
}
