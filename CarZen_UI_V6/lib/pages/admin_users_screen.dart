import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/admin_user_dialogs.dart';
import 'package:carzen_flutter/widgets/admin_widgets.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';

StatusTone userStatusTone(String status) => switch (status) {
      'active' => StatusTone.success,
      'blocked' => StatusTone.danger,
      _ => StatusTone.neutral,
    };

/// Users - `GET /v1/admin/users` returns everyone in one list, so search,
/// filters and paging happen here.
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  static const _pageSize = 15;
  final _service = ProfileService();

  List<UserResponse>? _users;
  Object? _error;
  bool _refreshing = false;
  String _query = '';
  String? _status;
  String? _role;
  int _page = 1;
  int? _busyId;

  int? get _myId => SessionController.instance.user?.id;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _error = null;
      _refreshing = true;
    });
    try {
      final users = await _service.adminListUsers();
      if (mounted) setState(() => _users = users);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  List<UserResponse> get _filtered {
    final q = _query.toLowerCase();
    return (_users ?? const <UserResponse>[]).where((u) {
      if (_status != null && u.status != _status) return false;
      if (_role != null && u.role != _role) return false;
      if (q.isEmpty) return true;
      return u.fullName.toLowerCase().contains(q) ||
          u.username.toLowerCase().contains(q) ||
          u.email.toLowerCase().contains(q) ||
          (u.phoneNumber ?? '').contains(q) ||
          '${u.id}' == q;
    }).toList();
  }

  Future<void> _editStatus(UserResponse user) async {
    final change = await showUserRoleStatusDialog(context, user);
    if (change == null || !mounted) return;
    setState(() => _busyId = user.id);
    try {
      final updated = await _service.adminUpdateRoleStatus(user.id, role: change.role, status: change.status);
      if (!mounted) return;
      setState(() => _users = [for (final u in _users!) u.id == updated.id ? updated : u]);
      showAppSnack(context, '@${updated.username} is now ${updated.statusLabel.toLowerCase()}');
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _delete(UserResponse user) async {
    if (!await confirmDeleteUser(context, user) || !mounted) return;
    setState(() => _busyId = user.id);
    try {
      await _service.adminDeleteUser(user.id);
      if (!mounted) return;
      setState(() => _users = _users!.where((u) => u.id != user.id).toList());
      showAppSnack(context, '@${user.username} deleted');
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  void _open(UserResponse u) => Navigator.of(context).pushNamed(AppRoutes.adminUser(u.id)).then((_) => _load());

  @override
  Widget build(BuildContext context) {
    final users = _users;
    final filtered = _filtered;
    final totalPages = (filtered.length / _pageSize).ceil().clamp(1, 1 << 20);
    final page = _page.clamp(1, totalPages);
    final pageItems = filtered.skip((page - 1) * _pageSize).take(_pageSize).toList();
    final counts = <String, int>{};
    for (final u in users ?? const <UserResponse>[]) {
      counts[u.status] = (counts[u.status] ?? 0) + 1;
    }

    return AdminPage(
      section: NavSection.adminUsers,
      title: 'Users',
      subtitle: users == null
          ? 'Everyone with a CarZen account.'
          : '${formatCount(users.length)} accounts: ${counts['active'] ?? 0} active, ${counts['inactive'] ?? 0} inactive, ${counts['blocked'] ?? 0} blocked.',
      onRefresh: _load,
      filters: AdminFilterBar(children: [
        SegmentFilter<String?>(
          options: const [(null, 'All'), ('active', 'Active'), ('inactive', 'Inactive'), ('blocked', 'Blocked')],
          selected: _status,
          onChanged: (v) => setState(() {
            _status = v;
            _page = 1;
          }),
        ),
        SegmentFilter<String?>(
          options: const [(null, 'Any role'), ('user', 'Customers'), ('admin', 'Admins')],
          selected: _role,
          onChanged: (v) => setState(() {
            _role = v;
            _page = 1;
          }),
        ),
        AdminSearchField(
          hint: 'Name, username, email or phone',
          onSubmitted: (v) => setState(() {
            _query = v;
            _page = 1;
          }),
        ),
      ]),
      child: Builder(builder: (context) {
        final frame = BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.divider),
        );
        if (users == null && _error != null) {
          return Container(decoration: frame, child: ApiErrorView(error: _error!, onRetry: _load, compact: true));
        }
        if (users == null) {
          return Container(
            decoration: frame,
            padding: const EdgeInsets.all(16),
            child: const Column(children: [SkeletonLine(), SizedBox(height: 14), SkeletonLine(), SizedBox(height: 14), SkeletonLine()]),
          );
        }
        if (filtered.isEmpty) {
          return Container(
            decoration: frame,
            child: EmptyStateView(
              compact: true,
              icon: Icons.person_search_outlined,
              title: 'No users match',
              message: 'Try a different search or clear the filters.',
              action: OutlinedButton(
                onPressed: () => setState(() {
                  _query = '';
                  _status = null;
                  _role = null;
                }),
                child: const Text('Clear filters'),
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_refreshing) const Padding(padding: EdgeInsets.only(bottom: 8), child: LinearProgressIndicator(minHeight: 2)),
            AdminTable<UserResponse>(
              items: pageItems,
              onTap: _open,
              actionsWidth: 150,
              cardTitle: (u) => Text(u.fullName.isEmpty ? '@${u.username}' : u.fullName),
              cardBadge: (u) => StatusPill(label: u.statusLabel, tone: userStatusTone(u.status)),
              columns: [
                AdminColumn(
                  'Name',
                  (u) => Row(children: [
                    CircleAvatar(
                      radius: 17,
                      backgroundColor: u.isAdmin ? AppColors.ink : AppColors.chromeTint,
                      child: Text(u.initials, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: u.isAdmin ? Colors.white : AppColors.chrome)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: StackedCell(u.fullName.isEmpty ? '@${u.username}' : u.fullName, '@${u.username}${u.id == _myId ? '  (you)' : ''}')),
                  ]),
                  flex: 4,
                  showInCard: false,
                ),
                AdminColumn('Email', (u) => TextCell(u.email), flex: 4),
                AdminColumn('Phone', (u) => TextCell(u.phoneNumber ?? 'Not added'), flex: 2),
                AdminColumn('Role', (u) => u.isAdmin ? const StatusPill(label: 'Admin', tone: StatusTone.highlight, icon: Icons.shield_outlined) : const TextCell('Customer'), flex: 2),
                AdminColumn('Joined', (u) => TextCell(formatDate(u.createdAtDate)), flex: 2),
                AdminColumn('Status', (u) => StatusPill(label: u.statusLabel, tone: userStatusTone(u.status)), flex: 2, showInCard: false),
              ],
              actions: (u) {
                if (_busyId == u.id) return const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))];
                final me = u.id == _myId;
                return [
                  RowAction('View', onPressed: () => _open(u)),
                  if (!me)
                    PopupMenuButton<String>(
                      tooltip: 'More',
                      onSelected: (v) => v == 'status' ? _editStatus(u) : _delete(u),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'status', child: Text('Change status')),
                        PopupMenuItem(value: 'delete', child: Text('Delete user', style: TextStyle(color: AppColors.danger))),
                      ],
                    ),
                ];
              },
            ),
            const SizedBox(height: 16),
            PaginationBar(
              meta: PaginationMeta(page: page, limit: _pageSize, total: filtered.length, totalPages: totalPages),
              itemLabel: 'users',
              onPageChanged: (p) => setState(() => _page = p),
            ),
          ],
        );
      }),
    );
  }
}
