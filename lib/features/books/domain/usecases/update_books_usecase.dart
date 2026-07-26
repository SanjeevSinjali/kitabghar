import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';

class UpdateBookParams {
  final String id;
  final String token;
  final String? title;
  final String? author;
  final String? price;
  final String? description;
  final String? category;
  final String? condition;
  final File? image;

  const UpdateBookParams({
    required this.id,
    required this.token,
    this.title,
    this.author,
    this.price,
    this.description,
    this.category,
    this.condition,
    this.image,
  });
}

class UpdateBookUseCase {
  final IBooksRepository _repository;

  UpdateBookUseCase({required IBooksRepository repository})
      : _repository = repository;

  Future<Either<Failure, BooksEntity>> call(UpdateBookParams params) {
    return _repository.updateBook(
      id: params.id,
      token: params.token,
      title: params.title,
      author: params.author,
      price: params.price,
      description: params.description,
      category: params.category,
      condition: params.condition,
      image: params.image,
    );
  }
}