import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';

abstract class IBooksRepository {
  /// Browse the admin catalog (kitabghar_backend's /featured endpoint only
  /// ever returns books with source: "admin" — regular users' own listings
  /// are intentionally excluded here, matching the web app's behavior).
  Future<Either<Failure, List<BooksEntity>>> getAllBooks({
    required String token,
    String? category,
  });

  /// The current user's own listings, regardless of source.
  Future<Either<Failure, List<BooksEntity>>> getMyBooks({
    required String token,
  });

  Future<Either<Failure, BooksEntity>> createBook(
    BooksEntity book, {
    File? image,
    required String token,
  });

  /// Updates an existing listing. Only non-null fields are sent, so you
  /// can update just one field (e.g. just the price) without resending
  /// everything.
  Future<Either<Failure, BooksEntity>> updateBook({
    required String id,
    required String token,
    String? title,
    String? author,
    String? price,
    String? description,
    String? category,
    String? condition,
    File? image,
  });

  Future<Either<Failure, bool>> deleteBook(
    String id, {
    required String token,
  });
}