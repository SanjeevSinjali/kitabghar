import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/data/datasources/local/books_local_datasource.dart';
import 'package:kitabghar/features/books/data/datasources/remote/books_remote_datasource.dart';
import 'package:kitabghar/features/books/data/repositories/books_repository.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/usecases/create_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/delete_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/get_all_books_usecase.dart';
import 'package:kitabghar/features/books/presentation/state/books_state.dart';

// ── Providers ─────────────────────────────────────────────────

final booksRemoteDataSourceProvider = Provider<BooksRemoteDataSource>((ref) {
  return BooksRemoteDataSource(apiClient: ref.read(apiClientProvider));
});

final booksLocalDataSourceProvider = Provider<BooksLocalDataSource>((ref) {
  return BooksLocalDataSource();
});

final booksRepositoryProvider = Provider<BooksRepositoryImpl>((ref) {
  return BooksRepositoryImpl(
    remoteDataSource: ref.read(booksRemoteDataSourceProvider),
    localDataSource: ref.read(booksLocalDataSourceProvider),
  );
});

final getAllBooksUseCaseProvider = Provider<GetAllBooksUseCase>((ref) {
  return GetAllBooksUseCase(repository: ref.read(booksRepositoryProvider));
});

final createBooksUseCaseProvider = Provider<CreateBooksUseCase>((ref) {
  return CreateBooksUseCase(repository: ref.read(booksRepositoryProvider));
});

final deleteBooksUseCaseProvider = Provider<DeleteBooksUseCase>((ref) {
  return DeleteBooksUseCase(repository: ref.read(booksRepositoryProvider));
});

final booksViewModelProvider =
    StateNotifierProvider<BooksNotifier, BooksState>((ref) {
  return BooksNotifier(
    getAllBooksUseCase: ref.read(getAllBooksUseCaseProvider),
    createBooksUseCase: ref.read(createBooksUseCaseProvider),
    deleteBooksUseCase: ref.read(deleteBooksUseCaseProvider),
  );
});

// ── Notifier ──────────────────────────────────────────────────

class BooksNotifier extends StateNotifier<BooksState> {
  final GetAllBooksUseCase _getAllBooksUseCase;
  final CreateBooksUseCase _createBooksUseCase;
  final DeleteBooksUseCase _deleteBooksUseCase;

  BooksNotifier({
    required GetAllBooksUseCase getAllBooksUseCase,
    required CreateBooksUseCase createBooksUseCase,
    required DeleteBooksUseCase deleteBooksUseCase,
  })  : _getAllBooksUseCase = getAllBooksUseCase,
        _createBooksUseCase = createBooksUseCase,
        _deleteBooksUseCase = deleteBooksUseCase,
        super(const BooksState());

  Future<void> getAllBooks() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getAllBooksUseCase();
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (books) =>
          state = state.copyWith(isLoading: false, books: books),
    );
  }

  Future<void> createBook({
    required String title,
    required String author,
    required String price,
    required String description,
    required String category,
    required String token,
    File? image,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);
    final result = await _createBooksUseCase(
      CreateBooksParams(
        book: BooksEntity(
          title: title,
          author: author,
          price: price,
          description: description,
          category: category,
        ),
        image: image,
        token: token,
      ),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (book) => state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        books: [...state.books, book],
      ),
    );
  }

  Future<void> deleteBook({
    required String id,
    required String token,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _deleteBooksUseCase(
      DeleteBooksParams(id: id, token: token),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => state = state.copyWith(
        isLoading: false,
        books: state.books.where((b) => b.id != id).toList(),
      ),
    );
  }

  void resetState() => state = const BooksState();
}