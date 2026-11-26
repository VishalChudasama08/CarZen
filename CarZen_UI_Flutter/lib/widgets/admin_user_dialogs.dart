import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// Backend `UserStatus` values (`active`, `inactive`, `blocked`).
const List<String> kUserStatuses = ['active', 'inactive', 'blocked'];

String _cap(String value) => value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

/// Edit a user's status (`PATCH /v1/admin/users/{id}/role-status`).
/// Role changes are restricted and disabled from the UI.
Future<({String? role, String? status})?> showUserRoleStatusDialog(BuildContext context, UserResponse user) =>
    showDialog<({String? role, String? status})>(context: context, builder: (_) => _StatusDialog(user: user));

/// Asks before `DELETE /v1/admin/users/{id}`.
Future<bool> confirmDeleteUser(BuildContext context, UserResponse user) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete @${user.username}?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${user.fullName} will lose access to CarZen.\n\n'
            'Their cars and listings are not changed automatically. Review them on the user page first.',
            style: const TextStyle(height: 1.45),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete user'),
        ),
      ],
    ),
  );
  return confirmed == true;
}

class _StatusDialog extends StatefulWidget {
  final UserResponse user;
  const _StatusDialog({required this.user});

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  late String _status = kUserStatuses.contains(widget.user.status) ? widget.user.status : 'active';

  bool get _statusChanged => _status != widget.user.status;

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return AlertDialog(
      title: Text('Edit status for @${user.username}'),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontFamily: AppText.body),
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Account status'),
                items: [for (final s in kUserStatuses) DropdownMenuItem(value: s, child: Text(_cap(s)))],
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
              const SizedBox(height: 14),
              if (_status == 'blocked' || _status == 'inactive')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.danger),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text('Listings stay as they are', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.danger)),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Suspend their listings separately from the user page if needed.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _statusChanged
              ? () => Navigator.pop(
                    context,
                    (role: null, status: _status),
                  )
              : null,
          child: const Text('Save status'),
        ),
      ],
    );
  }
}
