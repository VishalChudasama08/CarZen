// TODO(Ayush): gap B — blocked/deleted users and their cars
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// Backend `UserStatus` values (`active`, `inactive`, `blocked`).
const List<String> kUserStatuses = ['active', 'inactive', 'blocked'];

String _cap(String value) => value.isEmpty ? value : value[0].toUpperCase() + value.substring(1);

/// Edit a user's status (`PATCH /v1/admin/users/{id}/role-status`).
/// Role changes are restricted and disabled from the UI.
Future<({String? role, String? status})?> showUserRoleStatusDialog(BuildContext context, UserResponse user) =>
    showDialog<({String? role, String? status})>(context: context, builder: (_) => _StatusDialog(user: user));

/// Asks before `DELETE /v1/admin/users/{id}`.
/// // TODO(Ayush): gap B — blocked/deleted users and their cars (listings not automatically hidden)
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
            '${user.fullName} will lose access and be deactivated.\n\n'
            'Important: Their existing listings are not changed automatically.',
            style: const TextStyle(height: 1.45),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context, false);
              Navigator.of(context).pushNamed(AppRoutes.adminCars);
            },
            icon: const Icon(Icons.directions_car_rounded, size: 16),
            label: const Text("Review user's cars"),
          ),
        ],
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
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Account Status'),
                items: [for (final s in kUserStatuses) DropdownMenuItem(value: s, child: Text(_cap(s)))],
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
              const SizedBox(height: 14),
              if (_status == 'blocked' || _status == 'inactive')
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.favorite.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.favorite.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.favorite),
                          SizedBox(width: 6),
                          Text('Listings Notice', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.favorite)),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Their existing listings are not changed automatically. You can review them in Car Approvals.',
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
