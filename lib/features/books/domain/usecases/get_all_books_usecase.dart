import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';

class GetAllBooksParams {
  final String token;
  final String? category;

  const GetAllBooksParams({required this.token, this.category});
}

/// Fetches the admin-curated catalog (kitabghar_backend's "featured" books —
/// source: "admin" only). This powers the Explore page's general browsing.
class GetAllBooksUseCase {
  final IBooksRepository _repository;

  GetAllBooksUseCase({required IBooksRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<BooksEntity>>> call(GetAllBooksParams params) {
    return _repository.getAllBooks(
      token: params.token,
      category: params.category,
    );
  }
}