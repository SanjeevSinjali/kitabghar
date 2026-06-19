import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';

class DeleteBooksParams {
  final String id;
  final String token;

  DeleteBooksParams({required this.id, required this.token});
}

class DeleteBooksUseCase {
  final IBooksRepository _repository;

  DeleteBooksUseCase({required IBooksRepository repository})
      : _repository = repository;

  Future<Either<Failure, bool>> call(DeleteBooksParams params) {
    return _repository.deleteBook(params.id, token: params.token);
  }
}