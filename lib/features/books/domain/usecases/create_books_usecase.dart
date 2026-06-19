import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';

class CreateBooksParams {
  final BooksEntity book;
  final File? image;
  final String token;

  CreateBooksParams({
    required this.book,
    this.image,
    required this.token,
  });
}

class CreateBooksUseCase {
  final IBooksRepository _repository;

  CreateBooksUseCase({required IBooksRepository repository})
      : _repository = repository;

  Future<Either<Failure, BooksEntity>> call(CreateBooksParams params) {
    return _repository.createBook(
      params.book,
      image: params.image,
      token: params.token,
    );
  }
}