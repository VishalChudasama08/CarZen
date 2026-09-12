/// Mirrors the backend's `UserResponse` object, returned by both
/// `POST /v1/auth/register` and inside `GET /v1/validate`.
class UserResponse {
  final int id;
  final String firstName;
  final String? lastName;
  final String username;
  final String email;
  final String? phoneNumber;
  final String role;
  final String status;
  final String? profileImageUrl;
  final String? createdAt;
  final String? updatedAt;
  final String? deletedAt;

  const UserResponse({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.username,
    required this.email,
    this.phoneNumber,
    required this.role,
    required this.status,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      username: json['username'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String?,
      role: json['role'] as String? ?? 'user',
      status: json['status'] as String? ?? 'active',
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      deletedAt: json['deleted_at'] as String?,
    );
  }

  String get fullName => [firstName, lastName].where((e) => e != null && e.isNotEmpty).join(' ');
}
