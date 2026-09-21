import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/auth_gate.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/services/order_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/listing_dialogs.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// One public listing in full — `GET /v1/listings/{listingId}`.
///
/// Browsing is public. Favorite, purchase request, inquiry and report go
/// through [AuthGate], which validates the session only at that moment.
class CarDetailsScreen extends StatefulWidget {
  final int listingId;
  const CarDetailsScreen({super.key, required this.listingId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final _marketplaceService = MarketplaceService();
  final _orderService = OrderService();
  final _engagementService = EngagementService();
  final _authService = AuthService();

  late Future<ListingDetail> _future;
  bool _isFavorite = false;
  bool _favoriteBusy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _marketplaceService.getPublicListing(widget.listingId).then((listing) {
      _syncFavorite(listing.car.id);
      return listing;
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Marks the heart correctly for signed-in users. Silent for visitors and on
  /// failure: it is a nicety, not something that should block the page.
  Future<void> _syncFavorite(int carId) async {
    if (!await _authService.hasStoredToken()) return;
    try {
      final favorites = await _marketplaceService.listFavorites();
      if (!mounted) return;
      setState(() => _isFavorite = favorites.any((f) => f.carId == carId));
    } on ApiException {
      // Ignored on purpose.
    }
  }

  Future<void> _toggleFavorite(int carId) async {
    final wantFavorite = !_isFavorite;
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    await _syncFavorite(carId);
    if (!mounted || _isFavorite == wantFavorite) return;
    setState(() => _favoriteBusy = true);
    try {
      if (wantFavorite) {
        await _marketplaceService.addFavorite(carId);
      } else {
        await _marketplaceService.removeFavorite(carId);
      }
      if (!mounted) return;
      setState(() => _isFavorite = wantFavorite);
    } on ApiException catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _favoriteBusy = false);
    }
  }

  Future<void> _placeOrder(ListingDetail listing) async {
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    final result = await showOrderRequestDialog(context, amount: listing.askingPrice);
    if (result == null) return;
    try {
      await _orderService.createOrder(listingId: listing.id, amount: listing.askingPrice, notes: result.note);
      if (!mounted) return;
      _snack('Purchase request sent to the seller.');
      Navigator.of(context).pushNamed(AppRoutes.orders);
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _askSeller(ListingDetail listing) async {
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    final result = await showInquiryDialog(context, defaultSubject: 'About: ${listing.title}');
    if (result == null) return;
    try {
      final inquiry = await _engagementService.createInquiry(
        listingId: listing.id,
        subject: result.subject,
        message: result.message,
      );
      if (!mounted) return;
      _snack('Your message was sent to the seller.');
      Navigator.of(context).pushNamed(AppRoutes.inquiry(inquiry.id));
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  Future<void> _report(ListingDetail listing) async {
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    final result = await showReportDialog(context);
    if (result == null) return;
    try {
      await _engagementService.reportListing(
        listingId: listing.id,
        reason: result.reason,
        description: result.description,
      );
      _snack('Thanks - your report was sent to our team.');
    } on ApiException catch (e) {
      _snack(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.buy, title: 'Car details'),
      body: SafeArea(
        child: FutureBuilder<ListingDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading car details...');
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              if (error is ApiException && error.statusCode == 404) {
                return EmptyStateView(
                  icon: Icons.car_crash_outlined,
                  title: 'This car is no longer available',
                  message: 'The listing may have been sold or removed.',
                  action: FilledButton(
                    onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.browse, (r) => false),
                    child: const Text('Browse other cars'),
                  ),
                );
              }
              final message = error is ApiException ? error.message : 'Could not load this listing.';
              return ErrorStateView(message: message, onRetry: () => setState(_load));
            }
            return _buildBody(context, snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ListingDetail listing) {
    final car = listing.car;
    final summary = _SummaryCard(
      listing: listing,
      isFavorite: _isFavorite,
      favoriteBusy: _favoriteBusy,
      onFavorite: () => _toggleFavorite(car.id),
      onOrder: () => _placeOrder(listing),
      onAsk: () => _askSeller(listing),
      onReport: () => _report(listing),
    );
    final details = <Widget>[
      _SectionTitle('Specifications'),
      _SpecsSection(car: car),
      if (car.features.isNotEmpty) ...[
        const SizedBox(height: 24),
        _SectionTitle('Features'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in car.features)
              Chip(
                label: Text(f.featureValue == null ? f.featureName : '${f.featureName}: ${f.featureValue}'),
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.divider),
              ),
          ],
        ),
      ],
      if (listing.description != null && listing.description!.isNotEmpty) ...[
        const SizedBox(height: 24),
        _SectionTitle('Description'),
        Text(listing.description!, style: const TextStyle(color: AppColors.textSecondary, height: 1.55)),
      ],
    ];

    if (Breakpoints.isExpanded(context)) {
      return SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [_Gallery(media: car.media), const SizedBox(height: 28), ...details],
                    ),
                  ),
                  const SizedBox(width: 28),
                  SizedBox(width: 380, child: summary),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Gallery(media: car.media),
                const SizedBox(height: 16),
                summary,
                const SizedBox(height: 24),
                ...details,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: Theme.of(context).textTheme.titleMedium),
      );
}

/// Title, price and every action a visitor can take on the listing.
class _SummaryCard extends StatelessWidget {
  final ListingDetail listing;
  final bool isFavorite;
  final bool favoriteBusy;
  final VoidCallback onFavorite;
  final VoidCallback onOrder;
  final VoidCallback onAsk;
  final VoidCallback onReport;

  const _SummaryCard({
    required this.listing,
    required this.isFavorite,
    required this.favoriteBusy,
    required this.onFavorite,
    required this.onOrder,
    required this.onAsk,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final car = listing.car;
    final marketPrice = car.expectedMarketPrice;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(listing.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            '${car.brandName} ${car.modelName} ${car.variantName}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text('${car.city}, ${car.state}', style: const TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            formatInr(listing.askingPrice),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 30, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Pill(listing.negotiable ? 'Negotiable' : 'Fixed price'),
              _Pill(listing.listingType.label),
              if (marketPrice != null && marketPrice != listing.askingPrice) _Pill('Market value ${formatInr(marketPrice)}'),
              if (listing.viewsCount != null) _Pill('${formatCount(listing.viewsCount!)} views'),
            ],
          ),
          const Divider(height: 32, color: AppColors.divider),
          FilledButton.icon(
            onPressed: onOrder,
            icon: const Icon(Icons.shopping_cart_checkout_outlined),
            label: const Text('Send purchase request'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onAsk,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Ask the seller'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: favoriteBusy ? null : onFavorite,
            icon: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: AppColors.favorite,
            ),
            label: Text(isFavorite ? 'Saved to favorites' : 'Save to favorites'),
          ),
          const SizedBox(height: 12),
          const Text(
            'Sending a request does not take a payment.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          TextButton.icon(
            onPressed: onReport,
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: const Text('Report this listing'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill(this.text);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      );
}

/// Swipeable photos with arrows, page dots and a thumbnail strip.
class _Gallery extends StatefulWidget {
  final List<CarMedia> media;
  const _Gallery({required this.media});

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

  void _goTo(int index) {
    if (index < 0 || index >= widget.media.length) return;
    _controller.animateToPage(index, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final media = widget.media;
    if (media.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            color: AppColors.divider,
            alignment: Alignment.center,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car, size: 56, color: AppColors.textSecondary),
                SizedBox(height: 8),
                Text('No photos yet', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: AspectRatio(
            aspectRatio: 16 / 10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: media.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _Slide(media: media[i]),
                ),
                if (media.length > 1) ...[
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _ArrowButton(icon: Icons.chevron_left_rounded, onTap: () => _goTo(_index - 1))),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(child: _ArrowButton(icon: Icons.chevron_right_rounded, onTap: () => _goTo(_index + 1))),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < media.length; i++)
                          Container(
                            width: i == _index ? 18 : 7,
                            height: 7,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i == _index ? Colors.white : Colors.white70,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (media.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 62,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: media.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => InkWell(
                onTap: () => _goTo(i),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: i == _index ? AppColors.secondary : AppColors.divider, width: 2),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _Thumb(media: media[i]),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.black38,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, color: Colors.white, size: 26)),
        ),
      );
}

class _Slide extends StatelessWidget {
  final CarMedia media;
  const _Slide({required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.mediaType != MediaType.image) {
      final isVideo = media.mediaType == MediaType.video;
      return Container(
        color: AppColors.divider,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isVideo ? Icons.videocam_outlined : Icons.description_outlined, size: 44),
            const SizedBox(height: 8),
            Text(isVideo ? 'Video available from the seller' : 'Document available from the seller'),
          ],
        ),
      );
    }
    return Image.network(
      media.absoluteUrl(ApiConfig.baseUrl),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Container(
              color: AppColors.divider,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2.4),
            ),
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.divider,
        alignment: Alignment.center,
        child: const Icon(Icons.broken_image_outlined, size: 40, color: AppColors.textSecondary),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final CarMedia media;
  const _Thumb({required this.media});

  @override
  Widget build(BuildContext context) {
    if (media.mediaType != MediaType.image) {
      return Container(
        color: AppColors.divider,
        child: Icon(media.mediaType == MediaType.video ? Icons.videocam_outlined : Icons.description_outlined),
      );
    }
    final url = (media.thumbnailUrl != null && media.thumbnailUrl!.isNotEmpty) ? media.thumbnailUrl! : media.mediaUrl;
    final absolute = url.startsWith('http') ? url : '${ApiConfig.baseUrl}$url';
    return Image.network(
      absolute,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: AppColors.divider),
    );
  }
}

class _SpecsSection extends StatelessWidget {
  final ListingCar car;
  const _SpecsSection({required this.car});

  @override
  Widget build(BuildContext context) {
    final specs = <({IconData icon, String label, String value})>[
      (icon: Icons.calendar_today_outlined, label: 'Year', value: '${car.manufacturingYear}'),
      if (car.registrationYear != null)
        (icon: Icons.assignment_outlined, label: 'Registered', value: '${car.registrationYear}'),
      (icon: Icons.speed_outlined, label: 'Driven', value: formatKm(car.mileageKm)),
      (icon: Icons.local_gas_station_outlined, label: 'Fuel', value: car.fuelType.label),
      (icon: Icons.settings_outlined, label: 'Transmission', value: car.transmission.label),
      if (car.engineCc != null) (icon: Icons.tune_outlined, label: 'Engine', value: '${formatCount(car.engineCc!)} cc'),
      if (car.horsepower != null) (icon: Icons.bolt_outlined, label: 'Power', value: '${formatCount(car.horsepower!)} hp'),
      if (car.bodyType != null) (icon: Icons.directions_car_outlined, label: 'Body', value: car.bodyType!.label),
      if (car.color != null) (icon: Icons.palette_outlined, label: 'Colour', value: car.color!),
      if (car.seatingCapacity != null)
        (icon: Icons.event_seat_outlined, label: 'Seats', value: '${car.seatingCapacity}'),
      if (car.ownershipType != null)
        (icon: Icons.badge_outlined, label: 'Ownership', value: car.ownershipType!.label)
      else if (car.ownerCount != null)
        (icon: Icons.person_outline, label: 'Owners', value: '${car.ownerCount}'),
      (icon: Icons.verified_outlined, label: 'Condition', value: car.condition.label),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 640 ? 3 : 2;
        final tileWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final spec in specs)
              Container(
                width: tileWidth,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Icon(spec.icon, color: AppColors.secondary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(spec.label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                          const SizedBox(height: 2),
                          Text(
                            spec.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
