import 'package:flutter/material.dart';
import 'package:carzen_flutter/config/payment_limits.dart';
import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/services/payment/payment_launcher.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';

/// Tone for an order status string from the backend.
StatusTone orderTone(String status) => switch (status.toLowerCase()) {
      'completed' => StatusTone.success,
      'confirmed' || 'processing' => StatusTone.info,
      'cancelled' => StatusTone.neutral,
      'rejected' => StatusTone.danger,
      _ => StatusTone.warning,
    };

/// Tone for payment status string.
StatusTone paymentTone(String paymentStatus) => switch (paymentStatus.toLowerCase()) {
      'paid' || 'success' => StatusTone.success,
      'pending' || 'processing' => StatusTone.warning,
      'failed' => StatusTone.danger,
      _ => StatusTone.neutral,
    };

/// The buyer's purchase requests — `GET /v1/buyer/orders` (paginated).
/// Supports order cancellation and order payment (online up to ₹50k, cash/transfer above).
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _service = OrderService();
  late final PagedController<OrderRecord> _paged;

  final Set<int> _cancelling = {};
  final Set<int> _paying = {};

  @override
  void initState() {
    super.initState();
    _paged = PagedController<OrderRecord>(
      limit: 8,
      fetch: (page, limit) => _service.listMyOrders(page: page, limit: limit),
    )..load();
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

  Future<void> _payOnline(OrderRecord order) async {
    if (_paying.contains(order.id)) return;

    if (!PaymentLimits.canPayOnline(order.amount)) {
      showAppSnack(context, PaymentLimits.carOrderLimitExceededMessage, error: true);
      return;
    }

    setState(() => _paying.add(order.id));
    try {
      final payment = await _service.createCarPayment(orderId: order.id, paymentMethod: 'online');

      if (!mounted) return;
      final result = await getPaymentLauncher().launchRazorpay(
        context: context,
        keyId: payment.razorpayKeyId ?? '',
        orderId: payment.razorpayOrderId ?? '',
        amountPaise: (payment.amount * 100).round(),
        name: 'Car Purchase Order #${order.id}',
        description: order.listingTitle,
        prefill: const PaymentPrefill(),
      );

      if (!mounted) return;

      switch (result) {
        case RazorpaySuccess(:final paymentId, :final orderId, :final signature):
          try {
            await _service.verifyCarPayment(
              payment.id,
              razorpayOrderId: orderId,
              razorpayPaymentId: paymentId,
              razorpaySignature: signature,
            );
            if (!mounted) return;
            showAppSnack(context, 'Payment successful! Order #${order.id} is marked as paid.');
            await _paged.refresh();
          } on ApiException catch (e) {
            if (!mounted) return;
            showAppSnack(
              context,
              'Verification failed: ${e.message}. If money was deducted, contact support with reference: $paymentId',
              error: true,
            );
          }
        case RazorpayFailure(:final message):
          showAppSnack(context, 'Payment failed: $message', error: true);
        case RazorpayDismissed():
          break;
      }
    } on ApiException catch (e) {
      if (mounted) {
        final msg = e.statusCode == 422
            ? PaymentLimits.carOrderLimitExceededMessage
            : e.message;
        showAppSnack(context, msg, error: true);
      }
    } finally {
      if (mounted) setState(() => _paying.remove(order.id));
    }
  }

  Future<void> _payCash(OrderRecord order) async {
    if (_paying.contains(order.id)) return;
    setState(() => _paying.add(order.id));
    try {
      await _service.createCarPayment(orderId: order.id, paymentMethod: 'cash');
      if (!mounted) return;
      showAppSnack(context, 'Cash payment selected for Order #${order.id}. Please arrange handover with seller.');
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _paying.remove(order.id));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CarZenNavBar(
          current: NavSection.orders,
          title: 'My Orders',
          fallbackRoute: AppRoutes.browse,
        ),
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
            itemBuilder: (context, order) {
              final isPaid = order.paymentStatus.toLowerCase() == 'paid';
              final isPayable = (order.status == 'confirmed' || order.status == 'processing') && !isPaid;
              final canOnline = PaymentLimits.canPayOnline(order.amount);
              final isBusy = _paying.contains(order.id);

              return SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(order.listingTitle, style: Theme.of(context).textTheme.titleMedium)),
                        const SizedBox(width: 8),
                        StatusPill(label: humanizeStatus(order.status), tone: orderTone(order.status)),
                        const SizedBox(width: 6),
                        StatusPill(
                          label: isPaid ? 'Paid' : (isPayable ? 'Payment due' : humanizeStatus(order.paymentStatus)),
                          tone: isPaid ? StatusTone.success : (isPayable ? StatusTone.warning : paymentTone(order.paymentStatus)),
                        ),
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
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Awaiting seller acceptance before payment.',
                            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                          OutlinedButton(
                            onPressed: _cancelling.contains(order.id) ? null : () => _cancel(order),
                            style: OutlinedButton.styleFrom(foregroundColor: AppColors.favorite, minimumSize: const Size(0, 36)),
                            child: _cancelling.contains(order.id)
                                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Text('Cancel request'),
                          ),
                        ],
                      ),
                    ],
                    if (isPayable) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      if (!canOnline) ...[
                        Text(
                          PaymentLimits.carOrderLimitExceededMessage,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        FilledButton.icon(
                          onPressed: isBusy ? null : () => _payCash(order),
                          icon: isBusy
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.handshake_outlined),
                          label: const Text('Select Cash / Handover Payment'),
                        ),
                      ] else ...[
                        Wrap(
                          spacing: 10,
                          runSpacing: 8,
                          children: [
                            FilledButton.icon(
                              onPressed: isBusy ? null : () => _payOnline(order),
                              icon: isBusy
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.bolt_rounded),
                              label: Text('Pay online (${formatInr(order.amount)})'),
                            ),
                            OutlinedButton.icon(
                              onPressed: isBusy ? null : () => _payCash(order),
                              icon: const Icon(Icons.payments_outlined),
                              label: const Text('Pay Cash / Handover'),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      );
}
