import 'dart:io';
import 'package:kitabghar/features/books/data/models/books_hive_model.dart';

abstract class IBooksDataSource {
  Future<List<BooksHiveModel>> getAllBooks();
  Future<BooksHiveModel> createBook(
    BooksHiveModel book, {
    File? image,
    required String token,
  });
  Future<bool> deleteBook(String id, {required String token});
}