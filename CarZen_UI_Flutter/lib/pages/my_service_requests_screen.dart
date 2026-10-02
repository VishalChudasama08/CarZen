import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/service_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// The signed-in user's service requests — `GET /v1/service-requests`
/// (paginated, filterable by status). Wrap with `RequireAuth(userOnly: true)`.
class MyServiceRequestsScreen extends StatefulWidget {
  const MyServiceRequestsScreen({super.key});

  @override
  State<MyServiceRequestsScreen> createState() => _MyServiceRequestsScreenState();
}

class _MyServiceRequestsScreenState extends State<MyServiceRequestsScreen> {
  final _api = ServiceRequestApi();
  late final PagedController<ServiceRequestRecord> _paged;
  ServiceRequestStatus? _status;

  @override
  void initState() {
    super.initState();
    _paged = PagedController<ServiceRequestRecord>(
      limit: 8,
      fetch: (page, limit) => _api.list(page: page, limit: limit, status: _status),
    )..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _setStatus(ServiceRequestStatus? status) {
    _status = status;
    _paged.reset();
  }

  Future<void> _open(ServiceRequestRecord request) async {
    await Navigator.of(context).pushNamed(AppRoutes.serviceRequest(request.id));
    if (mounted) _paged.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.services, title: 'My service requests'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.services),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.serviceBook),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New request'),
      ),
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
                      subtitle: 'Track your bookings, or look back at work done on your cars.',
                      icon: Icons.home_repair_service_rounded,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const ServiceTabs(current: ServicesTab.requests),
                    const SizedBox(height: AppSpacing.lg),
                    _StatusFilter(selected: _status, onChanged: _setStatus),
                    const SizedBox(height: AppSpacing.lg),
                    if (_paged.loading && _paged.hasData) const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator(minHeight: 3)),
                    _body(),
                    const SizedBox(height: AppSpacing.xl),
                    PaginationBar(meta: _paged.meta, busy: _paged.loading, itemLabel: 'requests', onPageChanged: _paged.goTo),
                    const SizedBox(height: 80),
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
          const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 120, radius: AppRadii.lg)),
      ]);
    }
    if (_paged.error != null && !_paged.hasData) {
      return SizedBox(height: 360, child: ApiErrorView(error: _paged.error!, onRetry: _paged.refresh, fallback: 'Could not load your requests.'));
    }
    if (!_paged.hasData) {
      return SizedBox(
        height: 360,
        child: EmptyStateView(
          icon: Icons.assignment_outlined,
          title: _status == null ? 'No service requests yet' : 'No ${_status!.label.toLowerCase()} requests',
          message: _status == null
              ? 'Book a service for your car and it will show up here with live status updates.'
              : 'Try another status, or show all requests.',
          action: _status == null
              ? FilledButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.services), child: const Text('Browse services'))
              : OutlinedButton(onPressed: () => _setStatus(null), child: const Text('Show all')),
        ),
      );
    }
    return Column(
      children: [
        if (_paged.error != null) InlineError('Could not refresh: ${_paged.error}'),
        for (final r in _paged.items)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: ServiceRequestCard(request: r, onTap: () => _open(r))),
      ],
    );
  }
}

class _StatusFilter extends StatelessWidget {
  final ServiceRequestStatus? selected;
  final ValueChanged<ServiceRequestStatus?> onChanged;
  const _StatusFilter({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, ServiceRequestStatus? value) {
      final on = selected == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: on,
          showCheckmark: false,
          selectedColor: AppColors.cyanTint,
          side: BorderSide(color: on ? AppColors.secondary : AppColors.divider),
          labelStyle: TextStyle(fontWeight: FontWeight.w700, color: on ? AppColors.secondary : AppColors.textPrimary),
          onSelected: (_) => onChanged(value),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [chip('All', null), for (final s in ServiceRequestStatus.values) chip(s.label, s)]),
    );
  }
}
