import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/config/payment_limits.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/services/payment/payment_launcher.dart';
import 'package:carzen_flutter/services/review_service.dart';
import 'package:carzen_flutter/services/seller_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/listing_dialogs.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

StatusTone orderTone(String status) => switch (status.toLowerCase()) {
      'completed' => StatusTone.success,
      'confirmed' || 'processing' => StatusTone.info,
      'cancelled' => StatusTone.neutral,
      'rejected' => StatusTone.danger,
      _ => StatusTone.warning,
    };

StatusTone paymentTone(String paymentStatus) => switch (paymentStatus.toLowerCase()) {
      'paid' || 'success' => StatusTone.success,
      'pending' || 'processing' || 'partial' => StatusTone.warning,
      'failed' => StatusTone.danger,
      _ => StatusTone.neutral,
    };

String orderStatusLabel(String status, {bool seller = false}) => switch (status) {
      'pending' => seller ? 'Needs your reply' : 'Waiting for seller',
      'confirmed' => 'Accepted',
      'processing' => 'Handover in progress',
      'completed' => 'Completed',
      'cancelled' => 'Cancelled',
      'rejected' => 'Declined',
      _ => humanizeStatus(status),
    };

enum OrdersTab { buying, selling }

/// An order with its payment (when one has been started).
class OrderWithPayment {
  final OrderRecord order;
  final CarPaymentRecord? payment;
  const OrderWithPayment(this.order, this.payment);
}

/// Purchase requests in both directions: cars you asked to buy, and
/// requests for your cars. Every step of the sale happens here.
class MyOrdersScreen extends StatefulWidget {
  final OrdersTab initialTab;
  const MyOrdersScreen({super.key, this.initialTab = OrdersTab.buying});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  final _orders = OrderService();
  final _seller = SellerService();
  final _reviews = ReviewService();

  late OrdersTab _tab = widget.initialTab;
  String? _status;
  late PagedController<OrderWithPayment> _paged = _controller();
  final Set<int> _busy = {};

  PagedController<OrderWithPayment> _controller() => PagedController<OrderWithPayment>(limit: 8, fetch: _fetch)..load();

  Future<PaginatedList<OrderWithPayment>> _fetch(int page, int limit) async {
    final result = _tab == OrdersTab.buying
        ? await _orders.listMyOrders(page: page, limit: limit, status: _status)
        : await _seller.orders(page: page, limit: limit, status: _status);
    final items = await Future.wait(result.data.map((o) async {
      final needsPayment = o.status == 'confirmed' || o.status == 'processing' || o.status == 'completed';
      return OrderWithPayment(o, needsPayment ? await _orders.getOrderPayment(o.id) : null);
    }));
    return PaginatedList(data: items, pagination: result.pagination);
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _reset() {
    final old = _paged;
    setState(() => _paged = _controller());
    old.dispose();
  }

  void _setTab(OrdersTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    _status = null;
    _reset();
    SystemNavigator.routeInformationUpdated(uri: Uri(path: tab == OrdersTab.selling ? AppRoutes.sales : AppRoutes.orders), replace: true);
  }

  Future<void> _act(OrderRecord o, Future<void> Function() action, String done) async {
    if (_busy.contains(o.id)) return;
    setState(() => _busy.add(o.id));
    try {
      await action();
      if (mounted) showAppSnack(context, done);
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(o.id));
    }
  }

  // ---- Buyer actions ----

  Future<void> _cancel(OrderRecord o) async {
    final ok = await confirmAction(
      context,
      title: 'Cancel this request?',
      message: 'The seller will be told you are no longer interested in ${o.listingTitle}.',
      confirmLabel: 'Cancel request',
      cancelLabel: 'Keep it',
      destructive: true,
    );
    if (ok) _act(o, () => _orders.cancelOrder(o.id), 'Request cancelled');
  }

  Future<void> _payCash(OrderRecord o) async {
    final ok = await confirmAction(
      context,
      title: 'Pay in cash at handover?',
      message: 'You pay ${formatInr(o.amount)} to the seller when you collect the car. The seller confirms they received it, and the order is marked paid.',
      confirmLabel: 'Choose cash',
    );
    if (ok) _act(o, () => _orders.createCarPayment(orderId: o.id, cash: true), 'Cash payment chosen. Arrange the handover with the seller.');
  }

  Future<void> _payOnline(OrderRecord o) async {
    if (_busy.contains(o.id)) return;
    setState(() => _busy.add(o.id));
    try {
      final payment = await _orders.createCarPayment(orderId: o.id);
      if (!mounted) return;
      final user = SessionController.instance.user;
      final result = await getPaymentLauncher().launchRazorpay(
        context: context,
        keyId: payment.razorpayKeyId ?? '',
        orderId: payment.razorpayOrderId ?? '',
        amountPaise: (payment.amount * 100).round(),
        name: 'CarZen order #${o.id}',
        description: o.listingTitle,
        prefill: PaymentPrefill(name: user?.fullName, email: user?.email, contact: user?.phoneNumber),
      );
      if (!mounted) return;
      switch (result) {
        case RazorpaySuccess(:final paymentId, :final orderId, :final signature):
          try {
            await _orders.verifyCarPayment(payment.id, razorpayOrderId: orderId, razorpayPaymentId: paymentId, razorpaySignature: signature);
            if (mounted) showAppSnack(context, 'Payment received. The seller will complete the handover.');
          } on ApiException catch (e) {
            if (mounted) {
              showAppSnack(context, 'We could not confirm the payment: ${e.message}. If money was taken, keep this reference: $paymentId', error: true);
            }
          }
        case RazorpayFailure(:final message):
          showAppSnack(context, 'Payment did not go through: $message', error: true);
        case RazorpayDismissed():
          break;
      }
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(o.id));
    }
  }

  Future<void> _review(OrderRecord o) async {
    final car = o.car;
    final name = car == null ? o.listingTitle : '${car.brandName} ${car.modelName}';
    final r = await showReviewDialog(context, carName: name);
    if (r == null) return;
    _act(o, () => _reviews.create(carId: o.carId, rating: r.rating, title: r.title, text: r.text), 'Thanks for your review');
  }

  // ---- Seller actions ----

  Future<void> _accept(OrderRecord o) async {
    final ok = await confirmAction(
      context,
      title: 'Accept this request?',
      message: 'Your car will be reserved for ${o.buyer?.displayName ?? 'this buyer'} and hidden from other buyers\' requests. You can still cancel if the sale falls through.',
      confirmLabel: 'Accept',
    );
    if (ok) _act(o, () => _seller.acceptOrder(o.id), 'Accepted. The buyer can now pay.');
  }

  Future<void> _decline(OrderRecord o) async {
    final ok = await confirmAction(context, title: 'Decline this request?', message: 'The buyer will be told you declined.', confirmLabel: 'Decline', destructive: true);
    if (ok) _act(o, () => _seller.rejectOrder(o.id), 'Request declined');
  }

  Future<void> _confirmCash(OrderRecord o, CarPaymentRecord p) async {
    final ok = await confirmAction(
      context,
      title: 'Confirm cash received?',
      message: 'Only confirm once you have received ${formatInr(p.amount)} from the buyer. The order will be marked paid.',
      confirmLabel: 'I received the cash',
    );
    if (ok) _act(o, () => _orders.confirmCash(p.id), 'Payment recorded');
  }

  Future<void> _complete(OrderRecord o) async {
    final ok = await confirmAction(
      context,
      title: 'Complete the sale?',
      message: 'Mark this car as handed over. The listing will show as sold.',
      confirmLabel: 'Complete sale',
    );
    if (ok) _act(o, () => _seller.setOrderStatus(o.id, 'completed'), 'Sale completed');
  }

  Future<void> _sellerCancel(OrderRecord o) async {
    final ok = await confirmAction(
      context,
      title: 'Cancel this sale?',
      message: 'The reservation is released and your listing becomes available to other buyers again.',
      confirmLabel: 'Cancel sale',
      cancelLabel: 'Keep it',
      destructive: true,
    );
    if (ok) _act(o, () => _seller.setOrderStatus(o.id, 'cancelled'), 'Sale cancelled');
  }

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    final selling = _tab == OrdersTab.selling;
    return AppScaffold(
      section: NavSection.orders,
      title: 'Orders',
      showBottomNav: true,
      body: RefreshIndicator(
        onRefresh: _paged.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: PageContainer(
            maxWidth: 900,
            verticalPadding: compact ? 18 : 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const PageHeader(title: 'Orders', subtitle: 'Purchase requests you sent and the ones buyers sent you.'),
                const SizedBox(height: 20),
                SegmentedButton<OrdersTab>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(value: OrdersTab.buying, label: Text('Buying'), icon: Icon(Icons.shopping_bag_outlined, size: 18)),
                    ButtonSegment(value: OrdersTab.selling, label: Text('Selling'), icon: Icon(Icons.sell_outlined, size: 18)),
                  ],
                  selected: {_tab},
                  onSelectionChanged: (s) => _setTab(s.first),
                ),
                const SizedBox(height: 14),
                SegmentFilter<String?>(
                  options: [
                    (null, 'All'),
                    ('pending', selling ? 'Needs reply' : 'Waiting'),
                    ('confirmed', 'Accepted'),
                    ('completed', 'Completed'),
                    ('cancelled', 'Cancelled'),
                    ('rejected', 'Declined'),
                  ],
                  selected: _status,
                  onChanged: (s) {
                    _status = s;
                    _reset();
                  },
                ),
                const SizedBox(height: 16),
                PagedBody<OrderWithPayment>(
                  controller: _paged,
                  itemLabel: 'orders',
                  skeletonHeight: 150,
                  errorFallback: 'Your orders could not be loaded.',
                  empty: EmptyStateView(
                    compact: true,
                    icon: Icons.receipt_long_outlined,
                    title: selling ? 'No requests for your cars yet' : 'No purchase requests yet',
                    message: selling
                        ? 'When a buyer asks to buy one of your cars, you accept or decline it here.'
                        : 'Found a car you like? Send a purchase request from its page. It costs nothing until the seller accepts.',
                    action: FilledButton(
                      onPressed: () => Navigator.of(context).pushNamed(selling ? AppRoutes.sell : AppRoutes.browse),
                      child: Text(selling ? 'Go to your cars' : 'Browse cars'),
                    ),
                  ),
                  itemBuilder: (context, item) => _OrderCard(
                    item: item,
                    selling: selling,
                    busy: _busy.contains(item.order.id),
                    onCancel: () => _cancel(item.order),
                    onPayOnline: () => _payOnline(item.order),
                    onPayCash: () => _payCash(item.order),
                    onReview: () => _review(item.order),
                    onAccept: () => _accept(item.order),
                    onDecline: () => _decline(item.order),
                    onConfirmCash: item.payment == null ? null : () => _confirmCash(item.order, item.payment!),
                    onComplete: () => _complete(item.order),
                    onSellerCancel: () => _sellerCancel(item.order),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderWithPayment item;
  final bool selling;
  final bool busy;
  final VoidCallback onCancel;
  final VoidCallback onPayOnline;
  final VoidCallback onPayCash;
  final VoidCallback onReview;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onConfirmCash;
  final VoidCallback onComplete;
  final VoidCallback onSellerCancel;

  const _OrderCard({
    required this.item,
    required this.selling,
    required this.busy,
    required this.onCancel,
    required this.onPayOnline,
    required this.onPayCash,
    required this.onReview,
    required this.onAccept,
    required this.onDecline,
    required this.onConfirmCash,
    required this.onComplete,
    required this.onSellerCancel,
  });

  @override
  Widget build(BuildContext context) {
    final o = item.order;
    final p = item.payment;
    final car = o.car;
    final compact = Breakpoints.isCompact(context);
    final cover = car?.media.cover?.thumbnailAbsoluteUrl(ApiConfig.baseUrl);
    final other = selling ? o.buyer : o.seller;

    final (String? note, CalloutTone tone) = _guidance(o, p);
    final actions = _actions(o, p);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: SizedBox(width: compact ? 88 : 120, height: compact ? 72 : 88, child: NetworkPhoto(url: cover, cacheWidth: 260)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(o.listingTitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                    const SizedBox(height: 4),
                    Text(
                      [
                        'Order #${o.id}',
                        formatDate(o.createdAt),
                        if (other != null) (selling ? 'Buyer: ' : 'Seller: ') + other.displayName,
                      ].join('  |  '),
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(formatInr(o.amount), style: AppText.price(17)),
                        StatusPill(label: orderStatusLabel(o.status, seller: selling), tone: orderTone(o.status)),
                        if (o.isPaid)
                          const StatusPill(label: 'Paid', tone: StatusTone.success, icon: Icons.check)
                        else if (p != null && p.isCash && p.isPending)
                          const StatusPill(label: 'Cash at handover', tone: StatusTone.warning)
                        else if (o.canPay)
                          const StatusPill(label: 'Payment due', tone: StatusTone.warning),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((o.notes ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${selling ? 'Buyer\'s note' : 'Your note'}: ${o.notes}',
              style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: 12),
            Callout(message: note, tone: tone, icon: tone == CalloutTone.warning ? Icons.schedule : Icons.info_outline),
          ],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 12),
            busy ? const LinearProgressIndicator() : Wrap(spacing: 10, runSpacing: 10, children: actions),
          ],
        ],
      ),
    );
  }

  (String?, CalloutTone) _guidance(OrderRecord o, CarPaymentRecord? p) {
    if (selling) {
      return switch (o.status) {
        'pending' => ('Accept to reserve the car for this buyer, or decline.', CalloutTone.info),
        'confirmed' || 'processing' when o.isPaid => ('Paid. Hand over the car and complete the sale.', CalloutTone.success),
        'confirmed' || 'processing' when p != null && p.isCash => ('The buyer will pay cash at handover. Confirm once you receive it.', CalloutTone.warning),
        'confirmed' || 'processing' => ('Waiting for the buyer to pay.', CalloutTone.info),
        _ => (null, CalloutTone.info),
      };
    }
    return switch (o.status) {
      'pending' => ('The seller has your request. You\'ll be notified when they reply.', CalloutTone.info),
      'confirmed' || 'processing' when o.isPaid => ('Paid. The seller will complete the handover.', CalloutTone.success),
      'confirmed' || 'processing' when p != null && p.isCash && p.isPending =>
        ('Pay ${formatInr(o.amount)} in cash when you collect the car. The seller confirms receipt.', CalloutTone.warning),
      'confirmed' || 'processing' when p != null && !p.isCash && p.isPending =>
        ('An online payment was started. It updates here once the payment provider confirms it. If you closed checkout without paying, contact CarZen support to restart it.', CalloutTone.warning),
      'confirmed' || 'processing' => ('The seller accepted. Pay to complete your purchase.', CalloutTone.success),
      _ => (null, CalloutTone.info),
    };
  }

  List<Widget> _actions(OrderRecord o, CarPaymentRecord? p) {
    final actions = <Widget>[];
    if (selling) {
      if (o.status == 'pending') {
        actions.add(FilledButton(onPressed: onAccept, child: const Text('Accept')));
        actions.add(OutlinedButton(onPressed: onDecline, child: const Text('Decline')));
      } else if (o.status == 'confirmed' || o.status == 'processing') {
        if (!o.isPaid && p != null && p.isCash && p.isPending && onConfirmCash != null) {
          actions.add(FilledButton(onPressed: onConfirmCash, child: const Text('Confirm cash received')));
        }
        if (o.isPaid) actions.add(FilledButton(onPressed: onComplete, child: const Text('Complete sale')));
        if (!o.isPaid) {
          actions.add(TextButton(onPressed: onSellerCancel, style: TextButton.styleFrom(foregroundColor: AppColors.danger), child: const Text('Cancel sale')));
        }
      }
    } else {
      if (o.status == 'pending') {
        actions.add(OutlinedButton(onPressed: onCancel, child: const Text('Cancel request')));
      } else if (o.canPay && (p == null || !p.isPending)) {
        final online = PaymentLimits.canPayOnline(o.amount);
        if (online) actions.add(ElevatedButton(onPressed: onPayOnline, child: const Text('Pay online')));
        actions.add(online
            ? OutlinedButton(onPressed: onPayCash, child: const Text('Pay cash at handover'))
            : FilledButton(onPressed: onPayCash, child: const Text('Pay cash at handover')));
        if (!online) {
          actions.add(const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('Online payment is available up to ₹50,000.', style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          ));
        }
      } else if (o.status == 'completed') {
        actions.add(OutlinedButton.icon(onPressed: onReview, icon: const Icon(Icons.star_outline, size: 18), label: const Text('Review this purchase')));
      }
      if (o.status == 'confirmed' && !o.isPaid && (p == null || !p.isPending)) {
        actions.add(TextButton(onPressed: onCancel, style: TextButton.styleFrom(foregroundColor: AppColors.danger), child: const Text('Cancel')));
      }
    }
    return actions;
  }
}
