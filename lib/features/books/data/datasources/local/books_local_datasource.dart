import 'dart:io';
import 'package:kitabghar/features/books/data/datasources/books_datasource.dart';
import 'package:kitabghar/features/books/data/models/books_hive_model.dart';

class BooksLocalDataSource implements IBooksDataSource {
  final List<BooksHiveModel> _cachedBooks = [];

  @override
  Future<List<BooksHiveModel>> getAllBooks() async {
    return _cachedBooks;
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