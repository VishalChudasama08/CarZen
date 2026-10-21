import 'dart:math' as math;

import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/auth_gate.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/services/service_catalog_api.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_logo.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/listing_card.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Budget brackets in lakh, matching how Indian buyers shop for cars.
const _budgets = <(String, num?, num?)>[
  ('Under ₹5 lakh', null, 500000),
  ('₹5-10 lakh', 500000, 1000000),
  ('₹10-20 lakh', 1000000, 2000000),
  ('Above ₹20 lakh', 2000000, null),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  final _catalog = CatalogService();
  final _market = MarketplaceService();
  final _services = ServiceCatalogApi();
  final _session = SessionController.instance;

  late Future<_LatestCars> _latest;
  late Future<List<CatalogBrand>> _brands;
  late Future<List<ServiceOffering>> _workshop;
  Set<int> _favoriteCarIds = {};

  @override
  void initState() {
    super.initState();
    _load();
    _initSession();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    _latest = _market.listPublicListings(page: 1, limit: 8).then((page) async {
      final details = await _market.expandWithCarDetails(page.data);
      return _LatestCars(details, page.pagination.total);
    });
    _brands = _catalog.listBrands(limit: 24, isActive: true).then((p) => p.data);
    _workshop = _services.list(limit: 4).then((p) => p.data.where((s) => s.isActive).toList());
  }

  Future<void> _initSession() async {
    await _session.refresh();
    if (!mounted) return;
    if (_session.isAdmin) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.admin, (r) => false);
      return;
    }
    if (_session.isLoggedIn) _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _market.listFavorites();
      if (mounted) setState(() => _favoriteCarIds = favorites.map((f) => f.carId).toSet());
    } catch (_) {
      // Saved-state hearts are a convenience; the page works without them.
    }
  }

  Future<void> _toggleFavorite(int carId, bool value) async {
    if (!await AuthGate.requireAuthenticated(context)) return;
    setState(() => _favoriteCarIds = value ? {..._favoriteCarIds, carId} : _favoriteCarIds.difference({carId}));
    try {
      if (value) {
        await _market.addFavorite(carId);
      } else {
        await _market.removeFavorite(carId);
      }
      if (mounted) showAppSnack(context, value ? 'Saved to your cars' : 'Removed from saved cars');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _favoriteCarIds = value ? _favoriteCarIds.difference({carId}) : {..._favoriteCarIds, carId});
      showAppSnack(context, e.message, error: true);
    }
  }

  void _search() {
    final q = _searchController.text.trim();
    Navigator.of(context).pushNamed(AppRoutes.browseWith(search: q.isEmpty ? null : q));
  }

  void _open(ListingDetail l) => Navigator.of(context).pushNamed(AppRoutes.carDetails(l.id, l.title));

  Future<void> _refresh() async {
    setState(_load);
    await Future.wait([_latest, _brands, _workshop].map((f) => f.catchError((_) => Object())));
    if (_session.isLoggedIn) await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final compact = width < Breakpoints.medium;
    return AppScaffold(
      section: NavSection.home,
      showBottomNav: true,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (compact)
                _Hero(controller: _searchController, onSearch: _search, latest: _latest, onOpen: _open, fullBleed: true)
              else
                PageContainer(
                  verticalPadding: 24,
                  bottomPadding: 0,
                  child: _Hero(controller: _searchController, onSearch: _search, latest: _latest, onOpen: _open),
                ),
              PageContainer(
                verticalPadding: compact ? 28 : 48,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SectionTitle(
                      'Just listed',
                      subtitle: 'The newest cars on CarZen.',
                      trailing: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.browse),
                        child: const Text('See all cars'),
                      ),
                    ),
                    _latestCars(),
                    SizedBox(height: compact ? 36 : 56),
                    _brandSection(),
                    SizedBox(height: compact ? 36 : 56),
                    _WorkshopBand(services: _workshop),
                    SizedBox(height: compact ? 20 : 24),
                    const _SellBand(),
                  ],
                ),
              ),
              const _Footer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _latestCars() {
    return FutureBuilder<_LatestCars>(
      future: _latest,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) return const ListingCollectionSkeleton(count: 4);
        if (snap.hasError) {
          return SurfaceFrame(
            child: ApiErrorView(error: snap.error!, compact: true, onRetry: () => setState(_load), fallback: 'Cars could not be loaded.'),
          );
        }
        final cars = snap.data!.cars;
        if (cars.isEmpty) {
          return SurfaceFrame(
            child: EmptyStateView(
              compact: true,
              icon: Icons.directions_car_outlined,
              title: 'No cars for sale yet',
              message: 'Listings appear here as soon as our team approves them. Have a car to sell?',
              action: FilledButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sell), child: const Text('Sell your car')),
            ),
          );
        }
        return ListingCollection(
          listings: cars,
          favoriteCarIds: _favoriteCarIds,
          onOpen: _open,
          onFavorite: (l, v) => _toggleFavorite(l.car.id, v),
        );
      },
    );
  }

  Widget _brandSection() {
    return FutureBuilder<List<CatalogBrand>>(
      future: _brands,
      builder: (context, snap) {
        final brands = snap.data ?? const <CatalogBrand>[];
        if (snap.connectionState == ConnectionState.done && brands.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle('Shop by brand'),
            if (snap.connectionState != ConnectionState.done)
              SizedBox(
                height: 104,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 8,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (_, __) => const SizedBox(
                    width: 76,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SkeletonBox(width: 64, height: 64, radius: 32),
                        SizedBox(height: 6),
                        SkeletonBox(width: 52, height: 12),
                      ],
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                height: 104,
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  scrollDirection: Axis.horizontal,
                  itemCount: brands.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final b = brands[index];
                    return _BrandButton(
                      brand: b,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.browseWith(brandId: b.id)),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LatestCars {
  final List<ListingDetail> cars;
  final int total;
  const _LatestCars(this.cars, this.total);
}

/// White frame for in-section empty/error states.
class SurfaceFrame extends StatelessWidget {
  final Widget child;
  const SurfaceFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: child,
      );
}

// ---------------------------------------------------------------------------
// Hero: search on the left, the latest real cars on the right.
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final Future<_LatestCars> latest;
  final void Function(ListingDetail) onOpen;
  final bool fullBleed;

  const _Hero({required this.controller, required this.onSearch, required this.latest, required this.onOpen, this.fullBleed = false});

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final wide = width >= 960;
    final compact = width < Breakpoints.medium;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            'Find a used car\nyou can trust.',
            style: AppText.heading(compact ? 30 : (wide ? 46 : 40), color: Colors.white, height: 1.06, weight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 14),
        FutureBuilder<_LatestCars>(
          future: latest,
          builder: (context, snap) {
            final total = snap.data?.total;
            final line = total == null || total == 0
                ? 'Every listing is reviewed by our team before it goes live.'
                : '${formatCount(total)} ${total == 1 ? 'car' : 'cars'} for sale right now. Every listing is reviewed by our team before it goes live.';
            return ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Text(line, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 16, height: 1.5)),
            );
          },
        ),
        const SizedBox(height: 24),
        _SearchField(controller: controller, onSearch: onSearch, compact: compact),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final b in _budgets)
              _DarkChip(
                label: b.$1,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.browseWith(minPrice: b.$2, maxPrice: b.$3)),
              ),
          ],
        ),
      ],
    );

    final mosaic = FutureBuilder<_LatestCars>(
      future: latest,
      builder: (context, snap) {
        final withPhotos = (snap.data?.cars ?? const <ListingDetail>[])
            .where((l) => l.car.media.cover != null)
            .take(3)
            .toList();
        if (snap.connectionState != ConnectionState.done) {
          return const _MosaicSkeleton();
        }
        if (withPhotos.isEmpty) return const _HeroArt();
        return _Mosaic(listings: withPhotos, onOpen: onOpen);
      },
    );

    final pad = compact ? const EdgeInsets.fromLTRB(16, 28, 16, 28) : EdgeInsets.all(wide ? 48 : 36);
    final body = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex: 11, child: text),
              const SizedBox(width: 40),
              Expanded(flex: 10, child: SizedBox(height: 380, child: mosaic)),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              text,
              if (!compact) ...[const SizedBox(height: 28), SizedBox(height: 220, child: mosaic)],
            ],
          );

    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: fullBleed ? null : BorderRadius.circular(AppRadii.xl),
      ),
      child: body,
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;
  final bool compact;
  const _SearchField({required this.controller, required this.onSearch, required this.compact});

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      onSubmitted: (_) => onSearch(),
      style: const TextStyle(fontSize: 15.5),
      decoration: const InputDecoration(
        hintText: 'Brand or model, e.g. Creta',
        prefixIcon: Icon(Icons.search),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.symmetric(vertical: 16),
      ),
    );
    return Semantics(
      label: 'Search cars',
      container: true,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.fromLTRB(4, 4, 6, 4),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(AppRadii.md)),
        child: Row(
          children: [
            Expanded(child: field),
            ElevatedButton(
              onPressed: onSearch,
              style: ElevatedButton.styleFrom(minimumSize: Size(compact ? 64 : 112, 46)),
              child: compact ? const Icon(Icons.arrow_forward, semanticLabel: 'Search') : const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DarkChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        hoverColor: Colors.white.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5)),
        ),
      ),
    );
  }
}

class _Mosaic extends StatelessWidget {
  final List<ListingDetail> listings;
  final void Function(ListingDetail) onOpen;
  const _Mosaic({required this.listings, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    Widget tile(ListingDetail l, {bool big = false}) => _MosaicTile(listing: l, big: big, onTap: () => onOpen(l));
    if (listings.length == 1) return tile(listings.first, big: true);
    if (listings.length == 2) {
      return Row(children: [
        Expanded(child: tile(listings[0], big: true)),
        const SizedBox(width: 12),
        Expanded(child: tile(listings[1])),
      ]);
    }
    return Row(
      children: [
        Expanded(flex: 3, child: tile(listings[0], big: true)),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Column(children: [
            Expanded(child: tile(listings[1])),
            const SizedBox(height: 12),
            Expanded(child: tile(listings[2])),
          ]),
        ),
      ],
    );
  }
}

class _MosaicTile extends StatelessWidget {
  final ListingDetail listing;
  final bool big;
  final VoidCallback onTap;
  const _MosaicTile({required this.listing, required this.big, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final car = listing.car;
    final url = car.media.cover?.absoluteUrl(ApiConfig.baseUrl);
    return Semantics(
      button: true,
      label: '${car.manufacturingYear} ${car.brandName} ${car.modelName}, ${formatLakh(listing.askingPrice)}',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Material(
          color: AppColors.inkSoft,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetworkPhoto(url: url, cacheWidth: big ? 640 : 360),
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: _Sticker(
                    price: formatLakh(listing.askingPrice),
                    caption: big ? '${car.manufacturingYear} ${car.brandName} ${car.modelName}' : null,
                    small: !big,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Windshield price sticker - the one decorative flourish on the page.
class _Sticker extends StatelessWidget {
  final String price;
  final String? caption;
  final bool small;
  const _Sticker({required this.price, this.caption, this.small = false});

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Transform.rotate(
      angle: reduce ? 0 : -math.pi / 90,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: small ? 9 : 12, vertical: small ? 5 : 8),
        decoration: BoxDecoration(
          color: AppColors.plate,
          borderRadius: BorderRadius.circular(AppRadii.xs),
          boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(price, style: AppText.price(small ? 13 : 19, color: AppColors.ink, weight: FontWeight.w800)),
            if (caption != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(caption!, style: const TextStyle(color: AppColors.ink, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
      ),
    );
  }
}

class _MosaicSkeleton extends StatelessWidget {
  const _MosaicSkeleton();

  @override
  Widget build(BuildContext context) {
    Widget block() => Container(
          decoration: BoxDecoration(color: AppColors.inkSoft, borderRadius: BorderRadius.circular(AppRadii.lg)),
        );
    return Row(children: [
      Expanded(flex: 3, child: block()),
      const SizedBox(width: 12),
      Expanded(flex: 2, child: Column(children: [Expanded(child: block()), const SizedBox(height: 12), Expanded(child: block())])),
    ]);
  }
}

/// Shown instead of photos when no listing has one yet.
class _HeroArt extends StatelessWidget {
  const _HeroArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.inkSoft, borderRadius: BorderRadius.circular(AppRadii.lg)),
      alignment: Alignment.center,
      child: const AppLogo(height: 72, markOnly: true, onDark: true),
    );
  }
}

// ---------------------------------------------------------------------------
// Sections
// ---------------------------------------------------------------------------

class _BrandButton extends StatelessWidget {
  final CatalogBrand brand;
  final VoidCallback onTap;
  const _BrandButton({required this.brand, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final logoUrl = ApiConfig.mediaUrl(brand.logoUrl);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 76,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
                boxShadow: AppShadows.card,
              ),
              child: ClipOval(
                child: logoUrl != null && logoUrl.isNotEmpty
                    ? Image.network(
                        logoUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stack) => const Icon(
                          Icons.directions_car_filled_outlined,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                      )
                    : const Icon(
                        Icons.directions_car_filled_outlined,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              brand.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopBand extends StatelessWidget {
  final Future<List<ServiceOffering>> services;
  const _WorkshopBand({required this.services});

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final wide = width >= 900;
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CarZen Workshop', style: AppText.heading(wide ? 28 : 23)),
        const SizedBox(height: 10),
        const Text(
          'Book a service in a few taps. Choose the work, pick a time slot, and follow the job from booked to done. Pay online or at the counter.',
          style: TextStyle(fontSize: 15, height: 1.55, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 20),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.serviceBook),
            child: const Text('Book a service'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.services),
            child: const Text('See all services'),
          ),
        ]),
      ],
    );
    final list = FutureBuilder<List<ServiceOffering>>(
      future: services,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Column(children: [for (var i = 0; i < 3; i++) const Padding(padding: EdgeInsets.only(bottom: 8), child: SkeletonBox(height: 56))]);
        }
        final items = snap.data ?? const <ServiceOffering>[];
        if (items.isEmpty) return const SizedBox.shrink();
        return Container(
          decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(AppRadii.md)),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0) const Divider(indent: 16, endIndent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  title: Text(items[i].name),
                  subtitle: items[i].durationMinutes == null ? null : Text('About ${formatDuration(items[i].durationMinutes!)}'),
                  trailing: Text(formatInr(items[i].price), style: AppText.price(15)),
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.serviceBook, arguments: [items[i].id]),
                ),
              ],
            ],
          ),
        );
      },
    );
    return Container(
      padding: EdgeInsets.all(wide ? 36 : 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.divider),
      ),
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: intro),
              const SizedBox(width: 40),
              Expanded(flex: 6, child: list),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [intro, const SizedBox(height: 24), list]),
    );
  }
}

class _SellBand extends StatelessWidget {
  const _SellBand();

  static const _steps = <(String, String)>[
    ('Add your car', 'Details, photos and features. Takes about ten minutes.'),
    ('We review it', 'Our team checks the details before anything goes live.'),
    ('Publish and sell', 'Set your price, answer buyers and accept an order.'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final wide = width >= 900;
    final steps = [
      for (var i = 0; i < _steps.length; i++)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.plate, borderRadius: BorderRadius.circular(AppRadii.xs)),
              child: Text('${i + 1}', style: AppText.figures(14, weight: FontWeight.w700, color: AppColors.ink)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_steps[i].$1, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(_steps[i].$2, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13.5, height: 1.45)),
                ],
              ),
            ),
          ],
        ),
    ];
    final intro = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selling your car?', style: AppText.heading(wide ? 28 : 23, color: Colors.white)),
        const SizedBox(height: 10),
        const Text(
          'List it for free. Not sure what to ask for it? Get a price estimate first.',
          style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 15, height: 1.55),
        ),
        const SizedBox(height: 20),
        Wrap(spacing: 10, runSpacing: 10, children: [
          ElevatedButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.sellNew), child: const Text('Start selling')),
          OutlinedButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.priceCheck),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: const Text('Check my car\'s price'),
          ),
        ]),
      ],
    );
    return Container(
      padding: EdgeInsets.all(wide ? 36 : 20),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadii.xl)),
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: intro),
              const SizedBox(width: 40),
              Expanded(
                flex: 6,
                child: Column(children: [for (final s in steps) Padding(padding: const EdgeInsets.only(bottom: 18), child: s)]),
              ),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              intro,
              const SizedBox(height: 24),
              for (final s in steps) Padding(padding: const EdgeInsets.only(bottom: 16), child: s),
            ]),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final wide = width >= 760;
    Widget column(String title, List<(String, String)> links) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 14)),
            const SizedBox(height: 8),
            for (final l in links)
              InkWell(
                onTap: () => Navigator.of(context).pushNamed(l.$2),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(l.$1, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ),
              ),
          ],
        );
    final cols = [
      column('Buy', [('All cars', AppRoutes.browse), ('Saved cars', AppRoutes.favorites)]),
      column('Sell', [('Sell your car', AppRoutes.sellNew), ('Price check', AppRoutes.priceCheck), ('My listings', AppRoutes.sell)]),
      column('Workshop', [('Services', AppRoutes.services), ('Book a service', AppRoutes.serviceBook), ('My bookings', AppRoutes.serviceRequests)]),
      column('Account', [('Log in', AppRoutes.login), ('Create account', AppRoutes.register), ('My account', AppRoutes.account)]),
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(color: AppColors.surface),
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
        child: PageContainer(
          verticalPadding: 36,
          bottomPadding: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              wide
                  ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Expanded(
                        flex: 3,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const AppLogo(height: 30),
                          const SizedBox(height: 12),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: const Text(
                              'Buy, sell and service your car in one place.',
                              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                            ),
                          ),
                        ]),
                      ),
                      for (final c in cols) Expanded(flex: 2, child: c),
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const AppLogo(height: 28),
                      const SizedBox(height: 20),
                      Wrap(spacing: 40, runSpacing: 20, children: [for (final c in cols) SizedBox(width: 140, child: c)]),
                    ]),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 16),
              Text('© ${DateTime.now().year} CarZen', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }
}
