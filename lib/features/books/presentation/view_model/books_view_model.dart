import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kitabghar/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:kitabghar/features/books/data/datasources/local/books_local_datasource.dart';
import 'package:kitabghar/features/books/data/datasources/remote/books_remote_datasource.dart';
import 'package:kitabghar/features/books/data/repositories/books_repository_impl.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/usecases/create_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/delete_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/get_all_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/get_my_books_usecase.dart';
import 'package:kitabghar/features/books/domain/usecases/update_books_usecase.dart';
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

final getMyBooksUseCaseProvider = Provider<GetMyBooksUseCase>((ref) {
  return GetMyBooksUseCase(repository: ref.read(booksRepositoryProvider));
});

final createBooksUseCaseProvider = Provider<CreateBooksUseCase>((ref) {
  return CreateBooksUseCase(repository: ref.read(booksRepositoryProvider));
});

final updateBookUseCaseProvider = Provider<UpdateBookUseCase>((ref) {
  return UpdateBookUseCase(repository: ref.read(booksRepositoryProvider));
});

final deleteBooksUseCaseProvider = Provider<DeleteBooksUseCase>((ref) {
  return DeleteBooksUseCase(repository: ref.read(booksRepositoryProvider));
});

final booksViewModelProvider =
    StateNotifierProvider<BooksNotifier, BooksState>((ref) {
  return BooksNotifier(
    getAllBooksUseCase: ref.read(getAllBooksUseCaseProvider),
    getMyBooksUseCase: ref.read(getMyBooksUseCaseProvider),
    createBooksUseCase: ref.read(createBooksUseCaseProvider),
    updateBookUseCase: ref.read(updateBookUseCaseProvider),
    deleteBooksUseCase: ref.read(deleteBooksUseCaseProvider),
  );
});

// ── Notifier ──────────────────────────────────────────────────

class BooksNotifier extends StateNotifier<BooksState> {
  final GetAllBooksUseCase _getAllBooksUseCase;
  final GetMyBooksUseCase _getMyBooksUseCase;
  final CreateBooksUseCase _createBooksUseCase;
  final UpdateBookUseCase _updateBookUseCase;
  final DeleteBooksUseCase _deleteBooksUseCase;

  BooksNotifier({
    required GetAllBooksUseCase getAllBooksUseCase,
    required GetMyBooksUseCase getMyBooksUseCase,
    required CreateBooksUseCase createBooksUseCase,
    required UpdateBookUseCase updateBookUseCase,
    required DeleteBooksUseCase deleteBooksUseCase,
  })  : _getAllBooksUseCase = getAllBooksUseCase,
        _getMyBooksUseCase = getMyBooksUseCase,
        _createBooksUseCase = createBooksUseCase,
        _updateBookUseCase = updateBookUseCase,
        _deleteBooksUseCase = deleteBooksUseCase,
        super(const BooksState());

  /// Loads the admin catalog for Explore (kitabghar_backend only returns
  /// source: "admin" books here — never other users' listings).
  Future<void> getAllBooks({required String token, String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getAllBooksUseCase(
      GetAllBooksParams(token: token, category: category),
    );
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (books) => state = state.copyWith(isLoading: false, books: books),
    );
  }

  /// Loads the current user's own listings — for Profile's "My Listings".
  Future<void> getMyBooks({required String token}) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _getMyBooksUseCase(token);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (books) => state = state.copyWith(isLoading: false, myBooks: books),
    );
  }

  Future<void> createBook({
    required String title,
    required String author,
    required String price,
    required String description,
    required String category,
    required String condition,
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
          condition: condition,
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
        // New listing always belongs to this user, so add it straight to
        // myBooks regardless of whether it also appears in the admin
        // catalog (only true if this account happens to be an admin).
        myBooks: [book, ...state.myBooks],
      ),
    );
  }

  /// Returns null on success (state updated), or an error message.
  Future<String?> updateBook({
    required String id,
    required String token,
    String? title,
    String? author,
    String? price,
    String? description,
    String? category,
    String? condition,
    File? image,
  }) async {
    final result = await _updateBookUseCase(
      UpdateBookParams(
        id: id,
        token: token,
        title: title,
        author: author,
        price: price,
        description: description,
        category: category,
        condition: condition,
        image: image,
      ),
    );

    String? errorMessage;
    result.fold(
      (failure) => errorMessage = failure.message,
      (updated) {
        state = state.copyWith(
          books: state.books.map((b) => b.id == id ? updated : b).toList(),
          myBooks:
              state.myBooks.map((b) => b.id == id ? updated : b).toList(),
        );
      },
    );
    return errorMessage;
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
        // This was missing before — deleting from My Listings wasn't
        // actually removing it from the myBooks list.
        myBooks: state.myBooks.where((b) => b.id != id).toList(),
      ),
    );
  }

  void resetState() => state = const BooksState();
}