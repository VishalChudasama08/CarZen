import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/admin_user_dialogs.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/user_badges.dart';
import 'package:flutter/material.dart';

/// Admin user management, backed only by endpoints that exist:
///
/// * `GET    /v1/admin/users`                    - the list
/// * `GET    /v1/admin/users/{id}`               - details (see [AdminUserDetailScreen])
/// * `PATCH  /v1/admin/users/{id}/role-status`   - role and status
/// * `DELETE /v1/admin/users/{id}`               - delete (soft delete on the server)
///
/// The list endpoint returns every user and takes no query parameters, so the
/// search box and the role/status chips filter that list on the device.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final _profileService = ProfileService();
  final TextEditingController _search = TextEditingController();

  List<UserResponse> _users = const [];
  int? _myId;
  bool _loading = true;
  Object? _error;
  String _query = '';
  String? _roleFilter;
  String? _statusFilter;
  int? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final users = await _profileService.adminListUsers();
      var me = _myId;
      if (me == null) {
        try {
          me = (await _profileService.getMe()).id;
        } on ApiException {
          // Unknown: the row protections are then skipped and the backend still decides.
        }
      }
      if (!mounted) return;
      setState(() {
        _users = users;
        _myId = me;
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      _onLoadError(e, silent);
    } catch (_) {
      _onLoadError(const ApiException('The server sent an unexpected response.'), silent);
    }
  }

  void _onLoadError(ApiException error, bool silent) {
    if (!mounted) return;
    if (silent) {
      _snack(error.message);
      return;
    }
    setState(() {
      _error = error;
      _loading = false;
    });
  }

  List<UserResponse> get _filtered {
    final q = _query.trim().toLowerCase();
    return _users.where((u) {
      if (_roleFilter != null && u.appRole != _roleFilter) return false;
      if (_statusFilter != null && u.status != _statusFilter) return false;
      if (q.isEmpty) return true;
      return u.fullName.toLowerCase().contains(q) ||
          u.username.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          (u.phoneNumber ?? '').contains(q) ||
          '${u.id}' == q;
    }).toList();
  }

  Future<void> _openDetails(UserResponse user) async {
    await Navigator.of(context).pushNamed(AppRoutes.adminUser(user.id));
    if (mounted) _load(silent: true);
  }

  Future<void> _edit(UserResponse user) async {
    final change = await showUserRoleStatusDialog(context, user);
    if (change == null || !mounted) return;
    setState(() => _busyId = user.id);
    try {
      final updated = await _profileService.adminUpdateRoleStatus(user.id, role: change.role, status: change.status);
      if (!mounted) return;
      setState(() => _users = [for (final u in _users) u.id == updated.id ? updated : u]);
      _snack('Updated @${updated.username}.');
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _delete(UserResponse user) async {
    if (!await confirmDeleteUser(context, user) || !mounted) return;
    setState(() => _busyId = user.id);
    try {
      await _profileService.adminDeleteUser(user.id);
      if (!mounted) return;
      setState(() => _users = _users.where((u) => u.id != user.id).toList());
      _snack('@${user.username} was deleted.');
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.adminUsers, title: 'Users'),
      body: SafeArea(child: ContentWidth(maxWidth: 1100, child: _buildBody())),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(label: 'Loading users...');
    if (_error != null) {
      return ApiErrorView(error: _error!, onRetry: _load, fallback: 'Could not load users.');
    }
    if (_users.isEmpty) {
      return const EmptyStateView(
        icon: Icons.group_outlined,
        title: 'No users yet',
        message: 'Registered users will appear here.',
      );
    }

    final filtered = _filtered;
    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverToBoxAdapter(child: _Header(users: _users)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            sliver: SliverToBoxAdapter(child: _buildFilters(filtered.length)),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: EmptyStateView(
                  icon: Icons.search_off_rounded,
                  title: 'No users match',
                  message: 'Try a different search or clear the filters.',
                  action: OutlinedButton(
                    onPressed: () => setState(() {
                      _search.clear();
                      _query = '';
                      _roleFilter = null;
                      _statusFilter = null;
                    }),
                    child: const Text('Clear search and filters'),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = filtered[index];
                  final isMe = user.id == _myId;
                  return _UserCard(
                    user: user,
                    isMe: isMe,
                    busy: _busyId == user.id,
                    onView: () => _openDetails(user),
                    onEdit: isMe ? null : () => _edit(user),
                    onDelete: isMe ? null : () => _delete(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(int shown) {
    Widget chips(String label, List<(String?, String)> options, String? selected, ValueChanged<String?> onSelected) {
      return Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          for (final (value, text) in options)
            ChoiceChip(
              label: Text(text),
              selected: selected == value,
              onSelected: (_) => onSelected(value),
              selectedColor: AppColors.secondary.withValues(alpha: 0.25),
              checkmarkColor: AppColors.primary,
              side: const BorderSide(color: AppColors.divider),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _search,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Search name, username, email, phone or ID',
            isDense: true,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() {
                      _search.clear();
                      _query = '';
                    }),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        chips(
          'Role',
          const [(null, 'All'), ('user', 'Users'), ('admin', 'Admins')],
          _roleFilter,
          (v) => setState(() => _roleFilter = v),
        ),
        chips(
          'Status',
          const [(null, 'All'), ('active', 'Active'), ('inactive', 'Inactive'), ('blocked', 'Blocked')],
          _statusFilter,
          (v) => setState(() => _statusFilter = v),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Showing $shown of ${_users.length} users',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final List<UserResponse> users;
  const _Header({required this.users});

  @override
  Widget build(BuildContext context) {
    int count(bool Function(UserResponse) test) => users.where(test).length;
    final stats = <(String, int, IconData)>[
      ('Total users', users.length, Icons.group_outlined),
      ('Active', count((u) => u.status == 'active'), Icons.check_circle_outline_rounded),
      ('Inactive', count((u) => u.status == 'inactive'), Icons.pause_circle_outline_rounded),
      ('Blocked', count((u) => u.status == 'blocked'), Icons.block_rounded),
      ('Admins', count((u) => u.isAdmin), Icons.shield_outlined),
    ];
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final (label, value, icon) in stats)
          Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.secondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserResponse user;
  final bool isMe;
  final bool busy;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _UserCard({
    required this.user,
    required this.isMe,
    required this.busy,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primary,
      child: Text(user.initials, style: const TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w700)),
    );
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(user.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 2),
        Text('@${user.username}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
        Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
          Text(user.phoneNumber!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
      ],
    );
    final badges = Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [RoleBadge(user: user), StatusBadge(status: user.status), if (isMe) const YouBadge()],
    );
    final actions = busy
        ? const Padding(
            padding: EdgeInsets.all(10),
            child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(onPressed: onView, child: const Text('View')),
              IconButton(
                tooltip: isMe ? 'Use Profile to edit your own account' : 'Edit role and status',
                icon: const Icon(Icons.edit_outlined),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: isMe ? 'You cannot delete your own account here' : 'Delete user',
                icon: Icon(Icons.delete_outline_rounded, color: onDelete == null ? null : AppColors.favorite),
                onPressed: onDelete,
              ),
            ],
          );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 640) {
            return Row(
              children: [
                avatar,
                const SizedBox(width: 14),
                Expanded(child: info),
                const SizedBox(width: 12),
                SizedBox(width: 150, child: badges),
                const SizedBox(width: 8),
                actions,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [avatar, const SizedBox(width: 12), Expanded(child: info)]),
              const SizedBox(height: 10),
              badges,
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          );
        },
      ),
    );
  }
}
