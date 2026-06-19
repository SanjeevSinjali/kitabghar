import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:kitabghar/core/error/failures.dart';
import 'package:kitabghar/features/books/data/datasources/local/books_local_datasource.dart';
import 'package:kitabghar/features/books/data/datasources/remote/books_remote_datasource.dart';
import 'package:kitabghar/features/books/data/models/books_hive_model.dart';
import 'package:kitabghar/features/books/domain/entities/books_entities.dart';
import 'package:kitabghar/features/books/domain/repositories/books_repository.dart';

class BooksRepositoryImpl implements IBooksRepository {
  final BooksRemoteDataSource _remoteDataSource;
  final BooksLocalDataSource _localDataSource;

  BooksRepositoryImpl({
    required BooksRemoteDataSource remoteDataSource,
    required BooksLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<BooksEntity>>> getAllBooks() async {
    try {
      final books = await _remoteDataSource.getAllBooks();
      _localDataSource.cacheBooks(books);
      return Right(books.map((b) => b.toEntity()).toList());
    } catch (e) {
      try {
        final cached = await _localDataSource.getAllBooks();
        return Right(cached.map((b) => b.toEntity()).toList());
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, BooksEntity>> createBook(
    BooksEntity book, {
    File? image,
    required String token,
  }) async {
    try {
      final model = BooksHiveModel.fromEntity(book);
      final created = await _remoteDataSource.createBook(
        model,
        image: image,
        token: token,
      );
      return Right(created.toEntity());
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBook(
    String id, {
    required String token,
  }) async {
    try {
      final result =
          await _remoteDataSource.deleteBook(id, token: token);
      return Right(result);
    } catch (e) {
      return Left(ApiFailure(message: e.toString()));
    }
  }
}