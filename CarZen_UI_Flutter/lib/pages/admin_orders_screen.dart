import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Admin view for the backend's real `/v1/admin/orders` workflow.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  static const _statuses = ['pending', 'confirmed', 'processing', 'completed', 'cancelled', 'rejected'];
  final _service = OrderService();
  late Future<List<OrderRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listAdminOrders().then((page) => page.data);
  }

  void _refresh() => setState(() => _future = _service.listAdminOrders().then((page) => page.data));

  Future<void> _changeStatus(OrderRecord order) async {
    var selected = order.status;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Order #${order.id}'),
          content: DropdownButtonFormField<String>(
            initialValue: selected,
            decoration: const InputDecoration(labelText: 'Status'),
            items: _statuses.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: (value) => setDialogState(() => selected = value!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Update')),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      await _service.updateAdminOrderStatus(order.id, selected);
      _refresh();
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CarZenNavBar(current: NavSection.adminOrders, title: 'Orders'),
        body: ContentWidth(
        maxWidth: 1000,
        child: FutureBuilder<List<OrderRecord>>(
          future: _future,
          builder: (_, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const LoadingView(label: 'Loading orders...');
            if (snapshot.hasError) {
              final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Could not load orders.';
              return ErrorStateView(message: message, onRetry: _refresh);
            }
            final orders = snapshot.data!;
            if (orders.isEmpty) return const EmptyStateView(title: 'No orders', message: 'No orders are available to manage.');
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, index) {
                  final order = orders[index];
                  return Card(
                    child: ListTile(
                      title: Text(order.listingTitle),
                      subtitle: Text('${formatInr(order.amount)} · ${order.status}\nPayment: ${order.paymentStatus}'),
                      isThreeLine: true,
                      trailing: IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => _changeStatus(order)),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      );
}
