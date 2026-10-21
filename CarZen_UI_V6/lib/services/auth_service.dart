import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/auth_token_response.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'auth_exception.dart';
import 'secure_storage_service.dart';

/// Handles every call to the backend's auth endpoints, plus persisting and
/// validating the JWT. This is the only file that should ever construct an
/// HTTP request for authentication — screens call these methods and only
/// ever see [UserResponse]/[AuthException], never raw HTTP details.
class AuthService {
  AuthService({http.Client? client, SecureStorageService? storage})
      : _client = client ?? http.Client(),
        _storage = storage ?? SecureStorageService.instance;

  final http.Client _client;
  final SecureStorageService _storage;

  /// Registers a new account.
  ///
  /// `role`, `status` and `profile_image_url` are never collected from the
  /// user — they're fixed here to match the backend defaults requested for
  /// this project ("user" / "active" / null).
  Future<UserResponse> register({
    required String firstName,
    String? lastName,
    required String username,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    final body = {
      'first_name': firstName,
      'last_name': (lastName == null || lastName.isEmpty) ? null : lastName,
      'username': username,
      'email': email,
      'password': password,
      'phone_number': (phoneNumber == null || phoneNumber.isEmpty) ? null : phoneNumber,
      'role': 'user',
      'status': 'active',
      'profile_image_url': null,
    };

    final response = await _send(() => _client
        .post(
          Uri.parse(ApiConfig.registerEndpoint),
          headers: _jsonHeaders,
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.requestTimeout));

    if (response.statusCode == 201) {
      return UserResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    }

    throw AuthException(_extractErrorMessage(response, fallback: 'Registration failed. Please try again.'),
        statusCode: response.statusCode);
  }

  /// Logs in with email/password, stores the returned JWT securely, and
  /// returns it to the caller.
  Future<String> login({required String email, required String password}) async {
    final response = await _send(() => _client
        .post(
          Uri.parse(ApiConfig.loginEndpoint),
          headers: _jsonHeaders,
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(ApiConfig.requestTimeout));

    if (response.statusCode == 200) {
      final token = AuthTokenResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      await _storage.saveToken(token.accessToken);
      return token.accessToken;
    }

    if (response.statusCode == 401) {
      throw const AuthException('Incorrect email or password.', statusCode: 401);
    }

    throw AuthException(_extractErrorMessage(response, fallback: 'Login failed. Please try again.'),
        statusCode: response.statusCode);
  }

  /// Checks whether a stored token exists and is still valid.
  ///
  /// * Returns the [UserResponse] when the token is valid.
  /// * Returns `null` when there is no token, or the backend rejected it with
  ///   `401`/`403` (expired, invalid, deleted or inactive account). Only in the
  ///   rejection case is the stored token cleared.
  /// * Throws [AuthException] for network errors, timeouts and unexpected
  ///   server responses. The stored token is **kept** in that case, so a
  ///   dropped connection never logs the user out.
  Future<UserResponse?> validateToken() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return null;

    final response = await _send(() => _client.get(
          Uri.parse(ApiConfig.validateEndpoint),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(ApiConfig.requestTimeout));

    if (response.statusCode == 200) {
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['valid'] == true && decoded['user'] != null) {
          return UserResponse.fromJson(decoded['user'] as Map<String, dynamic>);
        }
      } catch (_) {
        throw const AuthException('Unexpected response from the server.', statusCode: 200);
      }
      await _storage.deleteToken();
      return null;
    }

    if (response.statusCode == 401 || response.statusCode == 403) {
      await _storage.deleteToken();
      return null;
    }

    throw AuthException(
      'The server could not verify your session right now. Please try again.',
      statusCode: response.statusCode,
    );
  }

  /// Clears the stored token. The caller is responsible for navigating
  /// back to the Login page afterwards.
  Future<void> logout() => _storage.deleteToken();

  /// Reads only the locally stored JWT.  This intentionally does not call
  /// `/validate`: public pages remain available even while the API is down.
  /// Protected actions use [validateToken] immediately before proceeding.
  Future<bool> hasStoredToken() async {
    final token = await _storage.readToken();
    return token != null && token.isNotEmpty;
  }

  /// The JWT contains the role issued by the backend. It is used only to
  /// choose navigation affordances; server-side authorization remains the
  /// source of truth for every protected request.
  Future<String?> storedRole() async {
    final token = await _storage.readToken();
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final decoded = jsonDecode(payload) as Map<String, dynamic>;
      return decoded['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on TimeoutException {
      throw const AuthException('The request timed out. Please try again.');
    } on SocketException {
      throw const AuthException('Cannot reach the server. Check your connection and try again.');
    } on HttpException {
      throw const AuthException('Cannot reach the server. Check your connection and try again.');
    } on http.ClientException {
      throw const AuthException('Cannot reach the server. Check your connection and try again.');
    } on FormatException {
      throw const AuthException('Unexpected response from the server.');
    } catch (e) {
      if (e is AuthException) rethrow;
      throw const AuthException('Something went wrong. Please try again.');
    }
  }

  /// Tries to pull a readable message out of a FastAPI-style error body
  /// (`{"detail": "..."}` or `{"detail": [{"msg": "..."}]}`), falling back
  /// to a generic message when the body isn't in that shape.
  String _extractErrorMessage(http.Response response, {required String fallback}) {
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
      // Fall through to fallback.
    }
    return fallback;
  }
}
