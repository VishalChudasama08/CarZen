import 'package:flutter/material.dart';
import '../data/dummy_cars.dart' show carCategories, quickFilterFuel, quickFilterPrices, quickFilterTransmission;
import '../models/car.dart' show CarBrand;
import '../models/catalog_models.dart';
import '../models/enums.dart';
import '../models/listing_models.dart';
import '../services/api_exception.dart';
import '../services/catalog_service.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_list.dart';
import '../widgets/car_search_bar.dart';
import '../widgets/category_list.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/listing_card.dart';
import '../widgets/quick_filter_chips.dart';
import '../widgets/section_header.dart';
import '../widgets/state_views.dart';
import 'browse_listings_screen.dart';
import 'car_details_screen.dart';
import 'profile_screen.dart';

/// CarZen Home page.
///
/// Featured Cars, Popular Brands, and the search/filter row are wired to
/// the real backend (`/v1/listings`, `/v1/car-brands`, favorites). The
/// "Browse by Category" row has no backing endpoint on the backend yet
/// (there's no `/v1/categories`), so it's left as the original static
/// display rather than inventing one — see [carCategories].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _catalogService = CatalogService();
  final _marketplaceService = MarketplaceService();

  Future<List<CatalogBrand>>? _brandsFuture;
  Future<List<ListingDetail>>? _featuredFuture;
  Set<int> _favoriteCarIds = {};

  List<CatalogBrand> _brands = [];
  CatalogBrand? _selectedBrand;
  String _selectedPrice = quickFilterPrices.first;
  String _selectedFuel = quickFilterFuel.first;
  String _selectedTransmission = quickFilterTransmission.first;

  @override
  void initState() {
    super.initState();
    _loadBrands();
    _loadFavorites();
    _loadFeatured();
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
      limit: 6,
      brandId: _selectedBrand?.id,
      fuelType: _fuelFilter(),
      transmission: _transmissionFilter(),
      minPrice: price.min,
      maxPrice: price.max,
    )
        .then((page) => Future.wait(page.data.map((l) => _marketplaceService.getPublicListing(l.id))));
  }

  Future<void> _toggleFavorite(int carId, bool value) async {
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

  void _handleSearch(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _selectedBrand = null;
        _loadFeatured();
      });
      return;
    }
    final match = _brands.where((b) => b.name.toLowerCase().contains(trimmed.toLowerCase())).toList();
    if (match.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching brand found. The backend only supports searching by brand name.')),
      );
      return;
    }
    setState(() {
      _selectedBrand = match.first;
      _loadFeatured();
    });
  }

  void _handleExplore() {
    final price = _priceRange();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => BrowseListingsScreen(
        brandId: _selectedBrand?.id,
        fuelType: _fuelFilter()?.apiValue,
        transmission: _transmissionFilter()?.apiValue,
        minPrice: price.min,
        maxPrice: price.max,
      ),
    ));
  }

  Future<void> _refreshAll() async {
    setState(() {
      _loadBrands();
      _loadFeatured();
    });
    await Future.wait([_brandsFuture!, _featuredFuture!, _loadFavorites()]);
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
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              CustomHomeAppBar(
                location: 'Ahmedabad, GJ',
                onLocationTap: () {},
                onNotificationTap: () {},
                onProfileTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
              ),
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
                height: 246,
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
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: listings.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final listing = listings[index];
                        return ListingCard(
                          listing: listing,
                          isFavorite: _favoriteCarIds.contains(listing.car.id),
                          onFavoriteToggle: (value) => _toggleFavorite(listing.car.id, value),
                          onTap: () => Navigator.of(context)
                              .push(MaterialPageRoute(builder: (_) => CarDetailsScreen(listingId: listing.id))),
                        );
                      },
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
                  final brands =
                      snapshot.data!.map((b) => CarBrand(name: b.name, logoUrl: b.logoUrl ?? '')).toList();
                  return BrandList(
                    brands: brands,
                    onBrandTap: (item) => setState(() {
                      _selectedBrand = _brands.firstWhere((b) => b.name == item.name);
                      _loadFeatured();
                    }),
                  );
                },
              ),
              const SizedBox(height: 26),
              const SectionHeader(title: 'Browse by Category', actionLabel: null),
              CategoryList(categories: carCategories, onCategoryTap: (category) {}),
            ],
          ),
        ),
      ),
    );
  }
}
