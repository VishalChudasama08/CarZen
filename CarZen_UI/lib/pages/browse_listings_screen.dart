import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_filters.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/auth_gate.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/listing_card.dart';
import 'package:carzen_flutter/widgets/listing_filter_panel.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Buy / browse cars — the public `GET /v1/listings` with every filter the
/// backend supports (search, brand, model, fuel, transmission, condition,
/// price, year, mileage, city) plus sorting and paging.
///
/// Wide screens show the filters as a sidebar; narrow screens open them in a
/// bottom sheet from the Filters button.
class BrowseListingsScreen extends StatefulWidget {
  final int? brandId;
  final String? fuelType;
  final String? transmission;
  final num? minPrice;
  final num? maxPrice;
  final String? search;
  final String title;

  const BrowseListingsScreen({
    super.key,
    this.brandId,
    this.fuelType,
    this.transmission,
    this.minPrice,
    this.maxPrice,
    this.search,
    this.title = 'Explore Cars',
  });

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  static const int _pageSize = 12;

  final _marketplaceService = MarketplaceService();
  final _catalogService = CatalogService();
  final _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late ListingFilters _filters;
  List<CatalogBrand> _brands = const [];
  final Set<int> _favoriteCarIds = {};

  final List<ListingDetail> _listings = [];
  int _page = 1;
  int _totalPages = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;
  int _requestSeq = 0;

  @override
  void initState() {
    super.initState();
    _filters = ListingFilters(
      search: widget.search,
      brandId: widget.brandId,
      fuelType: FuelType.values.where((e) => e.name == widget.fuelType).firstOrNull,
      transmission: TransmissionType.values.where((e) => e.name == widget.transmission).firstOrNull,
      minPrice: widget.minPrice,
      maxPrice: widget.maxPrice,
    );
    _searchController.text = widget.search ?? '';
    _scroll.addListener(_onScroll);
    _loadBrands();
    _loadFavorites();
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scroll.hasClients && _scroll.position.pixels > _scroll.position.maxScrollExtent - 500) _loadMore();
  }

  Future<void> _loadBrands() async {
    try {
      final page = await _catalogService.listBrands(limit: 100, isActive: true);
      if (mounted) setState(() => _brands = page.data);
    } on ApiException {
      // The panel simply offers no brand list; other filters keep working.
    }
  }

  Future<void> _loadFavorites() async {
    if (!await _authService.hasStoredToken()) return;
    try {
      final favorites = await _marketplaceService.listFavorites();
      if (!mounted) return;
      setState(() {
        _favoriteCarIds
          ..clear()
          ..addAll(favorites.map((f) => f.carId));
      });
    } on ApiException {
      // Hearts just stay empty.
    }
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _requestSeq++;
    }
    final seq = _requestSeq;
    setState(() {
      if (reset) {
        _loading = true;
        _listings.clear();
        _total = 0;
        _totalPages = 1;
      } else {
        _loadingMore = true;
      }
      _error = null;
    });
    final f = _filters;
    try {
      final result = await _marketplaceService.listPublicListings(
        page: _page,
        limit: _pageSize,
        search: f.search,
        brandId: f.brandId,
        modelId: f.modelId,
        fuelType: f.fuelType,
        transmission: f.transmission,
        condition: f.condition,
        city: f.city,
        minPrice: f.minPrice,
        maxPrice: f.maxPrice,
        minYear: f.minYear,
        maxYear: f.maxYear,
        maxMileage: f.maxMileage,
        sortBy: f.sort,
      );
      // The list endpoint returns plain listings; the detail endpoint carries
      // the car snapshot the cards need.
      final details = await Future.wait(result.data.map((l) => _marketplaceService.getPublicListing(l.id)));
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _listings.addAll(details);
        _totalPages = result.pagination.totalPages;
        _total = result.pagination.total;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted || seq != _requestSeq) return;
      setState(() {
        _error = e is ApiException ? e : const ApiException('Could not load cars. Please try again.');
        _loading = false;
        _loadingMore = false;
        if (!reset && _page > 1) _page--;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || _error != null || _page >= _totalPages) return;
    _page++;
    await _load();
  }

  void _applyFilters(ListingFilters next) {
    setState(() => _filters = next);
    _searchController.text = next.search ?? '';
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _load(reset: true);
  }

  void _submitSearch(String text) {
    final trimmed = text.trim();
    _applyFilters(_filters.copyWith(search: trimmed.isEmpty ? null : trimmed));
  }

  Future<void> _toggleFavorite(int carId, bool add) async {
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    await _loadFavorites();
    if (!mounted || _favoriteCarIds.contains(carId) == add) return;
    try {
      if (add) {
        await _marketplaceService.addFavorite(carId);
      } else {
        await _marketplaceService.removeFavorite(carId);
      }
      if (!mounted) return;
      setState(() => add ? _favoriteCarIds.add(carId) : _favoriteCarIds.remove(carId));
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: ListingFilterPanel(
            filters: _filters,
            brands: _brands,
            onApply: (next) {
              Navigator.of(sheetContext).pop();
              _applyFilters(next);
            },
          ),
        ),
      ),
    );
  }

  String _brandName(int id) => _brands.where((b) => b.id == id).firstOrNull?.name ?? 'Brand #$id';

  List<({String label, ListingFilters cleared})> _activeChips() {
    final f = _filters;
    return [
      if (f.brandId != null)
        (label: 'Brand: ${_brandName(f.brandId!)}', cleared: f.copyWith(brandId: null, modelId: null)),
      if (f.fuelType != null) (label: 'Fuel: ${f.fuelType!.label}', cleared: f.copyWith(fuelType: null)),
      if (f.transmission != null)
        (label: 'Gearbox: ${f.transmission!.label}', cleared: f.copyWith(transmission: null)),
      if (f.condition != null) (label: 'Condition: ${f.condition!.label}', cleared: f.copyWith(condition: null)),
      if (f.hasPriceFilter)
        (
          label: 'Price: ${f.minPrice == null ? 'any' : formatInr(f.minPrice!)} - ${f.maxPrice == null ? 'any' : formatInr(f.maxPrice!)}',
          cleared: f.copyWith(minPrice: null, maxPrice: null),
        ),
      if (f.hasYearFilter)
        (label: 'Year: ${f.minYear ?? 'any'} - ${f.maxYear ?? 'any'}', cleared: f.copyWith(minYear: null, maxYear: null)),
      if (f.maxMileage != null) (label: 'Up to ${formatKm(f.maxMileage!)}', cleared: f.copyWith(maxMileage: null)),
      if (f.city != null && f.city!.isNotEmpty) (label: 'City: ${f.city}', cleared: f.copyWith(city: null)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isExpanded(context);
    final results = _buildResults(context, wide);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CarZenNavBar(current: NavSection.buy, title: widget.title),
      body: SafeArea(
        child: wide
            ? Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 12, 24),
                          child: ListingFilterPanel(filters: _filters, brands: _brands, onApply: _applyFilters),
                        ),
                      ),
                      const VerticalDivider(width: 1, color: AppColors.divider),
                      Expanded(child: results),
                    ],
                  ),
                ),
              )
            : results,
      ),
    );
  }

  Widget _buildResults(BuildContext context, bool wide) {
    final chips = _activeChips();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onSubmitted: _submitSearch,
                decoration: InputDecoration(
                  hintText: 'Search brand, model or variant',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.arrow_forward_rounded),
                    onPressed: () => _submitSearch(_searchController.text),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (!wide) ...[
                    OutlinedButton.icon(
                      onPressed: _openFilterSheet,
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: Text(_filters.activeCount == 0 ? 'Filters' : 'Filters (${_filters.activeCount})'),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      _loading ? 'Searching...' : '$_total car${_total == 1 ? '' : 's'} found',
                      style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  DropdownButton<ListingSort>(
                    value: _filters.sort,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(12),
                    items: [
                      for (final sort in ListingSort.values)
                        DropdownMenuItem<ListingSort>(value: sort, child: Text(sort.label)),
                    ],
                    onChanged: (value) {
                      if (value != null) _applyFilters(_filters.copyWith(sort: value));
                    },
                  ),
                ],
              ),
              if (chips.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final chip in chips)
                        InputChip(
                          label: Text(chip.label),
                          onDeleted: () => _applyFilters(chip.cleared),
                          backgroundColor: AppColors.surface,
                          side: const BorderSide(color: AppColors.divider),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _buildList(context)),
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    if (_loading) return const LoadingView(label: 'Finding cars...');
    if (_error != null && _listings.isEmpty) {
      return ApiErrorView(error: _error!, onRetry: () => _load(reset: true), fallback: 'Could not load cars.');
    }
    if (_listings.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: 'No cars match these filters',
        message: 'Try removing a filter or searching for something broader.',
        action: OutlinedButton(
          onPressed: () => _applyFilters(const ListingFilters()),
          child: const Text('Clear search and filters'),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverLayoutBuilder(
              builder: (context, constraints) {
                const spacing = 14.0;
                final available = constraints.crossAxisExtent;
                final columns = (available / 250).floor().clamp(2, 5);
                final cardWidth = (available - spacing * (columns - 1)) / columns;
                // 16:11 photo + about 96px of text.
                final ratio = cardWidth / (cardWidth * 11 / 16 + 96);
                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: ratio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final listing = _listings[index];
                      return ListingCard(
                        listing: listing,
                        width: double.infinity,
                        isFavorite: _favoriteCarIds.contains(listing.car.id),
                        onFavoriteToggle: (value) => _toggleFavorite(listing.car.id, value),
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.carDetails(listing.id)),
                      );
                    },
                    childCount: _listings.length,
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(child: _footer()),
        ],
      ),
    );
  }

  Widget _footer() {
    if (_loadingMore) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2.4)),
      );
    }
    if (_error != null) {
      final message = _error is ApiException ? (_error as ApiException).message : 'Could not load more cars.';
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message, style: const TextStyle(color: AppColors.favorite)),
            TextButton(onPressed: _loadMore, child: const Text('Try again')),
          ],
        ),
      );
    }
    if (_page >= _totalPages) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 28),
        child: Center(child: Text("You've seen every car for these filters.", style: TextStyle(color: AppColors.textSecondary))),
      );
    }
    return const SizedBox(height: 24);
  }
}
