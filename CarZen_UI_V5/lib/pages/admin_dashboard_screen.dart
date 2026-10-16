// TODO(Ayush): gap E — no admin dashboard endpoint (counts assembled from list endpoints)
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/services/service_catalog_api.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';

class AdminDashboardMetrics {
  final int totalCars;
  final int pendingCars;
  final int totalUsers;
  final int activeUsers;
  final int activeListings;
  final int totalOrders;
  final int pendingOrders;
  final int totalServiceRequests;
  final int openServiceRequests;
  final int serviceCatalogCount;

  const AdminDashboardMetrics({
    required this.totalCars,
    required this.pendingCars,
    required this.totalUsers,
    required this.activeUsers,
    required this.activeListings,
    required this.totalOrders,
    required this.pendingOrders,
    required this.totalServiceRequests,
    required this.openServiceRequests,
    required this.serviceCatalogCount,
  });
}

/// Central administrative dashboard at `/admin`.
class AdminDashboardScreen extends StatefulWidget {
  final AdminDashboardMetrics? initialMetrics;
  const AdminDashboardScreen({super.key, this.initialMetrics});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _carService = CarService();
  final _profileService = ProfileService();
  final _marketplaceService = MarketplaceService();
  final _orderService = OrderService();
  final _serviceRequestApi = ServiceRequestApi();
  final _catalogApi = ServiceCatalogApi();

  late Future<AdminDashboardMetrics> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.initialMetrics != null ? Future.value(widget.initialMetrics) : _fetchMetrics();
  }

  void _reload() => setState(() => _future = _fetchMetrics());

  Future<AdminDashboardMetrics> _fetchMetrics() async {
    int totalCars = 0;
    int pendingCars = 0;
    int totalUsers = 0;
    int activeUsers = 0;
    int activeListings = 0;
    int totalOrders = 0;
    int pendingOrders = 0;
    int totalServiceRequests = 0;
    int openServiceRequests = 0;
    int serviceCatalogCount = 0;

    final tasks = <Future<void>>[
      _carService.listAdminCars(page: 1, limit: 1).then((res) {
        totalCars = res.pagination.total;
      }).catchError((_) {}),
      _carService.listAdminCars(page: 1, limit: 1, status: CarApprovalStatus.pendingApproval).then((res) {
        pendingCars = res.pagination.total;
      }).catchError((_) {}),
      _profileService.adminListUsers().then((users) {
        totalUsers = users.length;
        activeUsers = users.where((u) => u.isActive && !u.isBlocked).length;
      }).catchError((_) {}),
      _marketplaceService.listPublicListings(page: 1, limit: 1).then((res) {
        activeListings = res.pagination.total;
      }).catchError((_) {}),
      _orderService.listAdminOrders(page: 1, limit: 1).then((res) {
        totalOrders = res.pagination.total;
      }).catchError((_) {}),
      _orderService.listAdminOrders(page: 1, limit: 1, status: 'pending').then((res) {
        pendingOrders = res.pagination.total;
      }).catchError((_) {}),
      _serviceRequestApi.adminList(page: 1, limit: 1).then((res) {
        totalServiceRequests = res.pagination.total;
      }).catchError((_) {}),
      _serviceRequestApi.adminList(page: 1, limit: 1, status: ServiceRequestStatus.requested).then((res) {
        openServiceRequests = res.pagination.total;
      }).catchError((_) {}),
      _catalogApi.adminList(page: 1, limit: 1).then((res) {
        serviceCatalogCount = res.pagination.total;
      }).catchError((_) {}),
    ];

    await Future.wait(tasks);

    return AdminDashboardMetrics(
      totalCars: totalCars,
      pendingCars: pendingCars,
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      activeListings: activeListings,
      totalOrders: totalOrders,
      pendingOrders: pendingOrders,
      totalServiceRequests: totalServiceRequests,
      openServiceRequests: openServiceRequests,
      serviceCatalogCount: serviceCatalogCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.adminDashboard, title: 'Dashboard'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _reload();
            await _future;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: PageContainer(
              maxWidth: 1100,
              child: FutureBuilder<AdminDashboardMetrics>(
                future: _future,
                builder: (context, snapshot) {
                  final loading = snapshot.connectionState != ConnectionState.done;
                  final m = snapshot.data ??
                      const AdminDashboardMetrics(
                        totalCars: 0,
                        pendingCars: 0,
                        totalUsers: 0,
                        activeUsers: 0,
                        activeListings: 0,
                        totalOrders: 0,
                        pendingOrders: 0,
                        totalServiceRequests: 0,
                        openServiceRequests: 0,
                        serviceCatalogCount: 0,
                      );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const PageHeader(
                        title: 'Admin Dashboard',
                        subtitle: 'Overview of marketplace cars, orders, service requests, and platform users.',
                        icon: Icons.dashboard_rounded,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      _buildNeedsAttentionSection(context, m, loading),
                      const SizedBox(height: AppSpacing.xl),
                      Text('System Overview', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.md),
                      _buildMetricsGrid(context, m, loading),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeedsAttentionSection(BuildContext context, AdminDashboardMetrics m, bool loading) {
    final hasAttention = m.pendingCars > 0 || m.openServiceRequests > 0 || m.pendingOrders > 0;

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hasAttention ? AppColors.warning.withValues(alpha: 0.15) : AppColors.cyanTint,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  hasAttention ? Icons.notifications_active_rounded : Icons.check_circle_outline_rounded,
                  color: hasAttention ? AppColors.warning : AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Needs Attention', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    Text(
                      hasAttention
                          ? 'Operational items awaiting admin review or action'
                          : 'All items are up to date! No pending approvals.',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasAttention) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              children: [
                if (m.pendingCars > 0)
                  _AttentionItem(
                    label: '${m.pendingCars} car${m.pendingCars == 1 ? '' : 's'} pending approval',
                    route: AppRoutes.adminCars,
                    icon: Icons.fact_check_rounded,
                    tone: AppColors.warning,
                  ),
                if (m.openServiceRequests > 0)
                  _AttentionItem(
                    label: '${m.openServiceRequests} new service request${m.openServiceRequests == 1 ? '' : 's'}',
                    route: AppRoutes.adminServiceRequests,
                    icon: Icons.assignment_late_rounded,
                    tone: AppColors.favorite,
                  ),
                if (m.pendingOrders > 0)
                  _AttentionItem(
                    label: '${m.pendingOrders} order${m.pendingOrders == 1 ? '' : 's'} pending confirmation',
                    route: AppRoutes.adminOrders,
                    icon: Icons.local_shipping_rounded,
                    tone: AppColors.secondary,
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricsGrid(BuildContext context, AdminDashboardMetrics m, bool loading) {
    final wide = Breakpoints.isExpanded(context);
    final medium = Breakpoints.isMedium(context);
    final columns = wide ? 3 : (medium ? 2 : 1);

    final cards = [
      _MetricTile(
        title: 'Cars & Approvals',
        primaryValue: loading ? '...' : '${m.totalCars}',
        secondaryValue: '${m.pendingCars} pending approval',
        icon: Icons.directions_car_rounded,
        route: AppRoutes.adminCars,
      ),
      _MetricTile(
        title: 'Platform Users',
        primaryValue: loading ? '...' : '${m.totalUsers}',
        secondaryValue: '${m.activeUsers} active',
        icon: Icons.group_rounded,
        route: AppRoutes.adminUsers,
      ),
      _MetricTile(
        title: 'Active Listings',
        primaryValue: loading ? '...' : '${m.activeListings}',
        secondaryValue: 'Public on marketplace',
        icon: Icons.sell_rounded,
        route: AppRoutes.browse,
      ),
      _MetricTile(
        title: 'Orders',
        primaryValue: loading ? '...' : '${m.totalOrders}',
        secondaryValue: '${m.pendingOrders} pending',
        icon: Icons.local_shipping_rounded,
        route: AppRoutes.adminOrders,
      ),
      _MetricTile(
        title: 'Service Requests',
        primaryValue: loading ? '...' : '${m.totalServiceRequests}',
        secondaryValue: '${m.openServiceRequests} open / requested',
        icon: Icons.assignment_rounded,
        route: AppRoutes.adminServiceRequests,
      ),
      _MetricTile(
        title: 'Service Catalog',
        primaryValue: loading ? '...' : '${m.serviceCatalogCount}',
        secondaryValue: 'Catalog offerings',
        icon: Icons.build_circle_rounded,
        route: AppRoutes.adminServices,
      ),
    ];

    if (columns == 1) {
      return Column(
        children: [
          for (final c in cards) ...[c, const SizedBox(height: 12)],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - (columns - 1) * 16) / columns;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final c in cards) SizedBox(width: itemWidth, child: c),
          ],
        );
      },
    );
  }
}

class _AttentionItem extends StatelessWidget {
  final String label;
  final String route;
  final IconData icon;
  final Color tone;

  const _AttentionItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      borderRadius: BorderRadius.circular(AppRadii.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: tone.withValues(alpha: 0.3)),
        ),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 4,
          children: [
            Icon(icon, size: 16, color: tone),
            Text(label, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: tone)),
            Icon(Icons.arrow_forward_rounded, size: 14, color: tone),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String title;
  final String primaryValue;
  final String secondaryValue;
  final IconData icon;
  final String route;

  const _MetricTile({
    required this.title,
    required this.primaryValue,
    required this.secondaryValue,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: () => Navigator.of(context).pushNamed(route),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textSecondary)),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: AppColors.cyanTint, shape: BoxShape.circle),
                child: Icon(icon, color: AppColors.secondary, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(primaryValue, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 28, color: AppColors.primary)),
          const SizedBox(height: 4),
          Text(secondaryValue, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
