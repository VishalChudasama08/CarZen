/// Mirrors the response of `POST /v1/auth/login`.
class AuthTokenResponse {
  final String accessToken;
  final String tokenType;

  const AuthTokenResponse({required this.accessToken, required this.tokenType});

  factory AuthTokenResponse.fromJson(Map<String, dynamic> json) {
    return AuthTokenResponse(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
    );
  }
}
