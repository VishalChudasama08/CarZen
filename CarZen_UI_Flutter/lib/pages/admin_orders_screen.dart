import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/pages/my_orders_screen.dart' show orderTone;
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

/// Admin view for the backend's real `/v1/admin/orders` workflow
/// (paginated, filterable by status).
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  static const _statuses = ['pending', 'confirmed', 'processing', 'completed', 'cancelled', 'rejected'];
  final _service = OrderService();
  late final PagedController<OrderRecord> _paged;
  String? _status;

  @override
  void initState() {
    super.initState();
    _paged = PagedController<OrderRecord>(
      limit: 10,
      fetch: (page, limit) => _service.listAdminOrders(page: page, limit: limit, status: _status),
    )..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _setStatus(String? status) {
    _status = status;
    _paged.reset();
  }

  Future<void> _changeStatus(OrderRecord order) async {
    var selected = order.status;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Order #${order.id}'),
          content: DropdownButtonFormField<String>(
            value: selected,
            decoration: const InputDecoration(labelText: 'Status'),
            items: _statuses.map((value) => DropdownMenuItem(value: value, child: Text(humanizeStatus(value)))).toList(),
            onChanged: (value) => setDialogState(() => selected = value ?? selected),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Update')),
          ],
        ),
      ),
    );
    if (confirmed != true || selected == order.status) return;
    try {
      await _service.updateAdminOrderStatus(order.id, selected);
      if (!mounted) return;
      showAppSnack(context, 'Order #${order.id} is now ${humanizeStatus(selected).toLowerCase()}.');
      await _paged.refresh();
    } on ApiException catch (error) {
      if (mounted) showAppSnack(context, error.message, error: true);
    }
  }

  Widget _chip(String label, String? value) {
    final on = _status == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: on,
        showCheckmark: false,
        selectedColor: AppColors.cyanTint,
        side: BorderSide(color: on ? AppColors.secondary : AppColors.divider),
        labelStyle: TextStyle(fontWeight: FontWeight.w700, color: on ? AppColors.secondary : AppColors.textPrimary),
        onSelected: (_) => _setStatus(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CarZenNavBar(current: NavSection.adminOrders, title: 'Orders'),
        bottomNavigationBar: const CarZenBottomBar(current: NavSection.adminOrders),
        body: SafeArea(
          bottom: false,
          child: PagedListView<OrderRecord>(
            controller: _paged,
            maxWidth: 1000,
            itemLabel: 'orders',
            header: AnimatedBuilder(
              animation: _paged,
              builder: (context, _) => PageHeader(
                title: 'Orders',
                subtitle: _paged.meta == null
                    ? 'Purchase requests from buyers.'
                    : '${formatCount(_paged.meta!.total)} order${_paged.meta!.total == 1 ? '' : 's'}${_status == null ? '' : ' with status ${_status!}'}.',
                icon: Icons.local_shipping_rounded,
              ),
            ),
            filters: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [_chip('All', null), for (final s in _statuses) _chip(humanizeStatus(s), s)]),
            ),
            empty: EmptyStateView(
              icon: Icons.receipt_long_outlined,
              title: _status == null ? 'No orders' : 'No ${_status!} orders',
              message: _status == null ? 'No orders are available to manage.' : 'Try another status.',
              action: _status == null ? null : OutlinedButton(onPressed: () => _setStatus(null), child: const Text('Show all')),
            ),
            errorFallback: 'Could not load orders.',
            itemBuilder: (context, order) => SurfaceCard(
              onTap: () => _changeStatus(order),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.cyanTint, borderRadius: BorderRadius.circular(AppRadii.md)),
                    child: const Icon(Icons.receipt_long_rounded, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.listingTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${order.id} · ${formatInr(order.amount)} · Payment: ${humanizeStatus(order.paymentStatus)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusPill(label: humanizeStatus(order.status), tone: orderTone(order.status)),
                  IconButton(tooltip: 'Change status', icon: const Icon(Icons.edit_outlined), onPressed: () => _changeStatus(order)),
                ],
              ),
            ),
          ),
        ),
      );
}
