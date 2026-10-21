import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/pages/my_orders_screen.dart' show orderTone;
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/admin_widgets.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';

const _orderStatuses = ['pending', 'confirmed', 'processing', 'completed', 'cancelled', 'rejected'];

/// Orders - `GET /v1/admin/orders`, `PATCH /v1/admin/orders/{id}/status` and
/// cash confirmation through `POST /v1/payments/{id}/confirm-cash`.
class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _service = OrderService();
  String? _status;
  final Set<int> _busy = {};
  late final _paged = PagedController<OrderRecord>(
    limit: 12,
    fetch: (p, l) => _service.listAdminOrders(page: p, limit: l, status: _status),
  )..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  Future<void> _run(OrderRecord o, Future<void> Function() action, String done) async {
    setState(() => _busy.add(o.id));
    try {
      await action();
      if (!mounted) return;
      showAppSnack(context, done);
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(o.id));
    }
  }

  Future<void> _changeStatus(OrderRecord o) async {
    final target = await showDialog<String>(context: context, builder: (_) => _StatusDialog(order: o));
    if (target == null || target == o.status) return;
    await _run(o, () => _service.updateAdminOrderStatus(o.id, target), 'Order #${o.id} is now ${humanizeStatus(target).toLowerCase()}. Buyer and seller were notified.');
  }

  Future<void> _confirmCash(OrderRecord o) async {
    setState(() => _busy.add(o.id));
    final payment = await _service.getOrderPayment(o.id);
    if (!mounted) return;
    setState(() => _busy.remove(o.id));
    if (payment == null || !payment.isCash || !payment.isPending) {
      showAppSnack(context, 'There is no cash payment waiting for confirmation on this order.', error: true);
      return;
    }
    final note = await showReasonDialog(
      context,
      title: 'Confirm cash for order #${o.id}?',
      message: 'Only confirm once ${formatInr(payment.amount)} has been received. This marks the order as paid.',
      label: 'Note',
      required: false,
      confirmLabel: 'Confirm cash received',
    );
    if (note == null) return;
    await _run(o, () => _service.adminConfirmCash(payment.id, notes: note.isEmpty ? null : note), 'Cash payment confirmed for order #${o.id}');
  }

  void _showDetails(OrderRecord o) {
    showDialog<void>(context: context, builder: (_) => _OrderDetails(order: o));
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      section: NavSection.adminOrders,
      title: 'Orders',
      subtitle: 'Purchase requests between buyers and sellers. Step in only when a deal is stuck.',
      onRefresh: _paged.refresh,
      filters: SegmentFilter<String?>(
        options: [(null, 'All'), for (final s in _orderStatuses) (s, humanizeStatus(s))],
        selected: _status,
        onChanged: (v) {
          setState(() => _status = v);
          _paged.reset();
        },
      ),
      child: AdminPagedTable<OrderRecord>(
        controller: _paged,
        itemLabel: 'orders',
        empty: EmptyStateView(
          compact: true,
          icon: Icons.receipt_long_outlined,
          title: _status == null ? 'No orders yet' : 'No ${humanizeStatus(_status!).toLowerCase()} orders',
          message: 'Try another status.',
        ),
        builder: (context, items) => AdminTable<OrderRecord>(
          items: items,
          onTap: _showDetails,
          actionsWidth: 170,
          cardTitle: (o) => Text(o.listingTitle),
          cardBadge: (o) => StatusPill(label: humanizeStatus(o.status), tone: orderTone(o.status)),
          columns: [
            AdminColumn('Car', (o) => StackedCell(o.listingTitle, 'Order #${o.id}  |  ${formatDate(o.createdAt)}'), flex: 5, showInCard: false),
            AdminColumn('Buyer', (o) => TextCell(o.buyer?.displayName ?? 'User #${o.buyerId}'), flex: 3),
            AdminColumn('Seller', (o) => TextCell(o.seller?.displayName ?? 'User #${o.sellerId}'), flex: 3),
            AdminColumn('Amount', (o) => Text(formatLakh(o.amount), style: AppText.figures(14)), flex: 2),
            AdminColumn(
              'Payment',
              (o) => StatusPill(label: humanizeStatus(o.paymentStatus), tone: o.isPaid ? StatusTone.success : StatusTone.warning),
              flex: 2,
            ),
            AdminColumn('Status', (o) => StatusPill(label: humanizeStatus(o.status), tone: orderTone(o.status)), flex: 2, showInCard: false),
          ],
          actions: (o) {
            if (_busy.contains(o.id)) return const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))];
            final open = o.status != 'cancelled' && o.status != 'rejected';
            return [
              RowAction('Status', onPressed: () => _changeStatus(o)),
              PopupMenuButton<String>(
                tooltip: 'More',
                onSelected: (v) {
                  if (v == 'cash') _confirmCash(o);
                  if (v == 'details') _showDetails(o);
                  if (v == 'buyer') Navigator.of(context).pushNamed(AppRoutes.adminUser(o.buyerId));
                  if (v == 'seller') Navigator.of(context).pushNamed(AppRoutes.adminUser(o.sellerId));
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'details', child: Text('Order details')),
                  if (open && !o.isPaid) const PopupMenuItem(value: 'cash', child: Text('Confirm cash payment')),
                  const PopupMenuItem(value: 'buyer', child: Text('View buyer')),
                  const PopupMenuItem(value: 'seller', child: Text('View seller')),
                ],
              ),
            ];
          },
        ),
      ),
    );
  }
}

class _StatusDialog extends StatefulWidget {
  final OrderRecord order;
  const _StatusDialog({required this.order});

  @override
  State<_StatusDialog> createState() => _StatusDialogState();
}

class _StatusDialogState extends State<_StatusDialog> {
  late String _status = widget.order.status;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change order #${widget.order.id}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.order.listingTitle, style: const TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              RadioGroup<String>(
                groupValue: _status,
                onChanged: (v) => setState(() => _status = v ?? _status),
                child: Column(
                  children: [
                    for (final s in _orderStatuses)
                      RadioListTile<String>(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        value: s,
                        title: Text(humanizeStatus(s) + (s == widget.order.status ? ' (current)' : '')),
                      ),
                  ],
                ),
              ),
              if (_status == 'cancelled' && widget.order.status != 'cancelled')
                const Callout(
                  tone: CalloutTone.warning,
                  message: 'Cancelling releases the car so other buyers can order it.',
                ),
              const SizedBox(height: 4),
              const Text('The buyer and the seller are notified of the change.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _status == widget.order.status ? null : () => Navigator.of(context).pop(_status),
          child: const Text('Save status'),
        ),
      ],
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final OrderRecord order;
  const _OrderDetails({required this.order});

  @override
  Widget build(BuildContext context) {
    final o = order;
    Widget row(String l, String v) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 120, child: Text(l, style: const TextStyle(color: AppColors.textSecondary))),
            Expanded(child: Text(v, style: const TextStyle(fontWeight: FontWeight.w500))),
          ]),
        );
    return AlertDialog(
      title: Text('Order #${o.id}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 300, maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              row('Car', o.listingTitle),
              row('Amount', formatInr(o.amount)),
              row('Status', humanizeStatus(o.status)),
              row('Payment', humanizeStatus(o.paymentStatus)),
              row('Buyer', o.buyer == null ? 'User #${o.buyerId}' : '${o.buyer!.displayName} (@${o.buyer!.username})'),
              row('Seller', o.seller == null ? 'User #${o.sellerId}' : '${o.seller!.displayName} (@${o.seller!.username})'),
              row('Placed', formatDateTime(o.createdAt)),
              if (o.updatedAt != null) row('Last change', formatDateTime(o.updatedAt)),
              if (o.completedAt != null) row('Completed', formatDateTime(o.completedAt)),
              if ((o.notes ?? '').isNotEmpty) row('Buyer note', o.notes!),
            ],
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    );
  }
}
