import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// `GET /v1/notifications` (or `/unread`) with open, mark read, mark all
/// read and delete.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = EngagementService();
  final _session = SessionController.instance;
  bool _unreadOnly = false;
  bool _markingAll = false;
  final Set<int> _busy = {};
  late PagedController<NotificationRecord> _paged = _controller();

  PagedController<NotificationRecord> _controller() => PagedController<NotificationRecord>(
        limit: 20,
        fetch: (page, limit) => _service.listNotifications(page: page, limit: limit, unreadOnly: _unreadOnly),
      )..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _setFilter(bool unreadOnly) {
    if (unreadOnly == _unreadOnly) return;
    final old = _paged;
    setState(() {
      _unreadOnly = unreadOnly;
      _paged = _controller();
    });
    old.dispose();
  }

  Future<void> _reload() async {
    await _paged.refresh();
    await _session.refreshUnread(force: true);
  }

  Future<void> _markAllRead() async {
    setState(() => _markingAll = true);
    try {
      await _service.markAllRead();
      if (!mounted) return;
      showAppSnack(context, 'All caught up');
      await _reload();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _markingAll = false);
    }
  }

  Future<void> _delete(NotificationRecord item) async {
    setState(() => _busy.add(item.id));
    try {
      await _service.deleteNotification(item.id);
      if (!mounted) return;
      showAppSnack(context, 'Notification deleted');
      await _reload();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(item.id));
    }
  }

  Future<bool> _markRead(NotificationRecord item) async {
    try {
      final updated = await _service.markRead(item.id);
      if (!mounted) return false;
      setState(() {
        final index = _paged.items.indexWhere((n) => n.id == item.id);
        if (index >= 0) _paged.items[index] = updated;
      });
      _session.refreshUnread(force: true);
      return true;
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
      return false;
    }
  }

  /// Where a notification leads, from its reference type and id.
  String? _routeFor(NotificationRecord n) {
    final id = n.referenceId;
    final admin = _session.isAdmin;
    final title = n.title.toLowerCase();
    switch (n.referenceType) {
      case 'order':
        if (admin) return AppRoutes.adminOrders;
        final toSeller = title.contains('new order') || title.contains('cancelled by buyer');
        return toSeller ? AppRoutes.sales : AppRoutes.orders;
      case 'payment':
        if (admin) return AppRoutes.adminOrders;
        final toSeller = title.contains('buyer');
        return toSeller ? AppRoutes.sales : AppRoutes.orders;
      case 'listing':
        return id == null ? AppRoutes.favorites : AppRoutes.carDetails(id);
      case 'inquiry':
        if (id == null) return AppRoutes.messages;
        return AppRoutes.inquiry(id, asSeller: title.contains('new buyer inquiry'));
      case 'car':
        if (admin) return id == null ? AppRoutes.adminCars : AppRoutes.adminCar(id);
        return id == null ? AppRoutes.sell : AppRoutes.myCar(id);
      case 'report':
        return admin ? AppRoutes.adminReports : AppRoutes.profileReports;
      case 'service_request':
        if (admin) return AppRoutes.adminServiceRequests;
        return id == null ? AppRoutes.serviceRequests : AppRoutes.serviceRequest(id);
      case 'service_payment':
        return admin ? AppRoutes.adminServiceRequests : AppRoutes.serviceRequests;
    }
    return null;
  }

  Future<void> _open(NotificationRecord item) async {
    if (!item.isRead) await _markRead(item);
    final route = _routeFor(item);
    if (route != null && mounted) Navigator.of(context).pushNamed(route);
  }

  static IconData iconFor(NotificationRecord n) {
    switch (n.referenceType) {
      case 'service_request':
      case 'service_payment':
        return Icons.build_outlined;
      case 'inquiry':
        return Icons.chat_bubble_outline;
      case 'report':
        return Icons.flag_outlined;
      case 'car':
        return Icons.fact_check_outlined;
    }
    return switch (n.type) {
      'order' => Icons.receipt_long_outlined,
      'payment' => Icons.payments_outlined,
      'listing' => Icons.directions_car_outlined,
      'favorite' => Icons.favorite_border,
      'admin' => Icons.shield_outlined,
      _ => Icons.notifications_none,
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: _session.isAdmin ? NavSection.adminNotifications : NavSection.notifications,
      title: 'Notifications',
      fallbackRoute: _session.isAdmin ? AppRoutes.admin : AppRoutes.account,
      body: PageScroll(
        maxWidth: 820,
        verticalPadding: Breakpoints.isCompact(context) ? 18 : 32,
        onRefresh: _reload,
        child: AnimatedBuilder(
          animation: Listenable.merge([_paged, _session]),
          builder: (context, _) {
            final unread = _session.unreadCount;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Notifications',
                  subtitle: unread > 0 ? '$unread unread. Open one to go straight to the order, message or booking.' : 'You are all caught up.',
                  actions: [
                    if (unread > 0)
                      OutlinedButton.icon(
                        onPressed: _markingAll ? null : _markAllRead,
                        icon: _markingAll
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.done_all, size: 18),
                        label: const Text('Mark all as read'),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                SegmentFilter<bool>(
                  options: const [(false, 'All'), (true, 'Unread')],
                  selected: _unreadOnly,
                  onChanged: _setFilter,
                ),
                const SizedBox(height: 14),
                PagedBody<NotificationRecord>(
                  controller: _paged,
                  itemLabel: 'notifications',
                  skeletonHeight: 78,
                  spacing: 8,
                  empty: EmptyStateView(
                    compact: true,
                    icon: Icons.notifications_none,
                    title: _unreadOnly ? 'No unread notifications' : 'Nothing here yet',
                    message: 'Order updates, replies from sellers and workshop updates appear here.',
                  ),
                  itemBuilder: (context, item) => _NotificationTile(
                    item: item,
                    icon: iconFor(item),
                    busy: _busy.contains(item.id),
                    hasTarget: _routeFor(item) != null,
                    onTap: () => _open(item),
                    onMarkRead: item.isRead ? null : () => _markRead(item),
                    onDelete: () => _delete(item),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationRecord item;
  final IconData icon;
  final bool busy;
  final bool hasTarget;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback onDelete;

  const _NotificationTile({
    required this.item,
    required this.icon,
    required this.busy,
    required this.hasTarget,
    required this.onTap,
    required this.onMarkRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;
    return Semantics(
      button: true,
      label: '${unread ? 'Unread. ' : ''}${item.title}. ${item.message}',
      excludeSemantics: false,
      child: Material(
        color: unread ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: InkWell(
          onTap: busy ? null : onTap,
          borderRadius: BorderRadius.circular(AppRadii.md),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadii.md),
              border: Border.all(color: unread ? AppColors.lineStrong : AppColors.divider),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: unread ? AppColors.ink : AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                  child: Icon(icon, size: 19, color: unread ? Colors.white : AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: TextStyle(fontWeight: unread ? FontWeight.w700 : FontWeight.w500, fontSize: 14.5),
                            ),
                          ),
                          if (unread)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.plate, borderRadius: BorderRadius.circular(AppRadii.xs)),
                              child: const Text('New', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.ink)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(item.message, style: const TextStyle(color: AppColors.textSecondary, height: 1.4, fontSize: 14)),
                      const SizedBox(height: 5),
                      Text(
                        [formatRelative(item.createdAt), if (hasTarget) 'Tap to open'].where((s) => s.isNotEmpty).join('  |  '),
                        style: const TextStyle(fontSize: 12, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                ),
                if (busy)
                  const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                else
                  PopupMenuButton<String>(
                    tooltip: 'More actions',
                    icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
                    onSelected: (v) => v == 'read' ? onMarkRead?.call() : onDelete(),
                    itemBuilder: (_) => [
                      if (onMarkRead != null) const PopupMenuItem(value: 'read', child: Text('Mark as read')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
