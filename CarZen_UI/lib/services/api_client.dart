import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:carzen_flutter/config/api_config.dart';
import 'api_exception.dart';
import 'secure_storage_service.dart';

/// Thin wrapper around [http.Client] shared by every service that talks to
/// a protected (`Authorization: Bearer <token>`) or public `/v1/...`
/// endpoint. Centralizing this here means car/catalog/marketplace/user
/// services never build headers or parse error bodies themselves — they
/// just call [get]/[post]/[patch]/[delete]/[postMultipart] and get back
/// decoded JSON or an [ApiException] with a friendly message.
class ApiClient {
  ApiClient({http.Client? client, SecureStorageService? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? SecureStorageService.instance;

  final http.Client _client;
  final SecureStorageService _storage;

  Future<Map<String, String>> _headers({bool withBody = false}) async {
    final token = await _storage.readToken();
    return {
      'Accept': 'application/json',
      if (withBody) 'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final full = path.startsWith('http') ? path : '${ApiConfig.v1}$path';
    final uri = Uri.parse(full);
    if (query == null || query.isEmpty) return uri;
    final cleaned = <String, String>{};
    query.forEach((key, value) {
      if (value != null) cleaned[key] = value.toString();
    });
    return uri.replace(queryParameters: {...uri.queryParameters, ...cleaned});
  }

  /// GET `/v1$path` (or an absolute `path` if one is passed).
  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    final response = await _run(() async {
      final headers = await _headers();
      return _client.get(_uri(path, query), headers: headers).timeout(ApiConfig.requestTimeout);
    });
    return _decode(response);
  }

  Future<dynamic> post(String path, {Object? body}) async {
    final response = await _run(() async {
      final headers = await _headers(withBody: true);
      return _client
          .post(_uri(path), headers: headers, body: body == null ? null : jsonEncode(body))
          .timeout(ApiConfig.requestTimeout);
    });
    return _decode(response);
  }

  Future<dynamic> patch(String path, {Object? body}) async {
    final response = await _run(() async {
      final headers = await _headers(withBody: true);
      return _client
          .patch(_uri(path), headers: headers, body: body == null ? null : jsonEncode(body))
          .timeout(ApiConfig.requestTimeout);
    });
    return _decode(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _run(() async {
      final headers = await _headers();
      return _client.delete(_uri(path), headers: headers).timeout(ApiConfig.requestTimeout);
    });
    return _decode(response);
  }

  /// Multipart POST — used only by car media upload
  /// (`POST /v1/cars/{id}/media`), which expects a file plus form fields.
  Future<dynamic> postMultipart(
    String path, {
    required List<int> fileBytes,
    required String fileName,
    required Map<String, String> fields,
  }) async {
    final response = await _run(() async {
      final headers = await _headers();
      final request = http.MultipartRequest('POST', _uri(path))
        ..headers.addAll(headers)
        ..fields.addAll(fields)
        ..files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: fileName));
      final streamed = await _client.send(request).timeout(ApiConfig.requestTimeout);
      return http.Response.fromStream(streamed);
    });
    return _decode(response);
  }

  /// The current backend still guards selling behind a `seller` role and
  /// ordering behind a `user` role (see `auth_dependencies.py` and
  /// `order_service.py`). The product decision is a single `user` role that can
  /// buy and sell, so these particular 403s are surfaced with a clear message.
  static final RegExp _legacyRoleDetail =
      RegExp(r'(seller|reseller|service provider|buyer or user)[^.]*access required', caseSensitive: false);

  static const String _legacyRoleMessage =
      "This action isn't available for your account on the current server version yet. "
      'It will work for every account once the backend update is deployed.';

  Future<http.Response> _run(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on SocketException {
      throw const ApiException('Cannot reach the server. Check your connection and try again.');
    } on HttpException {
      throw const ApiException('Cannot reach the server. Check your connection and try again.');
    } on http.ClientException {
      // On Flutter Web (and any non-dart:io platform) a failed connection or a
      // blocked CORS request surfaces as ClientException, not SocketException.
      throw const ApiException('Cannot reach the server. Check your connection and try again.');
    } on FormatException {
      throw const ApiException('Unexpected response from the server.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw const ApiException('Something went wrong. Please try again.');
    }
  }

  dynamic _decode(http.Response response) {
    final status = response.statusCode;

    if (status >= 200 && status < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    if (status == 401) {
      // The stored token is expired or invalid: drop it so the UI stops
      // presenting the user as signed in.
      unawaited(_storage.deleteToken());
      throw const ApiException('Your session has expired. Please log in again.', statusCode: 401);
    }
    if (status == 403) {
      final detail = _detail(response);
      if (detail != null && _legacyRoleDetail.hasMatch(detail)) {
        throw const ApiException(_legacyRoleMessage, statusCode: 403, isRoleRestriction: true);
      }
      throw ApiException(detail ?? 'You do not have permission to do that.', statusCode: 403);
    }
    if (status == 404) {
      throw ApiException(_detail(response) ?? 'The requested item was not found.', statusCode: 404);
    }

    if (status >= 500) {
      throw ApiException('The server could not complete the request. Please try again shortly.', statusCode: status);
    }

    throw ApiException(_detail(response) ?? 'Request failed (${response.statusCode}).', statusCode: status);
  }

  /// Pulls a readable message out of a FastAPI-style error body
  /// (`{"detail": "..."}` or `{"detail": [{"msg": "..."}]}`).
  String? _detail(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) return detail;
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) return first['msg'].toString();
        }
      }
    } catch (_) {
      // Fall through to null -> caller supplies a fallback message.
    }
    return null;
  }
}
