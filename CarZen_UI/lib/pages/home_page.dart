import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/widgets/car_search_bar.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/hero_banner.dart';
import 'package:carzen_flutter/widgets/quick_filter_chips.dart';
import 'package:carzen_flutter/widgets/section_header.dart';
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
    _featuredFuture = _marketplaceService.listPublicListings(
      page: 1,
      limit: 8,
      brandId: _selectedBrand?.id,
      fuelType: _fuelFilter(),
      transmission: _transmissionFilter(),
      minPrice: price.min,
      maxPrice: price.max,
    ).then((page) => Future.wait(page.data.map((l) => _marketplaceService.getPublicListing(l.id))));
  }

  // void _loadFeatured() {
  //   _marketplaceService
  //       .getPublicListing(7)
  //       .then((listing) {
  //     print('DETAIL SUCCESS: ${listing.title}');
  //     print('CAR: ${listing.car.brandName} ${listing.car.modelName}');
  //   })
  //       .catchError((e) {
  //     print('DETAIL ERROR: $e');
  //   });
  // }

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
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


    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const CarZenNavBar(current: NavSection.home),

      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeroBanner(onExplorePressed: _handleExplore),
                      CarSearchBar(
                        controller: _searchController,
                        onSubmitted: _handleSearch,
                        onFilterTap: _handleExplore,
                      ),
                      const SizedBox(height: 14),
                      QuickFilterChips(filters: filters),
                      const SizedBox(height: 26),
                      SectionHeader(title: 'Featured Cars', onActionTap: _handleExplore),
                      SizedBox(
                        // Compact: one horizontally scrolling row. Expanded: a wrapping
                        // grid, so the height must follow the content.
                        height: Breakpoints.isExpanded(context) ? null : 246,
                        child: FutureBuilder<List<ListingDetail>>(
                          future: _featuredFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState != ConnectionState.done) {
                              return const LoadingView();
                            }
                            if (snapshot.hasError) {
                              final message = snapshot.error is ApiException
                                  ? (snapshot.error as ApiException).message
                                  : 'Could not load cars right now.';
                              return ErrorStateView(message: message, onRetry: () => setState(_loadFeatured));
                            }
                            final listings = snapshot.data!;
                            if (listings.isEmpty) {
                              return const EmptyStateView(
                                icon: Icons.directions_car_outlined,
                                title: 'No cars found',
                                message: 'Try different filters, or check back soon.',
                              );
                            }
                            Widget cardFor(ListingDetail listing, {double width = 220}) => ListingCard(
                              listing: listing,
                              width: width,
                              isFavorite: _favoriteCarIds.contains(listing.car.id),
                              onFavoriteToggle: (value) => _toggleFavorite(listing.car.id, value),
                              onTap: () => Navigator.of(context).pushNamed(AppRoutes.carDetails(listing.id)),
                            );
                            if (Breakpoints.isExpanded(context)) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [for (final listing in listings) cardFor(listing, width: 270)],
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              scrollDirection: Axis.horizontal,
                              itemCount: listings.length,
                              separatorBuilder: (_, __) => const SizedBox(width: 14),
                              itemBuilder: (context, index) => cardFor(listings[index]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 26),
                      const SectionHeader(title: 'Popular Brands', actionLabel: null),
                      FutureBuilder<List<CatalogBrand>>(
                        future: _brandsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                            return const SizedBox(height: 92, child: LoadingView());
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
