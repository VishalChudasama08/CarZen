import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Backend `UserStatus` values (`active`, `inactive`, `blocked`).
const List<String> kUserStatuses = ['active', 'inactive', 'blocked'];

/// The product's only two roles.
const List<String> kUserRoles = ['user', 'admin'];

String _cap(String value) => value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

/// Edit a user's role and/or status (`PATCH /v1/admin/users/{id}/role-status`).
///
/// Resolves to only the fields that changed, or `null` if cancelled. Legacy
/// roles (seller, service_provider...) start as `user`; saving migrates them.
Future<({String? role, String? status})?> showUserRoleStatusDialog(BuildContext context, UserResponse user) =>
    showDialog<({String? role, String? status})>(context: context, builder: (_) => _RoleStatusDialog(user: user));

/// Asks before `DELETE /v1/admin/users/{id}`. The backend soft-deletes: the
/// account is deactivated and disappears from the users list.
Future<bool> confirmDeleteUser(BuildContext context, UserResponse user) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete @${user.username}?'),
      content: Text(
        '${user.fullName} will lose access and disappear from the users list. '
        'This cannot be undone from CarZen.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete user'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

class _RoleStatusDialog extends StatefulWidget {
  final UserResponse user;
  const _RoleStatusDialog({required this.user});

  @override
  State<_RoleStatusDialog> createState() => _RoleStatusDialogState();
}

class _RoleStatusDialogState extends State<_RoleStatusDialog> {
  late String _role = widget.user.appRole;
  late String _status = kUserStatuses.contains(widget.user.status) ? widget.user.status : 'active';

  bool get _roleChanged => _role != widget.user.role;
  bool get _statusChanged => _status != widget.user.status;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return AlertDialog(
      title: Text('Edit @${user.username}'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Role'),
                items: [for (final r in kUserRoles) DropdownMenuItem(value: r, child: Text(_cap(r)))],
                onChanged: (v) => setState(() => _role = v ?? _role),
              ),
              if (user.hasLegacyRole)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'This account still has the legacy "${user.role}" role on the server. '
                    'CarZen treats it as a User; saving will convert it.',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ),
              if (_role == 'admin' && !user.isAdmin)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Admins can manage every user, car and order.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.favorite),
                  ),
                ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: [for (final s in kUserStatuses) DropdownMenuItem(value: s, child: Text(_cap(s)))],
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
              if (_status == 'blocked' && user.status != 'blocked')
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'A blocked user can no longer use their account.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.favorite),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: (_roleChanged || _statusChanged)
              ? () => Navigator.pop(
                    context,
                    (role: _roleChanged ? _role : null, status: _statusChanged ? _status : null),
                  )
              : null,
          child: const Text('Save changes'),
        ),
      ],
    );
  }
}
