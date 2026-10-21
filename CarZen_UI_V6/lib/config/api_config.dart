import 'package:flutter/foundation.dart';

/// Central configuration for talking to the CarZen backend.
///
/// Set the backend address at build/run time - nothing is hard-coded per
/// environment:
///
/// ```
/// flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
/// flutter build web --dart-define=API_BASE_URL=https://api.example.com
/// ```
///
/// Without a define it falls back to the backend's documented local address
/// (`uvicorn ... --port 8000`): `http://10.0.2.2:8000` on the Android
/// emulator (the host machine) and `http://127.0.0.1:8000` everywhere else.
class ApiConfig {
  ApiConfig._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const int _defaultPort = 8000;

  /// Base URL of the backend API, without a trailing slash.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl.endsWith('/') ? _envBaseUrl.substring(0, _envBaseUrl.length - 1) : _envBaseUrl;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$_defaultPort';
    }
    return 'http://127.0.0.1:$_defaultPort';
  }

  static String get registerEndpoint => '$baseUrl/v1/auth/register';
  static String get loginEndpoint => '$baseUrl/v1/auth/login';
  static String get validateEndpoint => '$baseUrl/v1/auth/validate';

  /// Prefix for every other `/v1/...` endpoint.
  static String get v1 => '$baseUrl/v1';

  /// Turns a server-relative media path (`/uploads/...`) into a full URL.
  static String? mediaUrl(String? path) {
    if (path == null || path.trim().isEmpty) return null;
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '$baseUrl${path.startsWith('/') ? '' : '/'}$path';
  }

  static const Duration requestTimeout = Duration(seconds: 20);

  /// Photo uploads can take a while on mobile data.
  static const Duration uploadTimeout = Duration(seconds: 90);
}
