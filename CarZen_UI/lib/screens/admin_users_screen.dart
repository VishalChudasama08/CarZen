import 'package:flutter/material.dart';
import '../models/user_response.dart';
import '../services/api_exception.dart';
import '../services/profile_service.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';

const _roles = ['buyer', 'seller', 'reseller', 'service_provider', 'user', 'admin'];
const _statuses = ['active', 'inactive', 'blocked'];

/// Admin-only user management — `GET /v1/admin/users`,
/// `PATCH /v1/admin/users/{id}/role-status`, `DELETE /v1/admin/users/{id}`.
/// Only reachable from [ProfileScreen] when `role == "admin"`.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _profileService = ProfileService();
  late Future<List<UserResponse>> _future;

  @override
  void initState() {
    super.initState();
    _future = _profileService.adminListUsers();
  }

  void _refresh() => setState(() => _future = _profileService.adminListUsers());

  Future<void> _openEditDialog(UserResponse user) async {
    String role = user.role;
    String status = user.status;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('@${user.username}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                onChanged: (v) => setDialogState(() => role = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setDialogState(() => status = v!),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (saved != true) return;
    try {
      await _profileService.adminUpdateRoleStatus(user.id, role: role, status: status);
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  Future<void> _handleDelete(UserResponse user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete @${user.username}?'),
        content: const Text('This permanently removes the account.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: AppColors.favorite))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _profileService.adminDeleteUser(user.id);
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Manage Users'), backgroundColor: AppColors.background),
      body: SafeArea(
        child: FutureBuilder<List<UserResponse>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading users...');
            }
            if (snapshot.hasError) {
              final message =
                  snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Could not load users.';
              return ErrorStateView(message: message, onRetry: _refresh);
            }
            final users = snapshot.data!;
            if (users.isEmpty) {
              return const EmptyStateView(title: 'No users', message: 'No registered users found.');
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: ListTile(
                    title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('@${user.username} · ${user.email}\nrole: ${user.role} · status: ${user.status}'),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _openEditDialog(user)),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.favorite),
                          onPressed: () => _handleDelete(user),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
