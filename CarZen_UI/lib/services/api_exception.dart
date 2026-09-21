/// Thrown by [ApiClient] (and every service built on it) whenever a request
/// to the CarZen backend fails. Carries a user-friendly [message] plus the
/// raw [statusCode] when one is available, so callers can branch on it
/// (e.g. 401 vs 403 vs 404) without re-parsing the response themselves.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// True when the backend refused the call purely because of the account's
  /// (legacy) role — e.g. the current backend still restricts selling to a
  /// `seller` role and ordering to a `user` role. Screens can show a calm
  /// "not available for this account yet" state instead of a raw error.
  final bool isRoleRestriction;

  const ApiException(this.message, {this.statusCode, this.isRoleRestriction = false});

  /// True when the backend rejected the stored token (missing, expired, or
  /// otherwise invalid). Screens should catch this and route back to Login.
  bool get isAuthError => statusCode == 401;

  /// True for network/timeout failures where no HTTP response was received.
  bool get isNetworkError => statusCode == null;

  @override
  String toString() => message;
}
