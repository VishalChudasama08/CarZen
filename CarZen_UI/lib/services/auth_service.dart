import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/auth_token_response.dart';
import '../models/user_response.dart';
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
  /// Returns the [UserResponse] when valid. Returns `null` when there's no
  /// token, the token is invalid/expired, or the server is unreachable —
  /// in every one of those cases the stored token is cleared so the app
  /// falls back to the Login page.
  Future<UserResponse?> validateToken() async {
    final token = await _storage.readToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.validateEndpoint),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        if (decoded['valid'] == true && decoded['user'] != null) {
          return UserResponse.fromJson(decoded['user'] as Map<String, dynamic>);
        }
      }
    } catch (_) {
      // Network error, timeout, or malformed response — treat as invalid.
    }

    await _storage.deleteToken();
    return null;
  }

  /// Clears the stored token. The caller is responsible for navigating
  /// back to the Login page afterwards.
  Future<void> logout() => _storage.deleteToken();

  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    try {
      return await request();
    } on SocketException {
      throw const AuthException('Cannot reach the server. Check your connection and try again.');
    } on HttpException {
      throw const AuthException('Cannot reach the server. Check your connection and try again.');
    } on FormatException {
      throw const AuthException('Unexpected response from the server.');
    // } catch (e) {
    //   if (e is AuthException) rethrow;
    //   throw const AuthException('Something went wrong. Please try again.');
    // }
    } catch (e, stackTrace) {
      print('AUTH ERROR: $e');
      print('STACK TRACE: $stackTrace');

      if (e is AuthException) rethrow;

      throw AuthException('Auth error: $e');
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
