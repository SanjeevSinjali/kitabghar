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
  Future<List<BooksHiveModel>> getAllBooks({
    String? token,
    String? category,
  }) async {
    try {
      // kitabghar_backend's /featured endpoint defaults to only 6 books
      // per page — pass a high limit so we get the whole admin catalog
      // in one call (there's no pagination UI built yet).
      final query = <String, String>{'limit': '100'};
      if (category != null && category != 'All') {
        query['category'] = category;
      }
      final queryString =
          query.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');

      final response = await _apiClient.get(
        '${ApiEndpoints.featuredBooks}?$queryString',
        token: token,
      );
      final List data = response['data'];
      return data.map((e) => BooksHiveModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<BooksHiveModel>> getMyBooks({required String token}) async {
    try {
      final response =
          await _apiClient.get(ApiEndpoints.myBooks, token: token);
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
        fileField: 'image',
        token: token,
      );
      return BooksHiveModel.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<BooksHiveModel> updateBook({
    required String id,
    required String token,
    String? title,
    String? author,
    String? price,
    String? description,
    String? category,
    String? condition,
    File? image,
  }) async {
    try {
      final fields = <String, String>{};
      if (title != null) fields['title'] = title;
      if (author != null) fields['author'] = author;
      if (price != null) fields['price'] = price;
      if (description != null) fields['description'] = description;
      if (category != null) fields['category'] = category;
      if (condition != null) fields['condition'] = condition;

      final response = await _apiClient.putMultipart(
        '${ApiEndpoints.books}/$id',
        fields: fields,
        file: image,
        fileField: image != null ? 'image' : null,
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
      await _apiClient.delete(
        '${ApiEndpoints.books}/$id',
        token: token,
      );
      return true;
    } catch (e) {
      rethrow;
    }
  }
}