import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/pages/car_manage_screen.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/services/seller_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';

/// One of the seller's cars with what the list needs to show.
class OwnedCar {
  final CarRecordDetail car;
  final Listing? listing;
  const OwnedCar(this.car, this.listing);
}

/// The selling hub: how the seller's cars are doing, what needs attention,
/// and every car with its next step.
class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final _cars = CarService();
  final _market = MarketplaceService();
  final _seller = SellerService();

  CarApprovalStatus? _filter;
  late PagedController<OwnedCar> _paged = _controller();
  late Future<SellerDashboard> _dashboard = _seller.dashboard();

  PagedController<OwnedCar> _controller() => PagedController<OwnedCar>(limit: 8, fetch: _fetch)..load();

  Future<PaginatedList<OwnedCar>> _fetch(int page, int limit) async {
    final result = await _cars.listMyCars(page: page, limit: limit, status: _filter);
    final items = await Future.wait(result.data.map((c) async {
      final detail = await _cars.getCar(c.id);
      Listing? listing;
      try {
        listing = await _market.getOwnedListing(c.id);
      } on ApiException catch (e) {
        if (e.statusCode != 404) rethrow;
      }
      return OwnedCar(detail, listing);
    }));
    return PaginatedList(data: items, pagination: result.pagination);
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _setFilter(CarApprovalStatus? f) {
    if (f == _filter) return;
    final old = _paged;
    setState(() {
      _filter = f;
      _paged = _controller();
    });
    old.dispose();
  }

  Future<void> _refresh() async {
    setState(() => _dashboard = _seller.dashboard());
    await _paged.refresh();
  }

  Future<void> _open(OwnedCar c) async {
    await Navigator.of(context).pushNamed(AppRoutes.myCar(c.car.id));
    if (mounted) _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    return AppScaffold(
      section: NavSection.sell,
      title: 'Selling',
      showBottomNav: true,
      floatingActionButton: compact
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sellNew),
              icon: const Icon(Icons.add),
              label: const Text('Add a car'),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: PageContainer(
            maxWidth: 1080,
            verticalPadding: compact ? 18 : 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Selling',
                  subtitle: 'Your cars, their review status and everything buyers have sent you.',
                  actions: [
                    if (!compact)
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sellNew),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Add a car'),
                      ),
                  ],
                ),
                const SizedBox(height: 22),
                _Overview(dashboard: _dashboard),
                const SizedBox(height: 32),
                SectionTitle('Your cars', subtitle: 'Open a car to add photos, set the price and publish.'),
                SegmentFilter<CarApprovalStatus?>(
                  options: const [
                    (null, 'All'),
                    (CarApprovalStatus.pendingApproval, 'Waiting for review'),
                    (CarApprovalStatus.approved, 'Approved'),
                    (CarApprovalStatus.published, 'Live'),
                    (CarApprovalStatus.rejected, 'Changes needed'),
                    (CarApprovalStatus.sold, 'Sold'),
                  ],
                  selected: _filter,
                  onChanged: _setFilter,
                ),
                const SizedBox(height: 16),
                PagedBody<OwnedCar>(
                  controller: _paged,
                  itemLabel: 'cars',
                  skeletonHeight: 124,
                  errorFallback: 'Your cars could not be loaded.',
                  empty: _filter == null
                      ? EmptyStateView(
                          compact: true,
                          icon: Icons.garage_outlined,
                          title: 'Sell your first car',
                          message: 'Add the details and photos. Our team reviews it, then you publish it with your price.',
                          action: ElevatedButton(
                            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sellNew),
                            child: const Text('Add a car'),
                          ),
                        )
                      : const EmptyStateView(compact: true, icon: Icons.filter_alt_off_outlined, title: 'No cars here', message: 'No cars have this status right now.'),
                  itemBuilder: (context, c) => _OwnedCarCard(item: c, onTap: () => _open(c)),
                ),
                if (compact) const SizedBox(height: 72),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Overview extends StatelessWidget {
  final Future<SellerDashboard> dashboard;
  const _Overview({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SellerDashboard>(
      future: dashboard,
      builder: (context, snap) {
        final d = snap.data;
        final tiles = <(String, String, IconData, String?)>[
          ('Live listings', d == null ? '-' : '${d.activeListings}', Icons.storefront_outlined, null),
          ('Waiting for review', d == null ? '-' : '${d.pendingApprovals}', Icons.hourglass_empty, null),
          ('Sold', d == null ? '-' : '${d.soldCars}', Icons.handshake_outlined, null),
          ('Buyer questions', d == null ? '-' : '${d.inquiries}', Icons.forum_outlined, '${AppRoutes.messages}?tab=selling'),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ResponsiveGrid(
              minTileWidth: 200,
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final t in tiles)
                  _StatTile(
                    label: t.$1,
                    value: t.$2,
                    icon: t.$3,
                    loading: snap.connectionState != ConnectionState.done,
                    onTap: t.$4 == null ? null : () => Navigator.of(context).pushNamed(t.$4!),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sales),
                  icon: const Icon(Icons.receipt_long_outlined, size: 19),
                  label: const Text('Orders received'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed('${AppRoutes.messages}?tab=selling'),
                  icon: const Icon(Icons.forum_outlined, size: 19),
                  label: const Text('Buyer questions'),
                ),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profileContact),
                  icon: const Icon(Icons.contact_phone_outlined, size: 19),
                  label: const Text('Contact preferences'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool loading;
  final VoidCallback? onTap;

  const _StatTile({required this.label, required this.value, required this.icon, required this.loading, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md), side: const BorderSide(color: AppColors.divider)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Semantics(
          label: '$label: $value',
          button: onTap != null,
          excludeSemantics: true,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.textSecondary, size: 22),
                const SizedBox(width: 12),
                Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
                loading ? const SkeletonBox(width: 24, height: 22) : Text(value, style: AppText.price(22)),
                if (onTap != null) const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OwnedCarCard extends StatelessWidget {
  final OwnedCar item;
  final VoidCallback onTap;
  const _OwnedCarCard({required this.item, required this.onTap});

  String? _nextStep() {
    final car = item.car;
    final listing = item.listing;
    final photos = car.media.where((m) => m.mediaType == MediaType.image).length;
    switch (car.approvalStatus) {
      case CarApprovalStatus.rejected:
        return 'Changes needed: ${car.rejectionReason ?? 'see details'}';
      case CarApprovalStatus.pendingApproval:
        return photos == 0 ? 'Add photos to speed up the review' : (listing == null ? 'In review. Set your price meanwhile' : 'In review');
      case CarApprovalStatus.approved:
        return listing == null ? 'Approved. Create a listing to sell it' : 'Approved. Publish your listing';
      case CarApprovalStatus.published:
        if (listing?.listingStatus == ListingStatus.reserved) return 'Reserved for a buyer. Finish the sale in Orders';
        return listing?.listingStatus == ListingStatus.active ? null : 'Listing is not live. Publish it again';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final car = item.car;
    final listing = item.listing;
    final cover = car.media.cover?.thumbnailAbsoluteUrl(ApiConfig.baseUrl);
    final next = _nextStep();
    final compact = Breakpoints.isCompact(context);
    final status = listing?.listingStatus == ListingStatus.reserved
        ? StatusPill(label: 'Reserved', tone: listingTone(ListingStatus.reserved))
        : StatusPill(label: car.approvalStatus.label, tone: approvalTone(car.approvalStatus));
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.lg), side: const BorderSide(color: AppColors.divider)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.sm),
                child: SizedBox(
                  width: compact ? 104 : 160,
                  height: compact ? 88 : 110,
                  child: NetworkPhoto(url: cover, cacheWidth: 320, fallbackLabel: 'No photos'),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            car.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                        ),
                        if (!compact) status,
                      ],
                    ),
                    Text('${car.variantName}, ${car.manufacturingYear}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                    if (compact) ...[const SizedBox(height: 6), status],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 4,
                      children: [
                        Text(listing == null ? 'No price set' : formatLakh(listing.askingPrice), style: AppText.price(16)),
                        if (listing?.viewsCount != null && listing!.viewsCount! > 0)
                          Text('${formatCount(listing.viewsCount!)} views', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
                      ],
                    ),
                    if (next != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            car.approvalStatus == CarApprovalStatus.rejected ? Icons.error_outline : Icons.arrow_circle_right_outlined,
                            size: 17,
                            color: car.approvalStatus == CarApprovalStatus.rejected ? AppColors.danger : AppColors.chrome,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              next,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: car.approvalStatus == CarApprovalStatus.rejected ? AppColors.danger : AppColors.chrome,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
