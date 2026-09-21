/// Central configuration for talking to the CarZen backend.
///
/// Keeping the base URL here (instead of scattered across service files)
/// means switching from a local dev server to staging/production later is
/// a one-line change.
class ApiConfig {
  ApiConfig._();

  /// Base URL of the backend API.
  /// NOTE: `127.0.0.1` only works when running on the same machine as the
  /// backend (e.g. web, desktop, or an emulator with port-forwarding). On a
  /// physical device or the Android emulator, replace this with your
  /// machine's LAN IP (or `10.0.2.2` for the Android emulator).
  ///
  /// Override at build/run time without touching code, e.g.
  ///   flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
  ///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   (Android emulator)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static const String registerEndpoint = '$baseUrl/v1/auth/register';
  static const String loginEndpoint = '$baseUrl/v1/auth/login';
  static const String validateEndpoint = '$baseUrl/v1/auth/validate';

  /// Convenience prefix for every other `/v1/...` endpoint added by the
  /// car/catalog/marketplace/user services.
  static const String v1 = '$baseUrl/v1';

  static const Duration requestTimeout = Duration(seconds: 15);
}
