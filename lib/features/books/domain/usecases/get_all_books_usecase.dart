import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';

class GetAllBooksUseCase {
  final IBooksRepository _repository;

  GetAllBooksUseCase({required IBooksRepository repository})
      : _repository = repository;

  Future<Either<Failure, List<BooksEntity>>> call() {
    return _repository.getAllBooks();
  }
}