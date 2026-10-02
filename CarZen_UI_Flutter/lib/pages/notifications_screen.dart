import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// `GET /v1/notifications` with mark-as-read, mark-all-read and delete.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _service = EngagementService();
  final _session = SessionController.instance;
  late final PagedController<NotificationRecord> _paged;

  @override
  void initState() {
    super.initState();
    _paged = PagedController<NotificationRecord>(
      limit: 15,
      fetch: (page, limit) => _service.listNotifications(page: page, limit: limit),
    )..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllRead();
      if (!mounted) return;
      showAppSnack(context, 'All notifications marked as read.');
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  Future<void> _delete(NotificationRecord item) async {
    try {
      await _service.deleteNotification(item.id);
      if (!mounted) return;
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  String? _routeFor(NotificationRecord n) {
    final id = n.referenceId;
    switch (n.referenceType) {
      case 'order':
        return AppRoutes.orders;
      case 'listing':
        return id == null ? null : AppRoutes.carDetails(id);
      case 'inquiry':
        return id == null ? null : AppRoutes.inquiry(id);
      case 'car':
        return n.type == 'admin' ? AppRoutes.adminCars : AppRoutes.sell;
      case 'service_request':
        if (_session.isAdmin) return AppRoutes.adminServiceRequests;
        return id == null ? AppRoutes.serviceRequests : AppRoutes.serviceRequest(id);
    }
    return null;
  }

  Future<void> _open(NotificationRecord item) async {
    if (!item.isRead) {
      try {
        final updated = await _service.markRead(item.id);
        if (mounted) {
          setState(() {
            final index = _paged.items.indexWhere((n) => n.id == item.id);
            if (index >= 0) _paged.items[index] = updated;
          });
        }
      } on ApiException catch (e) {
        if (mounted) showAppSnack(context, e.message, error: true);
      }
    }
    final route = _routeFor(item);
    if (route != null && mounted) Navigator.of(context).pushNamed(route);
  }

  IconData _iconFor(NotificationRecord n) {
    if (n.referenceType == 'service_request') return Icons.build_circle_outlined;
    switch (n.type) {
      case 'order':
        return Icons.receipt_long_outlined;
      case 'payment':
        return Icons.payments_outlined;
      case 'listing':
        return Icons.directions_car_outlined;
      case 'inquiry':
        return Icons.chat_bubble_outline_rounded;
      case 'favorite':
        return Icons.favorite_border_rounded;
      case 'admin':
        return Icons.admin_panel_settings_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.notifications, title: 'Notifications'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.notifications),
      body: SafeArea(
        bottom: false,
        child: PagedListView<NotificationRecord>(
          controller: _paged,
          maxWidth: 860,
          itemLabel: 'notifications',
          skeletonHeight: 84,
          header: AnimatedBuilder(
            animation: _paged,
            builder: (context, _) => PageHeader(
              title: 'Notifications',
              subtitle: 'Updates on your orders, messages and service requests.',
              icon: Icons.notifications_rounded,
              actions: [
                if (_paged.items.any((n) => !n.isRead))
                  OutlinedButton.icon(
                    onPressed: _markAllRead,
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Mark all as read'),
                  ),
              ],
            ),
          ),
          empty: const EmptyStateView(
            icon: Icons.notifications_none_rounded,
            title: 'Nothing new',
            message: 'Order updates, replies from sellers and service request updates appear here.',
          ),
          errorFallback: 'Could not load notifications.',
          itemBuilder: (context, item) => _NotificationTile(
            item: item,
            icon: _iconFor(item),
            onTap: () => _open(item),
            onDelete: () => _delete(item),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationRecord item;
  final IconData icon;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationTile({required this.item, required this.icon, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surface : AppColors.cyanTint,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: item.isRead ? AppColors.divider : AppColors.secondary.withValues(alpha: 0.45)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: item.isRead ? AppColors.textSecondary : AppColors.secondary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w800, fontSize: 14.5),
                  ),
                  const SizedBox(height: 3),
                  Text(item.message, style: const TextStyle(color: AppColors.textSecondary, height: 1.35)),
                  if (item.createdAt != null) ...[
                    const SizedBox(height: 4),
                    Text(formatDateTime(item.createdAt), style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                  ],
                ],
              ),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
