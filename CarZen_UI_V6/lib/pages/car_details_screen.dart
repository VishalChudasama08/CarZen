import 'dart:ui' as ui;

import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/auth_gate.dart';
import 'package:carzen_flutter/services/buyer_service.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/services/review_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/listing_card.dart';
import 'package:carzen_flutter/widgets/listing_dialogs.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// One public listing in full.
///
/// Signed-in buyers open it through `/buyer/listings/{id}` so it lands in
/// their "Recently viewed"; everyone else uses the public endpoint. Saving,
/// purchase requests, messages and reports go through [AuthGate].
class CarDetailsScreen extends StatefulWidget {
  final int listingId;
  const CarDetailsScreen({super.key, required this.listingId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final _market = MarketplaceService();
  final _buyer = BuyerService();
  final _orders = OrderService();
  final _engagement = EngagementService();
  final _reviews = ReviewService();
  final _session = SessionController.instance;

  late Future<ListingDetail> _future;
  Future<PaginatedReviews>? _reviewsFuture;
  Future<List<ListingDetail>>? _similarFuture;
  bool _isFavorite = false;
  bool _favoriteBusy = false;
  bool _ordering = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _fetch().then((listing) {
      _syncFavorite(listing.car.id);
      _reviewsFuture = _reviews
          .forCar(listing.car.id)
          .then((p) => PaginatedReviews(p.data, p.pagination.total))
          .catchError((_) => const PaginatedReviews([], 0));
      _similarFuture = _loadSimilar(listing);
      return listing;
    });
  }

  Future<ListingDetail> _fetch() async {
    await _session.refresh();
    if (_session.isLoggedIn && !_session.isAdmin) {
      try {
        return await _buyer.viewListing(widget.listingId);
      } on ApiException catch (e) {
        if (e.statusCode == 404) rethrow;
        // Fall back to the public endpoint (e.g. own listing or a role check).
      }
    }
    return _market.getPublicListing(widget.listingId);
  }

  Future<List<ListingDetail>> _loadSimilar(ListingDetail listing) async {
    try {
      final page = await _market.listPublicListings(limit: 5, search: listing.car.brandName);
      final others = page.data.where((l) => l.id != listing.id).take(4);
      return await _market.expandWithCarDetails(others);
    } catch (_) {
      return const [];
    }
  }

  void _snack(String message, {bool error = false}) {
    if (mounted) showAppSnack(context, message, error: error);
  }

  Future<void> _syncFavorite(int carId) async {
    if (!_session.isLoggedIn || _session.isAdmin) return;
    try {
      final favorites = await _market.listFavorites();
      if (mounted) setState(() => _isFavorite = favorites.any((f) => f.carId == carId));
    } on ApiException {
      // Not essential for the page.
    }
  }

  Future<void> _toggleFavorite(int carId) async {
    final want = !_isFavorite;
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    setState(() => _favoriteBusy = true);
    try {
      if (want) {
        await _market.addFavorite(carId);
      } else {
        await _market.removeFavorite(carId);
      }
      if (!mounted) return;
      setState(() => _isFavorite = want);
      _snack(want ? 'Saved. We\'ll let you know if the price changes.' : 'Removed from saved cars');
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } finally {
      if (mounted) setState(() => _favoriteBusy = false);
    }
  }

  Future<void> _placeOrder(ListingDetail listing) async {
    if (_ordering) return;
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    final result = await showOrderRequestDialog(context, amount: listing.askingPrice);
    if (result == null || !mounted) return;
    setState(() => _ordering = true);
    try {
      await _orders.createOrder(listingId: listing.id, notes: result.note);
      if (!mounted) return;
      _snack('Purchase request sent. You\'ll be notified when the seller replies.');
      Navigator.of(context).pushNamed(AppRoutes.orders);
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } finally {
      if (mounted) setState(() => _ordering = false);
    }
  }

  Future<void> _askSeller(ListingDetail listing) async {
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    final result = await showInquiryDialog(context, defaultSubject: listing.title);
    if (result == null) return;
    try {
      final inquiry = await _engagement.createInquiry(listingId: listing.id, subject: result.subject, message: result.message);
      if (!mounted) return;
      _snack('Message sent to the seller.');
      Navigator.of(context).pushNamed(AppRoutes.inquiry(inquiry.id));
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    }
  }

  Future<void> _report(ListingDetail listing) async {
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    final result = await showReportDialog(context);
    if (result == null) return;
    try {
      await _engagement.reportListing(listingId: listing.id, reason: result.reason, description: result.description);
      _snack('Report sent. Our team will review this listing.');
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    }
  }

  Future<void> _copyLink(ListingDetail listing) async {
    final path = AppRoutes.carDetails(listing.id, listing.title);
    final base = Uri.base;
    final link = base.hasScheme && (base.scheme == 'http' || base.scheme == 'https') ? base.resolve(path).toString() : path;
    await Clipboard.setData(ClipboardData(text: link));
    _snack('Link copied');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ListingDetail>(
      future: _future,
      builder: (context, snapshot) {
        final listing = snapshot.data;
        final compact = Breakpoints.widthOf(context) < Breakpoints.expanded;
        final canAct = listing != null && !_session.isAdmin;
        return AppScaffold(
          section: NavSection.buy,
          title: listing == null ? 'Car details' : '${listing.car.brandName} ${listing.car.modelName}',
          fallbackRoute: AppRoutes.browse,
          bottomBar: compact && canAct
              ? _StickyActions(
                  listing: listing,
                  busy: _ordering,
                  onOrder: () => _placeOrder(listing),
                  onAsk: () => _askSeller(listing),
                )
              : null,
          body: _body(context, snapshot),
        );
      },
    );
  }

  Widget _body(BuildContext context, AsyncSnapshot<ListingDetail> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) return const _DetailsSkeleton();
    if (snapshot.hasError) {
      final error = snapshot.error;
      if (error is ApiException && error.statusCode == 404) {
        return EmptyStateView(
          icon: Icons.car_crash_outlined,
          title: 'This car is no longer for sale',
          message: 'It may have been sold or taken down by the seller.',
          action: FilledButton(
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.browse, (r) => false),
            child: const Text('See other cars'),
          ),
        );
      }
      return ApiErrorView(error: error!, onRetry: () => setState(_load), fallback: 'This listing could not be loaded.');
    }
    final listing = snapshot.data!;
    final car = listing.car;
    final width = Breakpoints.widthOf(context);
    final wide = width >= Breakpoints.expanded;

    final summary = _SummaryPanel(
      listing: listing,
      isAdmin: _session.isAdmin,
      isFavorite: _isFavorite,
      favoriteBusy: _favoriteBusy,
      ordering: _ordering,
      showActions: wide,
      onFavorite: () => _toggleFavorite(car.id),
      onOrder: () => _placeOrder(listing),
      onAsk: () => _askSeller(listing),
      onReport: () => _report(listing),
      onCopyLink: () => _copyLink(listing),
    );

    final details = <Widget>[
      _KeyFacts(car: car),
      const SizedBox(height: 32),
      const SectionTitle('Specifications'),
      _SpecTable(car: car),
      if (car.features.isNotEmpty) ...[
        const SizedBox(height: 32),
        const SectionTitle('Features'),
        _FeatureList(features: car.features),
      ],
      if ((listing.description ?? '').trim().isNotEmpty || (car.description ?? '').trim().isNotEmpty) ...[
        const SizedBox(height: 32),
        const SectionTitle('From the seller'),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Text(
            [listing.description, car.description].whereType<String>().where((s) => s.trim().isNotEmpty).toSet().join('\n\n'),
            style: const TextStyle(color: AppColors.textPrimary, height: 1.65, fontSize: 15.5),
          ),
        ),
      ],
      const SizedBox(height: 32),
      _ReviewsSection(future: _reviewsFuture),
      if (!wide && !_session.isAdmin) ...[
        const SizedBox(height: 24),
        Wrap(spacing: 4, children: [
          TextButton.icon(
            onPressed: _favoriteBusy ? null : () => _toggleFavorite(car.id),
            icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border, color: AppColors.danger),
            label: Text(_isFavorite ? 'Saved' : 'Save this car'),
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
          ),
          TextButton.icon(
            onPressed: () => _copyLink(listing),
            icon: const Icon(Icons.link),
            label: const Text('Copy link'),
            style: TextButton.styleFrom(foregroundColor: AppColors.ink),
          ),
          TextButton.icon(
            onPressed: () => _report(listing),
            icon: const Icon(Icons.flag_outlined),
            label: const Text('Report listing'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
        ]),
      ],
      const SizedBox(height: 40),
      _SimilarCars(future: _similarFuture),
    ];

    if (wide) {
      return SingleChildScrollView(
        child: PageContainer(
          verticalPadding: 28,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_Gallery(media: car.media, title: listing.title), const SizedBox(height: 28), ...details],
                ),
              ),
              const SizedBox(width: 32),
              SizedBox(width: width >= 1280 ? 380 : 340, child: summary),
            ],
          ),
        ),
      );
    }

    final compact = width < Breakpoints.medium;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (compact) _Gallery(media: car.media, title: listing.title, edgeToEdge: true),
          PageContainer(
            maxWidth: 820,
            verticalPadding: compact ? 18 : 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!compact) ...[_Gallery(media: car.media, title: listing.title), const SizedBox(height: 20)],
                summary,
                const SizedBox(height: 24),
                ...details,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaginatedReviews {
  final List<ReviewRecord> items;
  final int total;
  const PaginatedReviews(this.items, this.total);
}

// ---------------------------------------------------------------------------
// Summary: title, price and actions
// ---------------------------------------------------------------------------

class _SummaryPanel extends StatelessWidget {
  final ListingDetail listing;
  final bool isAdmin;
  final bool isFavorite;
  final bool favoriteBusy;
  final bool ordering;
  final bool showActions;
  final VoidCallback onFavorite;
  final VoidCallback onOrder;
  final VoidCallback onAsk;
  final VoidCallback onReport;
  final VoidCallback onCopyLink;

  const _SummaryPanel({
    required this.listing,
    required this.isAdmin,
    required this.isFavorite,
    required this.favoriteBusy,
    required this.ordering,
    required this.showActions,
    required this.onFavorite,
    required this.onOrder,
    required this.onAsk,
    required this.onReport,
    required this.onCopyLink,
  });

  @override
  Widget build(BuildContext context) {
    final car = listing.car;
    final market = car.expectedMarketPrice;
    final compact = Breakpoints.isCompact(context);
    final reserved = listing.listingStatus == ListingStatus.reserved;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text('${car.brandName} ${car.modelName}', style: AppText.heading(compact ? 22 : 24)),
        ),
        const SizedBox(height: 4),
        Text(
          '${car.variantName}, ${car.manufacturingYear}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
        const SizedBox(height: 18),
        Text(formatInr(listing.askingPrice), style: AppText.price(compact ? 28 : 32)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            Text(
              listing.negotiable ? 'Price is negotiable' : 'Fixed price',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: listing.negotiable ? AppColors.success : AppColors.textSecondary,
              ),
            ),
            if (market != null && market > 0)
              Text('Seller\'s market estimate ${formatLakh(market)}', style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
          ],
        ),
        if (reserved) ...[
          const SizedBox(height: 14),
          const Callout(
            tone: CalloutTone.warning,
            icon: Icons.schedule,
            message: 'Reserved: the seller has accepted another buyer\'s request. You can still save it in case the sale falls through.',
          ),
        ],
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 14),
        Row(
          children: [
            const Icon(Icons.place_outlined, size: 18, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text('${car.city}, ${car.state}', style: const TextStyle(fontSize: 14.5))),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.verified_outlined, size: 18, color: AppColors.success),
            const SizedBox(width: 8),
            const Expanded(child: Text('Details checked by the CarZen team', style: TextStyle(fontSize: 14.5))),
          ],
        ),
        if (listing.viewsCount != null && listing.viewsCount! > 0) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.visibility_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text('${formatCount(listing.viewsCount!)} ${listing.viewsCount == 1 ? 'view' : 'views'}', style: const TextStyle(fontSize: 14.5)),
            ],
          ),
        ],
        if (showActions) ...[
          const SizedBox(height: 20),
          if (isAdmin)
            const Callout(message: 'You are signed in as an admin. Buying and messaging are done from user accounts.')
          else ...[
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: (ordering || listing.listingStatus != ListingStatus.active) ? null : onOrder,
                child: ordering
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.ink))
                    : const Text('Send purchase request'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onAsk,
                icon: const Icon(Icons.chat_bubble_outline, size: 19),
                label: const Text('Message the seller'),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Sending a request is free. You pay only after the seller accepts.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: favoriteBusy ? null : onFavorite,
                  style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: AppColors.danger, size: 20),
                  label: Text(isFavorite ? 'Saved' : 'Save'),
                ),
                TextButton.icon(
                  onPressed: onCopyLink,
                  style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                  icon: const Icon(Icons.link, size: 20),
                  label: const Text('Copy link'),
                ),
                IconButton(
                  tooltip: 'Report this listing',
                  onPressed: onReport,
                  icon: const Icon(Icons.flag_outlined, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ],
      ],
    );
    return Container(
      padding: EdgeInsets.all(compact ? 16 : 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: content,
    );
  }
}

/// Phone/tablet action bar pinned to the bottom of the screen.
class _StickyActions extends StatelessWidget {
  final ListingDetail listing;
  final bool busy;
  final VoidCallback onOrder;
  final VoidCallback onAsk;

  const _StickyActions({required this.listing, required this.busy, required this.onOrder, required this.onAsk});

  @override
  Widget build(BuildContext context) {
    final narrow = Breakpoints.widthOf(context) < 380;
    return Material(
      color: AppColors.surface,
      elevation: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider)),
          boxShadow: [BoxShadow(color: Color(0x140F1C2E), blurRadius: 16, offset: Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(formatLakh(listing.askingPrice), style: AppText.price(narrow ? 17 : 19)),
                      Text(
                        listing.negotiable ? 'Negotiable' : 'Fixed price',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Message the seller',
                  onPressed: onAsk,
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48), side: const BorderSide(color: AppColors.lineStrong)),
                  icon: const Icon(Icons.chat_bubble_outline),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: (busy || listing.listingStatus != ListingStatus.active) ? null : onOrder,
                  style: ElevatedButton.styleFrom(minimumSize: Size(narrow ? 120 : 150, 48), padding: const EdgeInsets.symmetric(horizontal: 14)),
                  child: busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.ink))
                      : Text(narrow ? 'Request' : 'Request to buy'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Facts, specs, features
// ---------------------------------------------------------------------------

class _KeyFacts extends StatelessWidget {
  final ListingCar car;
  const _KeyFacts({required this.car});

  @override
  Widget build(BuildContext context) {
    final facts = <(IconData, String, String)>[
      (Icons.speed_outlined, 'Driven', formatKm(car.mileageKm)),
      (Icons.local_gas_station_outlined, 'Fuel', car.fuelType.label),
      (Icons.settings_outlined, 'Gearbox', car.transmission.label),
      (Icons.person_outline, 'Owner', car.ownershipType?.label ?? (car.ownerCount == null ? 'Not stated' : '${car.ownerCount}')),
      (Icons.event_outlined, 'Registered', '${car.registrationYear ?? car.manufacturingYear}'),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final cols = c.maxWidth >= 640 ? 5 : (c.maxWidth >= 420 ? 3 : 2);
        final w = (c.maxWidth - (cols - 1) * 1) / cols;
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Wrap(
            spacing: 1,
            runSpacing: 1,
            children: [
              for (final f in facts)
                Container(
                  width: w,
                  color: AppColors.surface,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(f.$1, size: 20, color: AppColors.textSecondary),
                      const SizedBox(height: 8),
                      Text(f.$2, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                      const SizedBox(height: 2),
                      Text(f.$3, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SpecTable extends StatelessWidget {
  final ListingCar car;
  const _SpecTable({required this.car});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Make and model', '${car.brandName} ${car.modelName}'),
      ('Variant', car.variantName),
      ('Manufactured', '${car.manufacturingYear}'),
      if (car.bodyType != null) ('Body type', car.bodyType!.label),
      if (car.engineCc != null) ('Engine', '${formatCount(car.engineCc!)} cc'),
      if (car.horsepower != null) ('Power', '${formatCount(car.horsepower!)} hp'),
      if (car.seatingCapacity != null) ('Seats', '${car.seatingCapacity}'),
      if (car.color != null) ('Colour', car.color!),
      ('Condition', car.condition.label),
      if (car.insuranceType != null || car.insuranceCompany != null)
        ('Insurance', [car.insuranceType, car.insuranceCompany].whereType<String>().join(', ')),
      if (car.insuranceExpiry != null) ('Insurance valid until', formatDate(car.insuranceExpiry)),
      if (car.rcStatus != null) ('RC status', car.rcStatus!),
    ];
    return LayoutBuilder(
      builder: (context, c) {
        final twoCol = c.maxWidth >= 620;
        Widget cell((String, String) r) => Container(
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Text(r.$1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14.5))),
                  const SizedBox(width: 12),
                  Expanded(child: Text(r.$2, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5))),
                ],
              ),
            );
        if (!twoCol) return Column(children: [for (final r in rows) cell(r)]);
        final half = (rows.length / 2).ceil();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Column(children: [for (final r in rows.take(half)) cell(r)])),
            const SizedBox(width: 32),
            Expanded(child: Column(children: [for (final r in rows.skip(half)) cell(r)])),
          ],
        );
      },
    );
  }
}

class _FeatureList extends StatelessWidget {
  final List<CarFeature> features;
  const _FeatureList({required this.features});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final f in features)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.sm),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 16, color: AppColors.success),
                const SizedBox(width: 8),
                Text.rich(TextSpan(children: [
                  TextSpan(text: f.featureName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (f.featureValue != null && f.featureValue!.isNotEmpty)
                    TextSpan(text: '  ${f.featureValue}', style: const TextStyle(color: AppColors.textSecondary)),
                ]), style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Reviews & similar cars
// ---------------------------------------------------------------------------

class _ReviewsSection extends StatelessWidget {
  final Future<PaginatedReviews>? future;
  const _ReviewsSection({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PaginatedReviews>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const SizedBox.shrink();
        final reviews = snap.data?.items ?? const <ReviewRecord>[];
        final visible = reviews.where((r) => r.isVisible).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle(
              'Buyer reviews',
              subtitle: visible.isEmpty ? null : _summary(visible),
            ),
            if (visible.isEmpty)
              const Text(
                'No reviews for this car yet. Buyers can review a car after completing the purchase.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14.5),
              )
            else
              for (final r in visible.take(4))
                Padding(padding: const EdgeInsets.only(bottom: 12), child: ReviewTile(review: r)),
          ],
        );
      },
    );
  }

  String _summary(List<ReviewRecord> reviews) {
    final avg = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;
    return '${avg.toStringAsFixed(1)} out of 5, from ${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'}';
  }
}

/// One review: stars, title, text, author and date.
class ReviewTile extends StatelessWidget {
  final ReviewRecord review;
  final Widget? trailing;
  const ReviewTile({super.key, required this.review, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StarRating(rating: review.rating),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  [review.user?.displayName, formatDate(review.createdAt)].whereType<String>().where((s) => s.isNotEmpty).join(', '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
              ?trailing,
            ],
          ),
          if ((review.title ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.title!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          ],
          if ((review.reviewText ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.reviewText!, style: const TextStyle(height: 1.5, fontSize: 14.5)),
          ],
        ],
      ),
    );
  }
}

/// Read-only star rating with an accessible label.
class StarRating extends StatelessWidget {
  final int rating;
  final double size;
  const StarRating({super.key, required this.rating, this.size = 17});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$rating out of 5 stars',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= 5; i++)
            Icon(i <= rating ? Icons.star : Icons.star_border, size: size, color: i <= rating ? const Color(0xFFE0A100) : AppColors.lineStrong),
        ],
      ),
    );
  }
}

class _SimilarCars extends StatelessWidget {
  final Future<List<ListingDetail>>? future;
  const _SimilarCars({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ListingDetail>>(
      future: future,
      builder: (context, snap) {
        final items = snap.data ?? const <ListingDetail>[];
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle('More from this brand'),
            ListingCollection(
              listings: items,
              maxColumns: 3,
              onOpen: (l) => Navigator.of(context).pushNamed(AppRoutes.carDetails(l.id, l.title)),
            ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Gallery with a full-screen, zoomable viewer
// ---------------------------------------------------------------------------

class _Gallery extends StatefulWidget {
  final List<CarMedia> media;
  final String title;
  final bool edgeToEdge;
  const _Gallery({required this.media, required this.title, this.edgeToEdge = false});

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(int index, int count) {
    if (index < 0 || index >= count) return;
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _controller.jumpToPage(index);
    } else {
      _controller.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _openViewer(List<CarMedia> media) {
    Navigator.of(context).push(PageRouteBuilder<void>(
      opaque: true,
      pageBuilder: (_, _, _) => _PhotoViewer(media: media, initial: _index, title: widget.title),
      transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media.inDisplayOrder.where((m) => m.mediaType == MediaType.image).toList();
    final radius = widget.edgeToEdge ? BorderRadius.zero : BorderRadius.circular(AppRadii.lg);
    if (media.isEmpty) {
      return ClipRRect(
        borderRadius: radius,
        child: const AspectRatio(aspectRatio: 16 / 10, child: PhotoFallback(label: 'The seller has not added photos yet')),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: radius,
          child: AspectRatio(
            aspectRatio: widget.edgeToEdge ? 4 / 3 : 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: media.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _openViewer(media),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.zoomIn,
                      child: _Slide(media: media[i], label: '${widget.title}, photo ${i + 1} of ${media.length}'),
                    ),
                  ),
                ),
                if (media.length > 1 && !widget.edgeToEdge) ...[
                  Positioned(
                    left: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _RoundButton(icon: Icons.chevron_left, label: 'Previous photo', onTap: _index == 0 ? null : () => _goTo(_index - 1, media.length))),
                  ),
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _RoundButton(
                        icon: Icons.chevron_right,
                        label: 'Next photo',
                        onTap: _index >= media.length - 1 ? null : () => _goTo(_index + 1, media.length),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xCC0A1422), borderRadius: BorderRadius.circular(AppRadii.xs)),
                    child: Text('${_index + 1} / ${media.length}', style: AppText.figures(12.5, color: Colors.white)),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _RoundButton(icon: Icons.fullscreen, label: 'View photos full screen', onTap: () => _openViewer(media), small: true),
                ),
              ],
            ),
          ),
        ),
        if (media.length > 1 && !widget.edgeToEdge) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) => Semantics(
                button: true,
                selected: i == _index,
                label: 'Photo ${i + 1}',
                child: InkWell(
                  onTap: () => _goTo(i, media.length),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Container(
                    width: 92,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: i == _index ? AppColors.ink : Colors.transparent, width: 2),
                    ),
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadii.xs),
                      child: NetworkPhoto(url: media[i].thumbnailAbsoluteUrl(ApiConfig.baseUrl), cacheWidth: 200),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool small;
  const _RoundButton({required this.icon, required this.label, required this.onTap, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: onTap == null ? Colors.white54 : Colors.white,
        shape: const CircleBorder(),
        elevation: 1,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(small ? 7 : 9),
            child: Icon(icon, color: AppColors.ink, size: small ? 20 : 24, semanticLabel: label),
          ),
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final CarMedia media;
  final String label;
  const _Slide({required this.media, required this.label});

  @override
  Widget build(BuildContext context) {
    final url = media.absoluteUrl(ApiConfig.baseUrl);
    // Photos come in many shapes. Show the whole car (contain) over a
    // blurred copy of the same image so there are never empty bands.
    return Stack(
      fit: StackFit.expand,
      children: [
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Image.network(
            url,
            fit: BoxFit.cover,
            cacheWidth: 1280,
            excludeFromSemantics: true,
            errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.surfaceMuted),
          ),
        ),
        const ColoredBox(color: Color(0x1A000000)),
        NetworkPhoto(url: url, fit: BoxFit.contain, cacheWidth: 1280, semanticLabel: label),
      ],
    );
  }
}

class _PhotoViewer extends StatefulWidget {
  final List<CarMedia> media;
  final int initial;
  final String title;
  const _PhotoViewer({required this.media, required this.initial, required this.title});

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _controller = PageController(initialPage: widget.initial);
  late int _index = widget.initial;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _go(int i) {
    if (i < 0 || i >= widget.media.length) return;
    _controller.animateToPage(i, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _go(_index - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _go(_index + 1),
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: const Color(0xFF05090F),
          body: SafeArea(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: widget.media.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: NetworkPhoto(
                        url: widget.media[i].absoluteUrl(ApiConfig.baseUrl),
                        fit: BoxFit.contain,
                        semanticLabel: '${widget.title}, photo ${i + 1} of ${widget.media.length}',
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  right: 8,
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '${_index + 1} of ${widget.media.length}',
                            style: AppText.figures(14, color: Colors.white),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                if (widget.media.length > 1) ...[
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _RoundButton(icon: Icons.chevron_left, label: 'Previous photo', onTap: _index == 0 ? null : () => _go(_index - 1))),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _RoundButton(
                        icon: Icons.chevron_right,
                        label: 'Next photo',
                        onTap: _index >= widget.media.length - 1 ? null : () => _go(_index + 1),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailsSkeleton extends StatelessWidget {
  const _DetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isExpanded(context);
    final gallery = const AspectRatio(aspectRatio: 16 / 10, child: SkeletonBox(radius: AppRadii.lg));
    final panel = const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 28, width: 220),
        SizedBox(height: 10),
        SkeletonBox(height: 16, width: 160),
        SizedBox(height: 22),
        SkeletonBox(height: 34, width: 200),
        SizedBox(height: 24),
        SkeletonBox(height: 50),
        SizedBox(height: 10),
        SkeletonBox(height: 48),
      ],
    );
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: PageContainer(
        verticalPadding: 28,
        child: wide
            ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: gallery),
                const SizedBox(width: 32),
                SizedBox(width: 360, child: panel),
              ])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [gallery, const SizedBox(height: 20), panel]),
      ),
    );
  }
}
