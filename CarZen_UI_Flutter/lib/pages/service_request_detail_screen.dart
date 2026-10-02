import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/service_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// One service request — `GET /v1/service-requests/{id}` — with progress,
/// the services requested, and Cancel while the backend still allows it.
class ServiceRequestDetailScreen extends StatefulWidget {
  final int requestId;
  const ServiceRequestDetailScreen({super.key, required this.requestId});

  @override
  State<ServiceRequestDetailScreen> createState() => _ServiceRequestDetailScreenState();
}

class _ServiceRequestDetailScreenState extends State<ServiceRequestDetailScreen> {
  final _api = ServiceRequestApi();
  late Future<ServiceRequestRecord> _future;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _future = _api.get(widget.requestId);
  }

  void _reload() => setState(() => _future = _api.get(widget.requestId));

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
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.services, title: 'Service request'),
      body: SafeArea(
        child: FutureBuilder<ServiceRequestRecord>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) return const LoadingView(label: 'Loading request...');
            if (snapshot.hasError) return ApiErrorView(error: snapshot.error!, onRetry: _reload, fallback: 'Could not load this request.');
            final r = snapshot.data!;
            final wide = Breakpoints.isExpanded(context);
            final main = _main(context, r);
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
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(r.title, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.xl),
                      SurfaceCard(padding: const EdgeInsets.all(20), child: RequestProgress(request: r)),
                      const SizedBox(height: AppSpacing.lg),
                      if (wide)
                        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 3, child: main),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: side),
                        ])
                      else ...[main, const SizedBox(height: AppSpacing.lg), side],
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

  Widget _main(BuildContext context, ServiceRequestRecord r) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Services', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
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
          Row(
            children: [
              const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w800))),
              Text(formatInr(r.amount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.primary)),
            ],
          ),
          if (r.paymentStatus.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text('Payment status: ${paymentInfo(r)}', style: Theme.of(context).textTheme.bodySmall),
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
          Text('Appointment', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DetailRow('Date', formatDate(r.scheduledDate), emphasize: true),
          DetailRow('Time', formatClock(r.scheduledTime), emphasize: true),
          if (r.car != null) DetailRow('Car', r.car!.label),
          if (r.notes != null && r.notes!.isNotEmpty) DetailRow('Your notes', r.notes!),
          if (r.adminNote != null && r.adminNote!.isNotEmpty) DetailRow('From CarZen', r.adminNote!),
          if (r.createdAt != null) DetailRow('Requested', formatDateTime(r.createdAt)),
        ],
      ),
    );
  }
}

