import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';

abstract class IBooksRepository {
  Future<Either<Failure, List<BooksEntity>>> getAllBooks();
  Future<Either<Failure, BooksEntity>> createBook(
    BooksEntity book, {
    File? image,
    required String token,
  });
  Future<Either<Failure, bool>> deleteBook(
    String id, {
    required String token,
  });
}