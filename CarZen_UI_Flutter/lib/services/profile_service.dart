import 'package:carzen_flutter/models/user_response.dart';
import 'api_client.dart';

/// Talks to `/v1/users/*` and `/v1/admin/users/*` (also
/// `/v1/admin/update/me`, the admin's own profile update).
class ProfileService {
  ProfileService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<UserResponse> getMe() async {
    final json = await _client.get('/users/me');
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }

  /// Only the fields the user actually changed should be passed —
  /// `UserUpdateProfile` on the backend treats every field as optional.
  Future<UserResponse> updateMe(Map<String, dynamic> partialFields) async {
    final json = await _client.patch('/users/update/me', body: partialFields);
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) {
    return _client.post('/users/me/change-password', body: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });
  }

  Future<void> deleteMyAccount() => _client.delete('/users/me');

  Future<UserResponse> getUserById(int id) async {
    final json = await _client.get('/users/$id');
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }

  // ---- Admin ----

  Future<List<UserResponse>> adminListUsers() async {
    final json = await _client.get('/admin/users');
    return (json as List<dynamic>).map((e) => UserResponse.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<UserResponse> adminGetUser(int id) async {
    final json = await _client.get('/admin/users/$id');
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<UserResponse> adminUpdateRoleStatus(int id, {String? role, String? status}) async {
    final json = await _client.patch('/admin/users/$id/role-status', body: {
      if (role != null) 'role': role,
      if (status != null) 'status': status,
    });
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<void> adminDeleteUser(int id) => _client.delete('/admin/users/$id');

  Future<UserResponse> adminUpdateOwnProfile(Map<String, dynamic> partialFields) async {
    final json = await _client.patch('/admin/update/me', body: partialFields);
    return UserResponse.fromJson(json as Map<String, dynamic>);
  }
}
