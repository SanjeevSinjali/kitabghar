import 'dart:io';
import 'package:kitabghar/features/books/data/datasources/books_datasource.dart';
import 'package:kitabghar/features/books/data/models/books_hive_model.dart';

/// Simple in-memory cache used as an offline fallback for the admin
/// catalog (getAllBooks) only — "my books" always goes straight to the
/// server since it's small and account-specific.
class BooksLocalDataSource implements IBooksDataSource {
  final List<BooksHiveModel> _cachedBooks = [];

  @override
  Future<List<BooksHiveModel>> getAllBooks({
    String? token,
    String? category,
  }) async {
    return _cachedBooks;
  }

  @override
  Future<List<BooksHiveModel>> getMyBooks({required String token}) async {
    return [];
  }

  @override
  Future<BooksHiveModel> createBook(
    BooksHiveModel book, {
    File? image,
    required String token,
  }) async {
    _cachedBooks.add(book);
    return book;
  }

  @override
  Future<bool> deleteBook(String id, {required String token}) async {
    _cachedBooks.removeWhere((b) => b.id == id);
    return true;
  }

  void cacheBooks(List<BooksHiveModel> books) {
    _cachedBooks
      ..clear()
      ..addAll(books);
  }
}