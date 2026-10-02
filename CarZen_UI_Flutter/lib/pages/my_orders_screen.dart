import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// Tone for an order status string from the backend.
StatusTone orderTone(String status) => switch (status) {
      'completed' => StatusTone.success,
      'confirmed' || 'processing' => StatusTone.info,
      'cancelled' => StatusTone.neutral,
      'rejected' => StatusTone.danger,
      _ => StatusTone.warning,
    };

/// The buyer's purchase requests — `GET /v1/buyer/orders` (paginated).
/// Payment status is shown as information only; there is no payment flow.
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _service = OrderService();
  late final PagedController<OrderRecord> _paged;
  final Set<int> _cancelling = {};

  @override
  void initState() {
    super.initState();
    _paged = PagedController<OrderRecord>(limit: 8, fetch: (page, limit) => _service.listMyOrders(page: page, limit: limit))..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  Future<void> _cancel(OrderRecord order) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: Text('Your purchase request for ${order.listingTitle} will be cancelled.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep it')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => _cancelling.add(order.id));
    try {
      await _service.cancelOrder(order.id);
      if (!mounted) return;
      showAppSnack(context, 'Purchase request cancelled.');
      await _paged.refresh();
    } on ApiException catch (error) {
      if (mounted) showAppSnack(context, error.message, error: true);
    } finally {
      if (mounted) setState(() => _cancelling.remove(order.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CarZenNavBar(current: NavSection.orders, title: 'My Orders'),
        bottomNavigationBar: const CarZenBottomBar(current: NavSection.orders),
        body: SafeArea(
          bottom: false,
          child: PagedListView<OrderRecord>(
            controller: _paged,
            itemLabel: 'orders',
            maxWidth: 860,
            header: const PageHeader(
              title: 'My orders',
              subtitle: 'Purchase requests you have sent to sellers.',
              icon: Icons.receipt_long_rounded,
            ),
            empty: EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: 'No orders yet',
              message: 'When you send a purchase request for a car, it will appear here.',
              action: FilledButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.browse, (r) => false),
                child: const Text('Browse cars'),
              ),
            ),
            errorFallback: 'Could not load your orders.',
            itemBuilder: (context, order) => SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(order.listingTitle, style: Theme.of(context).textTheme.titleMedium)),
                      const SizedBox(width: 8),
                      StatusPill(label: humanizeStatus(order.status), tone: orderTone(order.status)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(formatInr(order.amount), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 16,
                    runSpacing: 4,
                    children: [
                      Text('Order #${order.id}', style: Theme.of(context).textTheme.bodySmall),
                      Text('Payment: ${humanizeStatus(order.paymentStatus)}', style: Theme.of(context).textTheme.bodySmall),
                      if (order.createdAt != null) Text(formatDate(order.createdAt), style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  if (order.notes != null && order.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text('"${order.notes}"', style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic)),
                  ],
                  if (order.status == 'pending') ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: _cancelling.contains(order.id) ? null : () => _cancel(order),
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.favorite, minimumSize: const Size(0, 40)),
                        child: _cancelling.contains(order.id)
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Cancel request'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
}
