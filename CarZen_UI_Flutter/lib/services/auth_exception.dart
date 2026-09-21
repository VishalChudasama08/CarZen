/// Thrown by [AuthService] whenever a request fails, wrapping a
/// user-friendly [message] plus the raw [statusCode] (when available) so
/// callers can branch on it if needed (e.g. 401 vs 422 vs network error).
class AuthException implements Exception {
  final String message;
  final int? statusCode;

  const AuthException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
