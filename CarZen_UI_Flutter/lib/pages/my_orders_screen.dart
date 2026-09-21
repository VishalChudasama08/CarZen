import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _service = OrderService();
  late Future<List<OrderRecord>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.listMyOrders().then((page) => page.data);
  }

  void _refresh() => setState(() => _future = _service.listMyOrders().then((page) => page.data));

  Future<void> _cancel(OrderRecord order) async {
    try {
      await _service.cancelOrder(order.id);
      _refresh();
    } on ApiException catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CarZenNavBar(current: NavSection.orders, title: 'My Orders'),
        body: ContentWidth(
        maxWidth: 820,
        child: FutureBuilder<List<OrderRecord>>(
          future: _future,
          builder: (_, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const LoadingView(label: 'Loading orders...');
            if (snapshot.hasError) {
              final message = snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Could not load orders.';
              return ErrorStateView(message: message, onRetry: _refresh);
            }
            final orders = snapshot.data!;
            if (orders.isEmpty) return const EmptyStateView(icon: Icons.receipt_long_outlined, title: 'No orders yet', message: 'Orders you place for a car will appear here.');
            return RefreshIndicator(
              onRefresh: () async => _refresh(),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final order = orders[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(order.listingTitle, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('${formatInr(order.amount)} · ${order.status}', style: const TextStyle(color: AppColors.textSecondary)),
                        Text('Payment: ${order.paymentStatus}', style: const TextStyle(color: AppColors.textSecondary)),
                        if (order.createdAt != null) Text(DateFormat.yMMMd().format(order.createdAt!), style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        if (order.status == 'pending') Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => _cancel(order), child: const Text('Cancel request'))),
                      ]),
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
