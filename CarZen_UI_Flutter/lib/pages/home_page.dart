import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/hero_banner.dart';
import 'package:carzen_flutter/widgets/quick_filter_chips.dart';
import 'package:carzen_flutter/widgets/section_header.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/widgets/brand_list.dart';
import 'package:carzen_flutter/widgets/listing_card.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/car.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/auth_gate.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  final TextEditingController _searchController = TextEditingController();
  final _catalogService = CatalogService();
  final _marketplaceService = MarketplaceService();
  final _authService = AuthService();
  final _session = SessionController.instance;

  Future<List<CatalogBrand>>? _brandsFuture;
  Future<List<ListingDetail>>? _featuredFuture;
  Set<int> _favoriteCarIds = {};
  bool _hasStoredToken = false;

  List<CatalogBrand> _brands = [];
  CatalogBrand? _selectedBrand;
  String _selectedPrice = quickFilterPrices.first;
  String _selectedFuel = quickFilterFuel.first;
  String _selectedTransmission = quickFilterTransmission.first;

  @override
  void initState() {
    super.initState();
    _session.refresh();
    _loadBrands();
    _loadFeatured();
    _loadLocalAuth();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadBrands() {
    _brandsFuture = _catalogService.listBrands(limit: 20).then((p) {
      _brands = p.data;
      return p.data;
    });
  }

  Future<void> _loadLocalAuth() async {
    final hasToken = await _authService.hasStoredToken();
    if (!mounted) return;
    setState(() => _hasStoredToken = hasToken);
    if (hasToken) _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await _marketplaceService.listFavorites();
      if (!mounted) return;
      setState(() => _favoriteCarIds = favorites.map((f) => f.carId).toSet());
    } catch (_) {
      // Favorites are a nice-to-have on Home — a failure here shouldn't
      // block the rest of the page from rendering.
    }
  }

  ({num? min, num? max}) _priceRange() {
    switch (_selectedPrice) {
      case 'Under 5L':
        return (min: null, max: 500000);
      case '5L - 10L':
        return (min: 500000, max: 1000000);
      case '10L - 20L':
        return (min: 1000000, max: 2000000);
      case '20L+':
        return (min: 2000000, max: null);
      default:
        return (min: null, max: null);
    }
  }

  FuelType? _fuelFilter() {
    if (_selectedFuel == quickFilterFuel.first) return null;
    try {
      return FuelTypeX.fromApi(_selectedFuel.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  TransmissionType? _transmissionFilter() {
    if (_selectedTransmission == quickFilterTransmission.first) return null;
    try {
      return TransmissionTypeX.fromApi(_selectedTransmission.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  void _loadFeatured() {
    final price = _priceRange();
    _featuredFuture = _marketplaceService
        .listPublicListings(
      page: 1,
      limit: 8,
      brandId: _selectedBrand?.id,
      fuelType: _fuelFilter(),
      transmission: _transmissionFilter(),
      minPrice: price.min,
      maxPrice: price.max,
    )
        .then((page) => _marketplaceService.expandWithCarDetails(page.data));
  }

  Future<void> _toggleFavorite(int carId, bool value) async {
    if (!await AuthGate.requireAuthenticated(context)) {
      if (mounted) _loadLocalAuth();
      return;
    }
    setState(() => _favoriteCarIds = value ? ({..._favoriteCarIds, carId}) : (_favoriteCarIds.difference({carId})));
    try {
      if (value) {
        await _marketplaceService.addFavorite(carId);
      } else {
        await _marketplaceService.removeFavorite(carId);
      }
    } on ApiException catch (e) {
      // Revert the optimistic update and let the user know.
      if (!mounted) return;
      setState(() => _favoriteCarIds = value ? (_favoriteCarIds.difference({carId})) : ({..._favoriteCarIds, carId}));
      showAppSnack(context, e.message, error: true);
    }
  }

  /// `GET /v1/listings?search=` matches brand, model, variant, registration
  /// number and VIN, so free-text search hands off to the Browse page.
  void _handleSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _selectedBrand = null;
        _loadFeatured();
      });
      return;
    }
    Navigator.of(context).pushNamed(AppRoutes.browseWith(search: trimmed));
  }

  void _handleExplore() {
    final price = _priceRange();
    Navigator.of(context).pushNamed(AppRoutes.browseWith(
      brandId: _selectedBrand?.id,
      fuelType: _fuelFilter()?.apiValue,
      transmission: _transmissionFilter()?.apiValue,
      minPrice: price.min,
      maxPrice: price.max,
    ));
  }

  Future<void> _refreshAll() async {
    setState(() {
      _loadBrands();
      _loadFeatured();
    });
    await Future.wait([_brandsFuture!, _featuredFuture!, if (_hasStoredToken) _loadFavorites()]);
  }


  @override
  Widget build(BuildContext context) {
    final brandOptions = ['Any Brand', ..._brands.map((b) => b.name)];
    final filters = [
      QuickFilter(
        label: 'Brand',
        icon: Icons.directions_car_outlined,
        value: _selectedBrand?.name ?? 'Any Brand',
        options: brandOptions,
        onChanged: (value) => setState(() {
          _selectedBrand = value == 'Any Brand' ? null : _brands.firstWhere((b) => b.name == value);
          _loadFeatured();
        }),
      ),
      QuickFilter(
        label: 'Price',
        icon: Icons.sell_outlined,
        value: _selectedPrice,
        options: quickFilterPrices,
        onChanged: (value) => setState(() {
          _selectedPrice = value;
          _loadFeatured();
        }),
      ),
      QuickFilter(
        label: 'Fuel',
        icon: Icons.local_gas_station_outlined,
        value: _selectedFuel,
        options: quickFilterFuel,
        onChanged: (value) => setState(() {
          _selectedFuel = value;
          _loadFeatured();
        }),
      ),
      QuickFilter(
        label: 'Transmission',
        icon: Icons.settings_outlined,
        value: _selectedTransmission,
        options: quickFilterTransmission,
        onChanged: (value) => setState(() {
          _selectedTransmission = value;
          _loadFeatured();
        }),
      ),
    ];

    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        final isAdmin = _session.isAdmin;
        return Scaffold(
          appBar: const CarZenNavBar(current: NavSection.home),
          bottomNavigationBar: const CarZenBottomBar(current: NavSection.home),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _refreshAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PageContainer(
                  verticalPadding: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeroBanner(
                        searchController: _searchController,
                        onSearch: _handleSearch,
                        onExplore: _handleExplore,
                        onFilterTap: _handleExplore,
                        onSell: isAdmin ? null : () => Navigator.of(context).pushNamed(AppRoutes.sell),
                        onServices: isAdmin ? null : () => Navigator.of(context).pushNamed(AppRoutes.services),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      QuickFilterChips(filters: filters),
                      const SizedBox(height: AppSpacing.section),
                      SectionHeader(
                        title: 'Featured cars',
                        subtitle: 'Fresh listings, ready to view.',
                        actionLabel: 'View all',
                        onActionTap: _handleExplore,
                      ),
                      _featured(context),
                      const SizedBox(height: AppSpacing.section),
                      const SectionHeader(title: 'Popular brands', subtitle: 'Tap a brand to narrow the featured cars.', actionLabel: null),
                      FutureBuilder<List<CatalogBrand>>(
                        future: _brandsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done) {
                            return const SizedBox(height: 100, child: LoadingView());
                          }
                          if (snapshot.hasError || !(snapshot.data?.isNotEmpty ?? false)) {
                            return const SizedBox.shrink();
                          }
                          final brands = snapshot.data!.map((b) => CarBrand(name: b.name, logoUrl: b.logoUrl ?? '')).toList();
                          return BrandList(
                            brands: brands,
                            onBrandTap: (item) => setState(() {
                              _selectedBrand = _brands.firstWhere((b) => b.name == item.name);
                              _loadFeatured();
                            }),
                          );
                        },
                      ),
                      if (!isAdmin) ...[
                        const SizedBox(height: AppSpacing.section),
                        _ServicesPromo(onTap: () => Navigator.of(context).pushNamed(AppRoutes.services)),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _featured(BuildContext context) {
    return FutureBuilder<List<ListingDetail>>(
      future: _featuredFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SkeletonGrid(count: 4, tileHeight: 360);
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 300,
            child: ApiErrorView(error: snapshot.error!, onRetry: () => setState(_loadFeatured), fallback: 'Could not load cars right now.'),
          );
        }
        final listings = snapshot.data!;
        if (listings.isEmpty) {
          return SizedBox(
            height: 280,
            child: EmptyStateView(
              icon: Icons.directions_car_outlined,
              title: 'No cars match these filters',
              message: 'Try different filters, or check back soon.',
              action: OutlinedButton(
                onPressed: () => setState(() {
                  _selectedBrand = null;
                  _selectedPrice = quickFilterPrices.first;
                  _selectedFuel = quickFilterFuel.first;
                  _selectedTransmission = quickFilterTransmission.first;
                  _loadFeatured();
                }),
                child: const Text('Clear filters'),
              ),
            ),
          );
        }
        final shown = Breakpoints.isCompact(context) ? listings.take(4).toList() : listings;
        return LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 18.0;
            final columns = (constraints.maxWidth / 270).floor().clamp(1, 4);
            final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final listing in shown)
                  ListingCard(
                    listing: listing,
                    width: width,
                    isFavorite: _favoriteCarIds.contains(listing.car.id),
                    onFavoriteToggle: (value) => _toggleFavorite(listing.car.id, value),
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.carDetails(listing.id)),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Invitation to the Services area, shown to non-admin visitors.
class _ServicesPromo extends StatelessWidget {
  final VoidCallback onTap;
  const _ServicesPromo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('CARZEN WORKSHOP', style: TextStyle(color: AppColors.cyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
        const SizedBox(height: 8),
        const Text(
          'Keep your car running like new.',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800, height: 1.15),
        ),
        const SizedBox(height: 8),
        const Text(
          'Pick the services you need, choose a time slot, and follow the progress from your phone.',
          style: TextStyle(color: AppColors.textOnDarkMuted, height: 1.45),
        ),
        const SizedBox(height: 18),
        ElevatedButton(onPressed: onTap, child: const Text('See services')),
      ],
    );
    return Container(
      padding: EdgeInsets.all(compact ? 22 : 36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.primarySoft]),
      ),
      child: compact
          ? text
          : Row(
              children: [
                Expanded(child: text),
                const SizedBox(width: 24),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(color: AppColors.cyan.withValues(alpha: 0.14), shape: BoxShape.circle),
                  child: const Icon(Icons.home_repair_service_rounded, size: 56, color: AppColors.cyan),
                ),
              ],
            ),
    );
  }
}
