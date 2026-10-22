import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:carzen_flutter/config/payment_limits.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/payment/payment_launcher.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/service_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';

/// One service request — `GET /v1/service-requests/{id}` — with progress,
/// services breakdown, payment card, and cancellation.
class ServiceRequestDetailScreen extends StatefulWidget {
  final int requestId;
  final ServiceRequestRecord? initialRequest;
  const ServiceRequestDetailScreen({super.key, required this.requestId, this.initialRequest});

  @override
  State<ServiceRequestDetailScreen> createState() => _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState extends State<ServiceRequestDetailScreen> {
  final _api = ServiceRequestApi();

  late Future<ServiceRequestRecord> _future;
  bool _cancelling = false;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _future = widget.initialRequest != null ? Future.value(widget.initialRequest) : _api.get(widget.requestId);
  }

  void _reload() => setState(() => _future = _api.get(widget.requestId));

  Future<void> _payOnline(ServiceRequestRecord request) async {
    if (_paying) return;

    if (!PaymentLimits.canPayOnline(request.payableAmount)) {
      showAppSnack(context, PaymentLimits.serviceLimitExceededMessage, error: true);
      return;
    }

    setState(() => _paying = true);
    try {
      final payRes = await _api.payOnline(request.id);
      final user = request.user;

      if (!mounted) return;
      final result = await getPaymentLauncher().launchRazorpay(
        context: context,
        keyId: payRes.razorpayKeyId,
        orderId: payRes.razorpayOrderId,
        amountPaise: (payRes.amount * 100).round(),
        name: 'CarZen Service #${request.id}',
        description: request.title,
        prefill: PaymentPrefill(
          name: user?.displayName,
          email: user?.email,
          contact: user?.phoneNumber,
        ),
      );

      if (!mounted) return;

      switch (result) {
        case RazorpaySuccess(:final paymentId, :final orderId, :final signature):
          try {
            final verified = await _api.verifyOnline(
              request.id,
              razorpayOrderId: orderId,
              razorpayPaymentId: paymentId,
              razorpaySignature: signature,
            );
            if (!mounted) return;
            setState(() => _future = Future.value(verified));
            showAppSnack(context, 'Payment successful! Service #${verified.id} is marked as paid.');
          } on ApiException catch (e) {
            if (!mounted) return;
            showAppSnack(
              context,
              'Payment verification failed: ${e.message}. If money was deducted, contact support with reference: $paymentId',
              error: true,
            );
          }
        case RazorpayFailure(:final message):
          showAppSnack(context, 'Payment failed: $message', error: true);
        case RazorpayDismissed():
          // User dismissed checkout dialog: do not treat as error.
          break;
      }
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _payCash(ServiceRequestRecord request) async {
    if (_paying) return;
    setState(() => _paying = true);
    try {
      final updated = await _api.payCash(request.id);
      if (!mounted) return;
      setState(() => _future = Future.value(updated));
      showAppSnack(context, 'Cash payment selected. Please pay at the service center workshop.');
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  Future<void> _cancel(ServiceRequestRecord request) async {
    final reason = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Request #${request.id} for ${request.title} will be cancelled. This cannot be undone.'),
            const SizedBox(height: 14),
            TextField(
              controller: reason,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Reason (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep request')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel request'),
          ),
        ],
      ),
    );
    final note = reason.text;
    reason.dispose();
    if (confirmed != true) return;
    setState(() => _cancelling = true);
    try {
      final updated = await _api.cancel(request.id, notes: note);
      if (!mounted) return;
      showAppSnack(context, 'Request #${updated.id} cancelled.');
      setState(() => _future = Future.value(updated));
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.services,
      title: 'Service booking',
      fallbackRoute: AppRoutes.serviceRequests,
      body: SafeArea(
        child: FutureBuilder<ServiceRequestRecord>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading request...');
            }
            if (snapshot.hasError) {
              return ApiErrorView(
                error: snapshot.error!,
                onRetry: _reload,
                fallback: 'Could not load this request.',
              );
            }
            final r = snapshot.data!;
            final wide = Breakpoints.isExpanded(context);
            final main = _buildBillBreakdownCard(context, r);
            final payment = _buildPaymentCard(context, r);
            final side = _side(context, r);

            return RefreshIndicator(
              onRefresh: () async {
                _reload();
                await _future;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PageContainer(
                  maxWidth: 1000,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Request #${r.id}', style: Theme.of(context).textTheme.headlineMedium),
                          StatusPill(label: r.status.label, tone: r.status.tone),
                          servicePaymentPill(r),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(r.title, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.xl),
                      SurfaceCard(padding: const EdgeInsets.all(20), child: RequestProgress(request: r)),
                      const SizedBox(height: AppSpacing.lg),
                      if (wide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  main,
                                  const SizedBox(height: AppSpacing.lg),
                                  payment,
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(flex: 2, child: side),
                          ],
                        )
                      else ...[
                        main,
                        const SizedBox(height: AppSpacing.lg),
                        payment,
                        const SizedBox(height: AppSpacing.lg),
                        side,
                      ],
                      if (r.status.userCanCancel) ...[
                        const SizedBox(height: AppSpacing.xl),
                        OutlinedButton.icon(
                          onPressed: _cancelling ? null : () => _cancel(r),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.favorite,
                            side: BorderSide(color: AppColors.favorite.withValues(alpha: 0.5)),
                          ),
                          icon: _cancelling
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.cancel_outlined),
                          label: const Text('Cancel this request'),
                        ),
                      ],
                      if (r.status == ServiceRequestStatus.completed && r.car != null) ...[
                        const SizedBox(height: AppSpacing.xl),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.serviceHistory),
                          icon: const Icon(Icons.history_rounded),
                          label: const Text('See service history'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Bill breakdown card: Services (items), Base amount, Parts, Labor, Total payable.
  Widget _buildBillBreakdownCard(BuildContext context, ServiceRequestRecord r) {
    final isCompleted = r.status == ServiceRequestStatus.completed;
    final showParts = (r.partsCost != null && r.partsCost! > 0) || isCompleted;
    final showLabor = (r.laborCost != null && r.laborCost! > 0) || isCompleted;
    final base = r.baseAmount ?? r.amount;

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Text('Bill Breakdown', style: Theme.of(context).textTheme.titleMedium),
              servicePaymentPill(r),
            ],
          ),
          const SizedBox(height: 12),
          if (r.items.isEmpty)
            Text(r.title)
          else
            for (final item in r.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.serviceName, style: const TextStyle(fontWeight: FontWeight.w700)),
                          if (item.durationMinutes != null)
                            Text(formatDuration(item.durationMinutes!), style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(formatInr(item.unitPrice), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          const Divider(height: 24),
          DetailRow('Base amount', formatInr(base)),
          if (showParts) DetailRow('Parts cost', formatInr(r.partsCost ?? 0)),
          if (showLabor) DetailRow('Labor cost', formatInr(r.laborCost ?? 0)),
          const Divider(height: 20),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              const Text('Total payable', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              Text(
                formatInr(r.payableAmount),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (!isCompleted && r.status != ServiceRequestStatus.cancelled && r.status != ServiceRequestStatus.rejected) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textSecondary),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Final amount may change after service (parts and labor are added upon completion). You can pay in advance or after service completion.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Payment card driven by state machine.
  Widget _buildPaymentCard(BuildContext context, ServiceRequestRecord r) {
    if (r.status == ServiceRequestStatus.cancelled || r.status == ServiceRequestStatus.rejected) {
      return const SizedBox.shrink();
    }

    final isPaid = r.paymentStatus.toLowerCase() == 'paid';
    final method = r.paymentMethod?.toLowerCase();
    final canOnline = PaymentLimits.canPayOnline(r.payableAmount);

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Payment', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (isPaid) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: const Color(0xFF81C784)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF2E7D32), size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Paid  |  ${method == 'online' ? 'Online (Razorpay)' : 'Cash at Workshop'}',
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1B5E20), fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Paid amount: ${formatInr(r.payableAmount)}',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF2E7D32)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else if (method == 'cash') ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.payments_outlined, color: AppColors.secondary, size: 22),
                      SizedBox(width: 8),
                      Expanded(child: Text('Cash Payment Pending', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5))),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pay ${formatInr(r.payableAmount)} at the workshop counter. CarZen admin will confirm once collected.',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (canOnline)
              OutlinedButton.icon(
                onPressed: _paying ? null : () => _payOnline(r),
                icon: const Icon(Icons.credit_card_rounded),
                label: const Text('Switch to online payment'),
              )
            else
              Text(
                PaymentLimits.serviceLimitExceededMessage,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ] else ...[
            // No method chosen or retry online
            if (!canOnline)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  PaymentLimits.serviceLimitExceededMessage,
                  style: const TextStyle(fontSize: 13, color: AppColors.favorite, fontWeight: FontWeight.w500),
                ),
              ),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                FilledButton.icon(
                  onPressed: (_paying || !canOnline) ? null : () => _payOnline(r),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size(160, 46),
                  ),
                  icon: _paying
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.bolt_rounded),
                  label: Text('Pay online (${formatInr(r.payableAmount)})'),
                ),
                OutlinedButton.icon(
                  onPressed: _paying ? null : () => _payCash(r),
                  style: OutlinedButton.styleFrom(minimumSize: const Size(160, 46)),
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Pay cash at workshop'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _side(BuildContext context, ServiceRequestRecord r) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Appointment Details', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DetailRow('Requested date', formatDate(r.scheduledDate), emphasize: true),
          DetailRow('Requested time', formatClock(r.scheduledTime), emphasize: true),
          if (r.car != null) DetailRow('Car', r.car!.label),
          if (r.notes != null && r.notes!.isNotEmpty) DetailRow('Your notes', r.notes!),
          if (r.adminNote != null && r.adminNote!.isNotEmpty) DetailRow('From CarZen', r.adminNote!),
          if (r.createdAt != null) DetailRow('Created on', formatDateTime(r.createdAt)),
        ],
      ),
    );
  }
}
