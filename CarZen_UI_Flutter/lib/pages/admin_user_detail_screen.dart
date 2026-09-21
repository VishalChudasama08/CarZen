import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/admin_user_dialogs.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/user_badges.dart';
import 'package:flutter/material.dart';

/// One user for an admin — `GET /v1/admin/users/{id}` — with the same edit
/// (`PATCH .../role-status`) and delete (`DELETE .../{id}`) actions as the list.
class AdminUserDetailScreen extends StatefulWidget {
  final int userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final _profileService = ProfileService();

  UserResponse? _user;
  int? _myId;
  Object? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _profileService.adminGetUser(widget.userId);
      var me = _myId;
      if (me == null) {
        try {
          me = (await _profileService.getMe()).id;
        } on ApiException {
          // Unknown: only the row protections are skipped.
        }
      }
      if (!mounted) return;
      setState(() {
        _user = user;
        _myId = me;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = const ApiException('The server sent an unexpected response.');
        _loading = false;
      });
    }
  }

  Future<void> _edit(UserResponse user) async {
    final change = await showUserRoleStatusDialog(context, user);
    if (change == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final updated = await _profileService.adminUpdateRoleStatus(user.id, role: change.role, status: change.status);
      if (!mounted) return;
      setState(() => _user = updated);
      _snack('Saved changes for @${updated.username}.');
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(UserResponse user) async {
    if (!await confirmDeleteUser(context, user) || !mounted) return;
    setState(() => _busy = true);
    try {
      await _profileService.adminDeleteUser(user.id);
      if (!mounted) return;
      _snack('@${user.username} was deleted.');
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.adminUsers, (r) => false);
      }
    } on ApiException catch (e) {
      _snack(e.message);
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.adminUsers, title: 'User details'),
      body: SafeArea(child: ContentWidth(maxWidth: 760, child: _buildBody())),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(label: 'Loading user...');
    final error = _error;
    if (error != null) {
      if (error is ApiException && error.statusCode == 404) {
        return EmptyStateView(
          icon: Icons.person_off_outlined,
          title: 'User not found',
          message: 'This account does not exist or was already deleted.',
          action: FilledButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.adminUsers, (r) => false),
            child: const Text('Back to Users'),
          ),
        );
      }
      return ApiErrorView(error: error, onRetry: _load, fallback: 'Could not load this user.');
    }

    final user = _user!;
    final isMe = user.id == _myId;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      user.initials,
                      style: const TextStyle(color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: Theme.of(context).textTheme.titleLarge),
                        Text('@${user.username}', style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [RoleBadge(user: user), StatusBadge(status: user.status), if (isMe) const YouBadge()],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, color: AppColors.divider),
              _InfoRow(icon: Icons.tag_rounded, label: 'User ID', value: '${user.id}'),
              _InfoRow(icon: Icons.mail_outline_rounded, label: 'Email', value: user.email),
              _InfoRow(
                icon: Icons.phone_outlined,
                label: 'Phone',
                value: (user.phoneNumber == null || user.phoneNumber!.isEmpty) ? 'Not added' : user.phoneNumber!,
              ),
              _InfoRow(icon: Icons.badge_outlined, label: 'Role', value: user.roleLabel),
              _InfoRow(icon: Icons.toggle_on_outlined, label: 'Status', value: user.statusLabel),
              _InfoRow(
                icon: Icons.event_outlined,
                label: 'Member since',
                value: user.createdAtDate == null ? 'Unknown' : formatDateTime(user.createdAtDate),
              ),
              _InfoRow(
                icon: Icons.update_rounded,
                label: 'Last updated',
                value: user.updatedAtDate == null ? 'Never' : formatDateTime(user.updatedAtDate),
              ),
              if (user.hasLegacyRole)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'The server still stores the legacy "${user.role}" role for this account. CarZen treats it as a User.',
                    style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                  ),
                ),
              const SizedBox(height: 20),
              if (isMe)
                const Text(
                  'This is your own account. Use Profile to change your details.',
                  style: TextStyle(color: AppColors.textSecondary),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy ? null : () => _edit(user),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit role and status'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : () => _delete(user),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.favorite),
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: const Text('Delete user'),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 16),
            Expanded(
              child: Text(value, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
            ),
          ],
        ),
      );
}
