/// Thrown by [ApiClient] (and every service built on it) whenever a request
/// to the CarZen backend fails. Carries a user-friendly [message] plus the
/// raw [statusCode] when one is available, so callers can branch on it
/// (e.g. 401 vs 403 vs 404) without re-parsing the response themselves.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  /// True when the backend rejected the stored token (missing, expired, or
  /// otherwise invalid). Screens should catch this and route back to Login.
  bool get isAuthError => statusCode == 401;

  @override
  String toString() => message;
}
