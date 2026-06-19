import 'package:kitabghar/features/books/domain/entities/books_entities.dart';

class BooksState {
  final bool isLoading;
  final String? error;
  final List<BooksEntity> books;
  final bool isSuccess;

  const BooksState({
    this.isLoading = false,
    this.error,
    this.books = const [],
    this.isSuccess = false,
  });

  BooksState copyWith({
    bool? isLoading,
    String? error,
    List<BooksEntity>? books,
    bool? isSuccess,
  }) {
    return BooksState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      books: books ?? this.books,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}