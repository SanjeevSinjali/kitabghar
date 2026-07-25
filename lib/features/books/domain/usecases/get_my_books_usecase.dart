import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';

/// Fetches the current user's own book listings — powers "My Listings"
/// on the Profile page. Unlike getAllBooks, this includes books regardless
/// of source (admin or user), since it's scoped to the logged-in seller.
class GetMyBooksUseCase {
  final IBooksRepository _repository;

  GetMyBooksUseCase({required IBooksRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<BooksEntity>>> call(String token) {
    return _repository.getMyBooks(token: token);
  }
}