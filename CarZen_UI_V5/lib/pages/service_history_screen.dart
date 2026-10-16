import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/service_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// Completed work on the user's cars — `GET /v1/services/history` (paginated).
class ServiceHistoryScreen extends StatefulWidget {
  const ServiceHistoryScreen({super.key});

  @override
  State<ServiceHistoryScreen> createState() => _ServiceHistoryScreenState();
}

class _ServiceHistoryScreenState extends State<ServiceHistoryScreen> {
  final _api = ServiceRequestApi();
  late final PagedController<ServiceRecord> _paged;

  @override
  void initState() {
    super.initState();
    _paged = PagedController<ServiceRecord>(limit: 8, fetch: (page, limit) => _api.history(page: page, limit: limit))..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.services, title: 'Service history'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.services),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _paged.refresh,
          child: AnimatedBuilder(
            animation: _paged,
            builder: (context, _) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: PageContainer(
                maxWidth: 900,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const PageHeader(
                      title: 'Services',
                      subtitle: 'A record of the work done on your cars.',
                      icon: Icons.home_repair_service_rounded,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const ServiceTabs(current: ServicesTab.history),
                    const SizedBox(height: AppSpacing.lg),
                    if (_paged.loading && _paged.hasData) const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator(minHeight: 3)),
                    _body(),
                    const SizedBox(height: AppSpacing.xl),
                    PaginationBar(meta: _paged.meta, busy: _paged.loading, itemLabel: 'records', onPageChanged: _paged.goTo),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _body() {
    if (_paged.isFirstLoad) {
      return Column(children: [
        for (var i = 0; i < 3; i++)
          const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 110, radius: AppRadii.lg)),
      ]);
    }
    if (_paged.error != null && !_paged.hasData) {
      return SizedBox(height: 360, child: ApiErrorView(error: _paged.error!, onRetry: _paged.refresh, fallback: 'Could not load service history.'));
    }
    if (!_paged.hasData) {
      return SizedBox(
        height: 360,
        child: EmptyStateView(
          icon: Icons.history_rounded,
          title: 'No service history yet',
          message: 'Once a service on one of your cars is completed, the details will appear here.',
          action: FilledButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.services), child: const Text('Browse services')),
        ),
      );
    }
    return Column(
      children: [
        for (final record in _paged.items)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: _RecordCard(record: record)),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final ServiceRecord record;
  const _RecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final r = record;
    final status = r.status;
    return SurfaceCard(
      padding: EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          shape: const Border(),
          collapsedShape: const Border(),
          title: Text(r.serviceType, style: Theme.of(context).textTheme.titleMedium),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              [formatDate(r.serviceDate), if (r.car != null) r.car!.label].join(' · '),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          trailing: status == null
              ? null
              : StatusPill(
                  label: humanizeStatus(status),
                  tone: status == 'completed' ? StatusTone.success : (status == 'cancelled' ? StatusTone.neutral : StatusTone.info),
                ),
          children: [
            if (r.description != null && r.description!.isNotEmpty) DetailRow('Notes', r.description!),
            if (r.odometerReading != null) DetailRow('Odometer', formatKm(r.odometerReading!)),
            if (r.partsCost != null) DetailRow('Parts', formatInr(r.partsCost!)),
            if (r.laborCost != null) DetailRow('Labour', formatInr(r.laborCost!)),
            if (r.serviceCost != null) DetailRow('Total cost', formatInr(r.serviceCost!), emphasize: true),
            if (r.nextServiceDate != null) DetailRow('Next service', formatDate(r.nextServiceDate)),
            if (r.nextServiceMileage != null) DetailRow('Next at', formatKm(r.nextServiceMileage!)),
            if (r.items.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text('Work done', style: TextStyle(fontWeight: FontWeight.w800)),
              for (final item in r.items)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Expanded(child: Text(item.quantity != null && item.quantity! > 1 ? '${item.itemName} × ${item.quantity}' : item.itemName)),
                      if (item.totalPrice != null) Text(formatInr(item.totalPrice!), style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
