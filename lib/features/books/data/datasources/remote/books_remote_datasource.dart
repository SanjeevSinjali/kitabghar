import 'dart:io';
import 'package:kitabghar/core/api/api_client.dart';
import 'package:kitabghar/core/api/api_endpoints.dart';
import 'package:kitabghar/features/books/data/datasources/books_datasource.dart';
import 'package:kitabghar/features/books/data/models/books_hive_model.dart';

class BooksRemoteDataSource implements IBooksDataSource {
  final ApiClient _apiClient;

  BooksRemoteDataSource({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<BooksHiveModel>> getAllBooks() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.books);
      final List data = response['data'];
      return data.map((e) => BooksHiveModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<BooksHiveModel> createBook(
    BooksHiveModel book, {
    File? image,
    required String token,
  }) async {
    try {
      final response = await _apiClient.postMultipart(
        ApiEndpoints.books,
        fields: book.toFields(),
        file: image,
        fileField: 'coverImage',
        token: token,
      );
      return BooksHiveModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> deleteBook(String id, {required String token}) async {
    try {
      await _apiClient.post(
        '${ApiEndpoints.books}/$id',
        token: token,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}