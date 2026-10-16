import 'package:flutter/foundation.dart';

/// Central configuration for talking to the CarZen backend.
///
/// Keeping the base URL here (instead of scattered across service files)
/// means switching from a local dev server to staging/production later is
/// a one-line change.
class ApiConfig {
  ApiConfig._();

  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// Base URL of the backend API.
  /// Platform-aware: uses --dart-define=API_BASE_URL if set;
  /// otherwise defaults to http://10.0.2.2:8085 on Android (emulator)
  /// and http://127.0.0.1:8085 on web/desktop/iOS.
  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8085';
    }
    return 'http://127.0.0.1:8085';
  }

  static String get registerEndpoint => '$baseUrl/v1/auth/register';
  static String get loginEndpoint => '$baseUrl/v1/auth/login';
  static String get validateEndpoint => '$baseUrl/v1/auth/validate';

  /// Convenience prefix for every other `/v1/...` endpoint added by the
  /// car/catalog/marketplace/user services.
  static String get v1 => '$baseUrl/v1';

  static const Duration requestTimeout = Duration(seconds: 15);
}
