import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/pages/my_orders_screen.dart' show orderTone;
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/admin_listing_service.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/services/report_service.dart';
import 'package:carzen_flutter/services/service_catalog_api.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/services/transaction_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/admin_widgets.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';

/// Counts for the dashboard. There is no dashboard endpoint, so each number
/// is the `total` of a one-item page from the matching admin list; a count
/// that could not be loaded stays null and shows as a dash.
class _Metrics {
  int? pendingCars;
  int? listingsInReview;
  int? pendingOrders;
  int? newServiceRequests;
  int? newReports;
  int? users;
  int? liveListings;
  int? orders;
  int? completedSales;
  int? serviceRequests;
  int? services;
  List<OrderRecord> latestOrders = const [];
}

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<_Metrics> _future = _load();

  Future<_Metrics> _load() async {
    final m = _Metrics();
    final cars = CarService();
    final listings = AdminListingService();
    final orders = OrderService();
    final requests = ServiceRequestApi();
    Future<void> count(Future<int> Function() f, void Function(int) set) async {
      try {
        set(await f());
      } catch (_) {}
    }

    await Future.wait([
      count(() async => (await cars.listAdminCars(limit: 1, status: CarApprovalStatus.pendingApproval)).pagination.total, (v) => m.pendingCars = v),
      count(() async => (await listings.list(limit: 1, status: ListingStatus.pendingReview.apiValue)).pagination.total, (v) => m.listingsInReview = v),
      count(() async => (await orders.listAdminOrders(limit: 1, status: 'pending')).pagination.total, (v) => m.pendingOrders = v),
      count(() async => (await requests.adminList(limit: 1, status: ServiceRequestStatus.requested)).pagination.total, (v) => m.newServiceRequests = v),
      count(() async => (await ReportService().adminList(limit: 1, status: 'pending')).pagination.total, (v) => m.newReports = v),
      count(() async => (await ProfileService().adminListUsers()).length, (v) => m.users = v),
      count(() async => (await MarketplaceService().listPublicListings(page: 1, limit: 1)).pagination.total, (v) => m.liveListings = v),
      count(() async => (await TransactionService().adminList(limit: 1, status: 'completed')).pagination.total, (v) => m.completedSales = v),
      count(() async => (await requests.adminList(limit: 1)).pagination.total, (v) => m.serviceRequests = v),
      count(() async => (await ServiceCatalogApi().adminList(limit: 1)).pagination.total, (v) => m.services = v),
      () async {
        try {
          final res = await orders.listAdminOrders(limit: 6);
          m.orders = res.pagination.total;
          m.latestOrders = res.data;
        } catch (_) {}
      }(),
    ]);
    return m;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  String _greeting() {
    final h = DateTime.now().hour;
    final name = SessionController.instance.user?.firstName;
    final part = h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
    return name == null ? part : '$part, $name';
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      section: NavSection.adminDashboard,
      title: _greeting(),
      subtitle: 'Here is what needs a decision on CarZen today.',
      onRefresh: _refresh,
      child: FutureBuilder<_Metrics>(
        future: _future,
        builder: (context, snap) {
          final loading = snap.connectionState != ConnectionState.done;
          final m = snap.data ?? _Metrics();
          String v(int? n) => loading ? '...' : (n == null ? '-' : formatCount(n));
          void go(String r) => Navigator.of(context).pushNamed(r).then((_) => _refresh());

          final queue = <_QueueItem>[
            _QueueItem('Cars waiting for approval', m.pendingCars, Icons.fact_check_outlined, AppRoutes.adminCars, 'Review'),
            _QueueItem('Listings in review', m.listingsInReview, Icons.storefront_outlined, AppRoutes.adminListings, 'Open'),
            _QueueItem('Orders waiting for the seller', m.pendingOrders, Icons.receipt_long_outlined, AppRoutes.adminOrders, 'Open'),
            _QueueItem('New workshop requests', m.newServiceRequests, Icons.assignment_outlined, AppRoutes.adminServiceRequests, 'Respond'),
            _QueueItem('New reports from buyers', m.newReports, Icons.flag_outlined, AppRoutes.adminReports, 'Review'),
          ];
          final open = queue.where((q) => (q.count ?? 0) > 0).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _QueuePanel(items: queue, loading: loading, openCount: open, onGo: go),
              const SizedBox(height: 28),
              const SectionTitle('Marketplace at a glance'),
              ResponsiveGrid(
                minTileWidth: 220,
                maxColumns: 3,
                children: [
                  StatTile(label: 'Users', value: v(m.users), icon: Icons.group_outlined, onTap: () => go(AppRoutes.adminUsers)),
                  StatTile(label: 'Cars on sale', value: v(m.liveListings), icon: Icons.directions_car_outlined, onTap: () => go(AppRoutes.adminListings)),
                  StatTile(label: 'Orders', value: v(m.orders), icon: Icons.receipt_long_outlined, onTap: () => go(AppRoutes.adminOrders)),
                  StatTile(label: 'Completed sales', value: v(m.completedSales), icon: Icons.account_balance_wallet_outlined, onTap: () => go(AppRoutes.adminTransactions)),
                  StatTile(label: 'Workshop requests', value: v(m.serviceRequests), icon: Icons.build_outlined, onTap: () => go(AppRoutes.adminServiceRequests)),
                  StatTile(label: 'Workshop services', value: v(m.services), icon: Icons.handyman_outlined, onTap: () => go(AppRoutes.adminServices)),
                ],
              ),
              const SizedBox(height: 28),
              SectionTitle(
                'Latest orders',
                trailing: TextButton(onPressed: () => go(AppRoutes.adminOrders), child: const Text('All orders')),
              ),
              if (loading)
                const Column(children: [SkeletonLine(), SizedBox(height: 12), SkeletonLine(), SizedBox(height: 12), SkeletonLine()])
              else if (m.latestOrders.isEmpty)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const EmptyStateView(compact: true, icon: Icons.receipt_long_outlined, title: 'No orders yet', message: 'Orders appear here as buyers place them.'),
                )
              else
                AdminTable<OrderRecord>(
                  items: m.latestOrders,
                  onTap: (_) => go(AppRoutes.adminOrders),
                  cardTitle: (o) => Text(o.listingTitle),
                  cardBadge: (o) => StatusPill(label: humanizeStatus(o.status), tone: orderTone(o.status)),
                  columns: [
                    AdminColumn('Car', (o) => StackedCell(o.listingTitle, 'Order #${o.id}'), flex: 5, showInCard: false),
                    AdminColumn('Buyer', (o) => TextCell(o.buyer?.displayName ?? 'User #${o.buyerId}'), flex: 3),
                    AdminColumn('Amount', (o) => Text(formatLakh(o.amount), style: AppText.figures(14)), flex: 2),
                    AdminColumn('Placed', (o) => TextCell(formatRelative(o.createdAt)), flex: 2),
                    AdminColumn('Status', (o) => StatusPill(label: humanizeStatus(o.status), tone: orderTone(o.status)), flex: 2, showInCard: false),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _QueueItem {
  final String label;
  final int? count;
  final IconData icon;
  final String route;
  final String action;
  const _QueueItem(this.label, this.count, this.icon, this.route, this.action);
}

class _QueuePanel extends StatelessWidget {
  final List<_QueueItem> items;
  final bool loading;
  final int openCount;
  final ValueChanged<String> onGo;

  const _QueuePanel({required this.items, required this.loading, required this.openCount, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadii.xl)),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loading ? 'Checking the queues...' : (openCount == 0 ? 'All queues are clear' : 'Waiting for you'),
            style: AppText.heading(18, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            loading ? ' ' : (openCount == 0 ? 'Nothing needs a decision right now.' : '$openCount queue${openCount == 1 ? '' : 's'} with items to handle.'),
            style: const TextStyle(color: Color(0xFFB9C6D8), fontSize: 13.5),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0x22FFFFFF)),
            _QueueRow(item: items[i], loading: loading, onGo: onGo),
          ],
        ],
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  final _QueueItem item;
  final bool loading;
  final ValueChanged<String> onGo;
  const _QueueRow({required this.item, required this.loading, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final n = item.count;
    final has = (n ?? 0) > 0;
    return InkWell(
      onTap: () => onGo(item.route),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(item.icon, color: has ? AppColors.plate : const Color(0xFF7F91A8), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(color: has ? Colors.white : const Color(0xFFB9C6D8), fontWeight: has ? FontWeight.w600 : FontWeight.w400, fontSize: 14.5),
              ),
            ),
            const SizedBox(width: 12),
            if (loading)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54))
            else if (has)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.plate, borderRadius: BorderRadius.circular(AppRadii.xs)),
                child: Text(formatCount(n!), style: AppText.figures(14, color: AppColors.ink, weight: FontWeight.w700)),
              )
            else
              Text(n == null ? 'Unavailable' : 'None', style: const TextStyle(color: Color(0xFF7F91A8), fontSize: 13)),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: Color(0xFF7F91A8), size: 20),
          ],
        ),
      ),
    );
  }
}
