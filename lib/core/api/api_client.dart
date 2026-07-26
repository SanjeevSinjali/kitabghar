// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// Figures out the correct image MIME type from a file's extension, since
/// image_picker's temp file paths (especially from the camera) don't
/// always let http.MultipartFile guess this correctly on its own — and
/// the backend's multer fileFilter strictly rejects anything that isn't
/// exactly image/jpeg, image/png, or image/webp.
MediaType _imageMediaType(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return MediaType('image', 'png');
  if (lower.endsWith('.webp')) return MediaType('image', 'webp');
  // Covers .jpg, .jpeg, and anything else (HEIC gets converted to jpeg
  // by image_picker's imageQuality option, so this is a safe default).
  return MediaType('image', 'jpeg');
}

class ApiClient {
  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 10);

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('=== POST URL: $url');

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw Exception(
          'Request timed out. Check that the server is running and reachable at $url');
    } on SocketException {
      throw Exception(
          'Could not connect to server at $url. Check your IP address and Wi-Fi network.');
    }

    print('=== POST STATUS: ${response.statusCode}');
    print('=== POST BODY: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      throw Exception('Invalid response from server: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> get(
    String url, {
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('=== GET URL: $url');

    late final http.Response response;
    try {
      response = await _client.get(Uri.parse(url), headers: headers).timeout(_timeout);
    } on TimeoutException {
      throw Exception(
          'Request timed out. Check that the server is running and reachable at $url');
    } on SocketException {
      throw Exception(
          'Could not connect to server at $url. Check your IP address and Wi-Fi network.');
    }

    print('=== GET STATUS: ${response.statusCode}');
    print('=== GET BODY: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      throw Exception('Invalid response from server: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('=== DELETE URL: $url');

    late final http.Response response;
    try {
      response =
          await _client.delete(Uri.parse(url), headers: headers).timeout(_timeout);
    } on TimeoutException {
      throw Exception(
          'Request timed out. Check that the server is running and reachable at $url');
    } on SocketException {
      throw Exception(
          'Could not connect to server at $url. Check your IP address and Wi-Fi network.');
    }

    print('=== DELETE STATUS: ${response.statusCode}');
    print('=== DELETE BODY: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      throw Exception('Invalid response from server: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> patch(
    String url, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('=== PATCH URL: $url');

    late final http.Response response;
    try {
      response = await _client
          .patch(
            Uri.parse(url),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
    } on TimeoutException {
      throw Exception(
          'Request timed out. Check that the server is running and reachable at $url');
    } on SocketException {
      throw Exception(
          'Could not connect to server at $url. Check your IP address and Wi-Fi network.');
    }

    print('=== PATCH STATUS: ${response.statusCode}');
    print('=== PATCH BODY: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      throw Exception('Invalid response from server: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String url, {
    required Map<String, String> fields,
    File? file,
    String? fileField,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);

    if (file != null && fileField != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          file.path,
          contentType: _imageMediaType(file.path),
        ),
      );
    }

    print('=== MULTIPART URL: $url');
    print('=== MULTIPART FIELDS: $fields');
    print('=== MULTIPART TOKEN: $token');
    print('=== MULTIPART FILE: ${file?.path}');

    http.Response response;
    try {
      final streamed = await request.send().timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw Exception(
          'Request timed out. Check that the server is running and reachable at $url');
    } on SocketException {
      throw Exception(
          'Could not connect to server at $url. Check your IP address and Wi-Fi network.');
    }

    print('=== MULTIPART STATUS: ${response.statusCode}');
    print('=== MULTIPART RESPONSE: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      throw Exception('Invalid response from server: ${response.body}');
    }
  }

  /// Like postMultipart, but sends a PUT request — used for endpoints like
  /// PUT /auth/update that accept an optional file alongside form fields.
  Future<Map<String, dynamic>> putMultipart(
    String url, {
    required Map<String, String> fields,
    File? file,
    String? fileField,
    String? token,
  }) async {
    final request = http.MultipartRequest('PUT', Uri.parse(url));

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(fields);

    if (file != null && fileField != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          fileField,
          file.path,
          contentType: _imageMediaType(file.path),
        ),
      );
    }

    print('=== MULTIPART(PUT) URL: $url');
    print('=== MULTIPART(PUT) FIELDS: $fields');
    print('=== MULTIPART(PUT) FILE: ${file?.path}');

    http.Response response;
    try {
      final streamed = await request.send().timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw Exception(
          'Request timed out. Check that the server is running and reachable at $url');
    } on SocketException {
      throw Exception(
          'Could not connect to server at $url. Check your IP address and Wi-Fi network.');
    }

    print('=== MULTIPART(PUT) STATUS: ${response.statusCode}');
    print('=== MULTIPART(PUT) RESPONSE: ${response.body}');

    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      throw Exception('Invalid response from server: ${response.body}');
    }
  }
}