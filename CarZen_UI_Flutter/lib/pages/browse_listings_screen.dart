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

/// Public browsing: search, every filter and sort `GET /v1/listings`
/// supports, paged results and favorites. No login needed to browse.
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
  final ScrollController _scrollController = ScrollController();

  late ListingFilters _filters;
  List<CatalogBrand> _brands = const [];
  final List<ListingDetail> _listings = [];
  Set<int> _favoriteCarIds = {};

  int _page = 1;
  int _totalPages = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  Object? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _filters = ListingFilters(
      search: (widget.search ?? '').trim().isEmpty ? null : widget.search!.trim(),
      brandId: widget.brandId,
      fuelType: _matchName(FuelType.values, widget.fuelType),
      transmission: _matchName(TransmissionType.values, widget.transmission),
      minPrice: widget.minPrice,
      maxPrice: widget.maxPrice,
    );
    _searchController.text = _filters.search ?? '';
    _scrollController.addListener(_onScroll);
    _loadBrands();
    _loadFavorites();
    _load(reset: true);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  T? _matchName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  Future<void> _loadBrands() async {
    try {
      final page = await _catalogService.listBrands(limit: 100, isActive: true);
      if (mounted) setState(() => _brands = page.data);
    } on ApiException {
      // Filtering by brand is optional; the rest of the page still works.
    }
  }

  Future<void> _loadFavorites() async {
    if (!await _authService.hasStoredToken()) return;
    try {
      final favorites = await _marketplaceService.listFavorites();
      if (mounted) setState(() => _favoriteCarIds = favorites.map((f) => f.carId).toSet());
    } on ApiException {
      // Hearts simply stay empty.
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 400) _loadMore();
  }

  Future<void> _load({required bool reset}) async {
    final requestId = ++_requestId;
    setState(() {
      if (reset) {
        _loading = true;
        _page = 1;
      } else {
        _loadingMore = true;
      }
      _error = null;
    });
    try {
      final f = _filters;
      final result = await _marketplaceService.listPublicListings(
        page: _page,
        limit: _pageSize,
        search: f.search,
        brandId: f.brandId,
        modelId: f.modelId,
        fuelType: f.fuelType,
        transmission: f.transmission,
        condition: f.condition,
        minPrice: f.minPrice,
        maxPrice: f.maxPrice,
        minYear: f.minYear,
        maxYear: f.maxYear,
        maxMileage: f.maxMileage,
        city: f.city,
        sortBy: f.sort,
      );
      // The list endpoint omits the car snapshot, so each card's detail is fetched.
      final details = await _marketplaceService.expandWithCarDetails(result.data);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        if (reset) _listings.clear();
        _listings.addAll(details);
        _totalPages = result.pagination.totalPages;
        _total = result.pagination.total;
        _loading = false;
        _loadingMore = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error;
        _loading = false;
        _loadingMore = false;
        if (!reset && _page > 1) _page--;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loading || _loadingMore || _error != null || _page >= _totalPages) return;
    _page++;
    await _load(reset: false);
  }

  void _applyFilters(ListingFilters filters) {
    setState(() => _filters = filters.withSearch(_filters.search).withSort(_filters.sort));
    _load(reset: true);
  }

  void _submitSearch(String value) {
    setState(() => _filters = _filters.withSearch(value));
    _load(reset: true);
  }

  Future<void> _toggleFavorite(int carId, bool wantFavorite) async {
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    try {
      if (wantFavorite) {
        await _marketplaceService.addFavorite(carId);
      } else {
        await _marketplaceService.removeFavorite(carId);
      }
      if (!mounted) return;
      setState(() {
        final ids = {..._favoriteCarIds};
        wantFavorite ? ids.add(carId) : ids.remove(carId);
        _favoriteCarIds = ids;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: ListingFilterPanel(
            initial: _filters,
            brands: _brands,
            onApply: (filters) {
              Navigator.of(sheetContext).pop();
              _applyFilters(filters);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CarZenNavBar(current: NavSection.buy, title: widget.title),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= Breakpoints.expanded;
            final results = _buildResults(wide);
            if (!wide) return results;
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1400),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 300,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 8, 12, 32),
                        child: ListingFilterPanel(initial: _filters, brands: _brands, onApply: _applyFilters),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: AppColors.divider),
                    Expanded(child: results),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResults(bool wide) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Toolbar(
          controller: _searchController,
          sort: _filters.sort,
          activeFilters: _filters.activeCount,
          showFilterButton: !wide,
          onSubmitted: _submitSearch,
          onClearSearch: () {
            _searchController.clear();
            _submitSearch('');
          },
          onSort: (sort) {
            setState(() => _filters = _filters.withSort(sort));
            _load(reset: true);
          },
          onOpenFilters: _openFilterSheet,
        ),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(label: 'Finding cars...');
    if (_error != null && _listings.isEmpty) {
      return ApiErrorView(error: _error!, onRetry: () => _load(reset: true), fallback: 'Could not load cars.');
    }
    if (_listings.isEmpty) {
      return EmptyStateView(
        icon: Icons.search_off_rounded,
        title: 'No cars match',
        message: 'Try removing a filter or searching for something broader.',
        action: (_filters.activeCount > 0 || _filters.search != null)
            ? OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _filters = ListingFilters(sort: _filters.sort));
                  _load(reset: true);
                },
                child: const Text('Clear search and filters'),
              )
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 14.0;
          const horizontalPadding = 16.0;
          final available = constraints.maxWidth - horizontalPadding * 2;
          final columns = (available / 250).floor().clamp(2, 4);
          final cardWidth = (available - spacing * (columns - 1)) / columns;
          // Card = 16:11 photo + ~98px of text.
          final aspect = cardWidth / (cardWidth * 11 / 16 + 98);
          return CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    '${formatCount(_total)} car${_total == 1 ? '' : 's'} found',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: aspect,
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
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: _footer()),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _footer() {
    if (_loadingMore) {
      return const CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2.4);
    }
    if (_error != null) {
      final message = _error is ApiException ? (_error as ApiException).message : 'Could not load more cars.';
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: const TextStyle(color: AppColors.favorite)),
          TextButton(onPressed: _loadMore, child: const Text('Try again')),
        ],
      );
    }
    if (_page < _totalPages) {
      return OutlinedButton(onPressed: _loadMore, child: const Text('Load more'));
    }
    return const Text("You've seen every match", style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5));
  }
}

class _Toolbar extends StatelessWidget {
  final TextEditingController controller;
  final ListingSort sort;
  final int activeFilters;
  final bool showFilterButton;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClearSearch;
  final ValueChanged<ListingSort> onSort;
  final VoidCallback onOpenFilters;

  const _Toolbar({
    required this.controller,
    required this.sort,
    required this.activeFilters,
    required this.showFilterButton,
    required this.onSubmitted,
    required this.onClearSearch,
    required this.onSort,
    required this.onOpenFilters,
  });

  @override
  Widget build(BuildContext context) {
    final sortMenu = PopupMenuButton<ListingSort>(
      tooltip: 'Sort',
      initialValue: sort,
      onSelected: onSort,
      itemBuilder: (_) => [
        for (final option in ListingSort.values) PopupMenuItem<ListingSort>(value: option, child: Text(option.label)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded, size: 20),
            if (!showFilterButton) ...[
              const SizedBox(width: 6),
              Text(sort.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: 'Search brand, model or variant',
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, __) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(icon: const Icon(Icons.close_rounded), onPressed: onClearSearch),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          sortMenu,
          if (showFilterButton) ...[
            const SizedBox(width: 10),
            Badge(
              isLabelVisible: activeFilters > 0,
              label: Text('$activeFilters'),
              child: OutlinedButton.icon(
                onPressed: onOpenFilters,
                icon: const Icon(Icons.tune_rounded, size: 20),
                label: const Text('Filters'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
