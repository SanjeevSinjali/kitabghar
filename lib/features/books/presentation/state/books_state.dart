import 'package:kitabghar/features/books/domain/entities/books_entities.dart';

class BooksState {
  final bool isLoading;
  final String? error;
  final List<BooksEntity> books;
  final List<BooksEntity> myBooks;
  final bool isSuccess;

  const BooksState({
    this.isLoading = false,
    this.error,
    this.books = const [],
    this.myBooks = const [],
    this.isSuccess = false,
  });

  BooksState copyWith({
    bool? isLoading,
    String? error,
    List<BooksEntity>? books,
    List<BooksEntity>? myBooks,
    bool? isSuccess,
  }) {
    return BooksState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      books: books ?? this.books,
      myBooks: myBooks ?? this.myBooks,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}