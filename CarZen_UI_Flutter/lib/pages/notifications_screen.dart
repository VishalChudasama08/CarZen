import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// `GET /v1/notifications` with mark-as-read, mark-all-read and delete.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const int _pageSize = 30;

  final _service = EngagementService();
  final List<NotificationRecord> _items = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    setState(() {
      if (reset) {
        _loading = true;
        _page = 1;
      } else {
        _loadingMore = true;
      }
      _error = null;
    });
    try {
      final result = await _service.listNotifications(page: _page, limit: _pageSize);
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(result.data);
        _totalPages = result.pagination.totalPages;
        _loading = false;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
        _loadingMore = false;
        if (!reset) _page--;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _totalPages) return;
    _page++;
    await _load();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _markAllRead() async {
    try {
      await _service.markAllRead();
      await _load(reset: true);
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _delete(NotificationRecord item) async {
    try {
      await _service.deleteNotification(item.id);
      if (!mounted) return;
      setState(() => _items.removeWhere((n) => n.id == item.id));
    } on ApiException catch (e) {
      _snack(e.message);
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
    }
    return null;
  }

  Future<void> _open(NotificationRecord item) async {
    if (!item.isRead) {
      try {
        final updated = await _service.markRead(item.id);
        if (mounted) {
          setState(() {
            final index = _items.indexWhere((n) => n.id == item.id);
            if (index >= 0) _items[index] = updated;
          });
        }
      } on ApiException catch (e) {
        _snack(e.message);
      }
    }
    final route = _routeFor(item);
    if (route != null && mounted) Navigator.of(context).pushNamed(route);
  }

  IconData _iconFor(String? type) {
    switch (type) {
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
    final hasUnread = _items.any((n) => !n.isRead);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.notifications, title: 'Notifications'),
      body: SafeArea(child: _buildBody(hasUnread)),
    );
  }

  Widget _buildBody(bool hasUnread) {
    if (_loading) return const LoadingView(label: 'Loading notifications...');
    if (_error != null && _items.isEmpty) {
      return ApiErrorView(error: _error!, onRetry: () => _load(reset: true), fallback: 'Could not load notifications.');
    }
    if (_items.isEmpty) {
      return const EmptyStateView(
        icon: Icons.notifications_none_rounded,
        title: 'Nothing new',
        message: 'Order updates, replies from sellers and price changes on saved cars appear here.',
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              if (hasUnread)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _markAllRead,
                    icon: const Icon(Icons.done_all_rounded, size: 18),
                    label: const Text('Mark all as read'),
                  ),
                ),
              for (final item in _items) ...[
                _NotificationTile(
                  item: item,
                  icon: _iconFor(item.type),
                  onTap: () => _open(item),
                  onDelete: () => _delete(item),
                ),
                const SizedBox(height: 8),
              ],
              if (_page < _totalPages)
                Center(
                  child: _loadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2.4),
                        )
                      : OutlinedButton(onPressed: _loadMore, child: const Text('Load older notifications')),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      _error is ApiException ? (_error as ApiException).message : 'Could not load more.',
                      style: const TextStyle(color: AppColors.favorite),
                    ),
                  ),
                ),
            ],
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
        decoration: BoxDecoration(
          color: item.isRead ? AppColors.surface : const Color(0xFFFFF7E8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: item.isRead ? AppColors.divider : AppColors.secondary.withValues(alpha: 0.5)),
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
