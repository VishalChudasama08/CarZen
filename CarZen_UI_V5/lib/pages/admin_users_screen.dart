// TODO(Ayush): gap D — admin users list is unpaginated (paginated client-side)
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/admin_user_dialogs.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:carzen_flutter/widgets/user_badges.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';

/// Admin user management.
///
/// * `GET    /v1/admin/users`                    - the list
/// * `GET    /v1/admin/users/{id}`               - details (see [AdminUserDetailScreen])
/// * `PATCH  /v1/admin/users/{id}/role-status`   - status (roles restricted)
/// * `DELETE /v1/admin/users/{id}`               - delete (soft delete on the server)
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
  String? _statusFilter;
  int? _busyId;

  int _page = 1;
  static const int _pageSize = 10;

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

  void _snack(String message, {bool error = false}) {
    if (!mounted) return;
    showAppSnack(context, message, error: error);
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
          // Ignored
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
      _snack(error.message, error: true);
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
      final updated = await _profileService.adminUpdateRoleStatus(
        user.id,
        role: change.role,
        status: change.status,
      );
      if (!mounted) return;
      setState(() => _users = [for (final u in _users) u.id == updated.id ? updated : u]);
      _snack('Updated @${updated.username}.');
    } on ApiException catch (e) {
      _snack(e.message, error: true);
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
      _snack(e.message, error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(
        current: NavSection.adminUsers,
        title: 'Users',
        fallbackRoute: AppRoutes.admin,
      ),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.adminUsers),
      body: SafeArea(child: ContentWidth(maxWidth: 1000, child: _buildBody())),
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
    final total = filtered.length;
    final totalPages = (total / _pageSize).ceil();
    final safePage = _page > (totalPages > 0 ? totalPages : 1) ? 1 : _page;
    final pageItems = filtered.skip((safePage - 1) * _pageSize).take(_pageSize).toList();
    final meta = PaginationMeta(
      page: safePage,
      limit: _pageSize,
      total: total,
      totalPages: totalPages > 0 ? totalPages : 1,
    );

    return RefreshIndicator(
      onRefresh: () => _load(silent: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PageHeader(
                    title: 'Users',
                    subtitle: 'Manage platform user accounts and access status.',
                    icon: Icons.group_rounded,
                  ),
                  const SizedBox(height: 16),
                  _Header(users: _users),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            sliver: SliverToBoxAdapter(child: _buildFilters(filtered.length)),
          ),
          if (filtered.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24),
                child: EmptyStateView(
                  icon: Icons.search_off_rounded,
                  title: 'No users match',
                  message: 'Try a different search query or clear the status filter.',
                  action: OutlinedButton(
                    onPressed: () => setState(() {
                      _search.clear();
                      _query = '';
                      _statusFilter = null;
                      _page = 1;
                    }),
                    child: const Text('Clear search'),
                  ),
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverList.separated(
                itemCount: pageItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = pageItems[index];
                  final isMe = user.id == _myId;
                  return _CompactUserCard(
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                child: PaginationBar(
                  meta: meta,
                  itemLabel: 'users',
                  onPageChanged: (newPage) => setState(() => _page = newPage),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilters(int shown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _search,
          onChanged: (value) => setState(() {
            _query = value;
            _page = 1;
          }),
          decoration: InputDecoration(
            hintText: 'Search by name or email...',
            isDense: true,
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() {
                      _search.clear();
                      _query = '';
                      _page = 1;
                    }),
                  ),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Status:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            for (final (value, text) in const [
              (null, 'All'),
              ('active', 'Active'),
              ('inactive', 'Inactive'),
              ('blocked', 'Blocked')
            ])
              ChoiceChip(
                label: Text(text),
                selected: _statusFilter == value,
                onSelected: (_) => setState(() {
                  _statusFilter = value;
                  _page = 1;
                }),
                showCheckmark: false,
                selectedColor: AppColors.cyanTint,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _statusFilter == value ? AppColors.secondary : AppColors.textPrimary,
                ),
                side: BorderSide(color: _statusFilter == value ? AppColors.secondary : AppColors.divider),
              ),
          ],
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
    final active = users.where((u) => u.isActive && !u.isBlocked).length;
    final blocked = users.where((u) => u.isBlocked).length;

    return Row(
      children: [
        Expanded(
          child: _Metric(
            label: 'Total users',
            value: users.length,
            icon: Icons.people_outline_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Metric(
            label: 'Active',
            value: active,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _Metric(
            label: 'Blocked',
            value: blocked,
            icon: Icons.block_rounded,
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _Metric({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.secondary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$value', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
                Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact user row: Name only + status pill, whole row tappable, View button.
class _CompactUserCard extends StatelessWidget {
  final UserResponse user;
  final bool isMe;
  final bool busy;
  final VoidCallback onView;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _CompactUserCard({
    required this.user,
    required this.isMe,
    required this.busy,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isNarrow = Breakpoints.isNarrow(context);
    final isCompact = Breakpoints.isCompact(context);
    return SurfaceCard(
      onTap: onView,
      padding: EdgeInsets.symmetric(horizontal: isNarrow ? 12 : 16, vertical: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Text(
              user.initials,
              style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      const YouBadge(),
                    ],
                  ],
                ),
                if (isNarrow) ...[
                  const SizedBox(height: 4),
                  StatusBadge(status: user.status),
                ],
              ],
            ),
          ),
          if (!isNarrow) ...[
            const SizedBox(width: 8),
            StatusBadge(status: user.status),
          ],
          const SizedBox(width: 8),
          if (busy)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.secondary),
            )
          else if (isCompact) ...[
            PopupMenuButton<String>(
              tooltip: 'Actions',
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              onSelected: (val) {
                if (val == 'view') onView();
                if (val == 'edit') onEdit?.call();
                if (val == 'delete') onDelete?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(children: [Icon(Icons.visibility_outlined, size: 18), SizedBox(width: 8), Text('View')]),
                ),
                if (onEdit != null)
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 8), Text('Change status')]),
                  ),
                if (onDelete != null)
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.favorite),
                        SizedBox(width: 8),
                        Text('Delete user', style: TextStyle(color: AppColors.favorite)),
                      ],
                    ),
                  ),
              ],
            ),
          ] else ...[
            FilledButton.tonal(
              onPressed: onView,
              style: FilledButton.styleFrom(
                minimumSize: const Size(60, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text('View', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            if (onEdit != null)
              IconButton(
                tooltip: 'Change status',
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: onEdit,
              ),
            if (onDelete != null)
              IconButton(
                tooltip: 'Delete user',
                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.favorite),
                onPressed: onDelete,
              ),
          ],
        ],
      ),
    );
  }
}
