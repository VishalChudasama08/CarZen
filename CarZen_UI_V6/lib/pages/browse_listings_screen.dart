import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_filters.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/auth_gate.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/listing_card.dart';
import 'package:carzen_flutter/widgets/listing_filter_panel.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Public browsing: search, every filter and sort `GET /v1/listings`
/// supports, paged results and saved cars. No login needed to browse.
/// The current search is mirrored in the URL so it can be shared.
class BrowseListingsScreen extends StatefulWidget {
  final ListingFilters initialFilters;

  const BrowseListingsScreen({super.key, this.initialFilters = const ListingFilters()});

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  static const int _pageSize = 12;

  final _market = MarketplaceService();
  final _catalog = CatalogService();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  late ListingFilters _filters;
  List<CatalogBrand> _brands = const [];
  Map<int, String> _modelNames = const {};
  List<ListingDetail> _listings = const [];
  Set<int> _favoriteCarIds = {};

  int _page = 1;
  PaginationMeta? _meta;
  bool _loading = true;
  Object? _error;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _filters = widget.initialFilters;
    _searchController.text = _filters.search ?? '';
    _loadBrands();
    _loadModelNames();
    _loadFavorites();
    _load(page: 1);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final page = await _catalog.listBrands(limit: 100, isActive: true);
      if (mounted) setState(() => _brands = page.data);
    } on ApiException {
      // Brand filter becomes unavailable; the rest of the page still works.
    }
  }

  Future<void> _loadModelNames() async {
    final brandId = _filters.brandId;
    if (brandId == null || _filters.modelId == null) return;
    try {
      final page = await _catalog.listModelsForBrand(brandId);
      if (mounted) setState(() => _modelNames = {for (final m in page.data) m.id: m.name});
    } on ApiException {
      // The chip falls back to a generic label.
    }
  }

  Future<void> _loadFavorites() async {
    await SessionController.instance.refresh();
    if (!SessionController.instance.isLoggedIn || SessionController.instance.isAdmin) return;
    try {
      final favorites = await _market.listFavorites();
      if (mounted) setState(() => _favoriteCarIds = favorites.map((f) => f.carId).toSet());
    } on ApiException {
      // Hearts simply stay empty.
    }
  }

  Future<void> _load({required int page}) async {
    final requestId = ++_requestId;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final f = _filters;
      final result = await _market.listPublicListings(
        page: page,
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
      if (result.data.isEmpty && page > 1 && result.pagination.totalPages < page) {
        return await _load(page: result.pagination.totalPages < 1 ? 1 : result.pagination.totalPages);
      }
      final details = await _market.expandWithCarDetails(result.data);
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _listings = details;
        _page = result.pagination.page;
        _meta = result.pagination;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  void _syncUrl() {
    final query = _filters.toQuery();
    final uri = Uri(path: AppRoutes.browse, queryParameters: query.isEmpty ? null : query);
    SystemNavigator.routeInformationUpdated(uri: uri, replace: true);
  }

  void _setFilters(ListingFilters next) {
    setState(() => _filters = next);
    _syncUrl();
    _load(page: 1);
    if (next.modelId != null && !_modelNames.containsKey(next.modelId)) _loadModelNames();
  }

  void _goToPage(int page) {
    _load(page: page);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    }
  }

  void _applyPanel(ListingFilters filters) => _setFilters(filters.withSearch(_filters.search).withSort(_filters.sort));

  void _submitSearch(String value) => _setFilters(_filters.withSearch(value));

  Future<void> _toggleFavorite(int carId, bool wantFavorite) async {
    if (!await AuthGate.requireAuthenticated(context) || !mounted) return;
    setState(() => _favoriteCarIds = wantFavorite ? {..._favoriteCarIds, carId} : _favoriteCarIds.difference({carId}));
    try {
      if (wantFavorite) {
        await _market.addFavorite(carId);
      } else {
        await _market.removeFavorite(carId);
      }
      if (mounted) showAppSnack(context, wantFavorite ? 'Saved to your cars' : 'Removed from saved cars');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _favoriteCarIds = wantFavorite ? _favoriteCarIds.difference({carId}) : {..._favoriteCarIds, carId});
      showAppSnack(context, e.message, error: true);
    }
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.96,
        builder: (context, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 8, 4),
              child: Row(
                children: [
                  Expanded(child: Text('Filters', style: AppText.heading(19))),
                  IconButton(tooltip: 'Close', onPressed: () => Navigator.of(sheetContext).pop(), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: ListingFilterPanel(
                  initial: _filters,
                  brands: _brands,
                  onApply: (filters) {
                    Navigator.of(sheetContext).pop();
                    _applyPanel(filters);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "13-24 of 56 cars" - always explains what the list is.
  String _summary() {
    final meta = _meta;
    if (meta == null) return 'Looking for cars...';
    if (meta.total == 0) return 'No cars match';
    if (meta.totalPages <= 1) return '${formatCount(meta.total)} ${meta.total == 1 ? 'car' : 'cars'}';
    final first = (meta.page - 1) * meta.limit + 1;
    final last = meta.page * meta.limit > meta.total ? meta.total : meta.page * meta.limit;
    return '${formatCount(first)}-${formatCount(last)} of ${formatCount(meta.total)} cars';
  }

  List<(String, ListingFilters)> _activeChips() {
    final f = _filters;
    final chips = <(String, ListingFilters)>[];
    if (f.search != null) chips.add(('"${f.search}"', f.withSearch(null)));
    if (f.brandId != null) {
      final name = _brands.where((b) => b.id == f.brandId).map((b) => b.name).firstOrNull ?? 'Brand';
      chips.add((name, f.copyWith(brandId: null, modelId: null)));
    }
    if (f.modelId != null) chips.add((_modelNames[f.modelId] ?? 'Model', f.copyWith(modelId: null)));
    if (f.minPrice != null || f.maxPrice != null) {
      final label = f.minPrice == null
          ? 'Under ${formatLakh(f.maxPrice!)}'
          : f.maxPrice == null
              ? 'Above ${formatLakh(f.minPrice!)}'
              : '${formatLakh(f.minPrice!)} - ${formatLakh(f.maxPrice!)}';
      chips.add((label, f.copyWith(minPrice: null, maxPrice: null)));
    }
    if (f.fuelType != null) chips.add((f.fuelType!.label, f.copyWith(fuelType: null)));
    if (f.transmission != null) chips.add((f.transmission!.label, f.copyWith(transmission: null)));
    if (f.maxMileage != null) chips.add(('Up to ${formatKm(f.maxMileage!)}', f.copyWith(maxMileage: null)));
    if (f.condition != null) chips.add((f.condition!.label, f.copyWith(condition: null)));
    if (f.minYear != null || f.maxYear != null) {
      final label = f.minYear != null && f.maxYear != null
          ? '${f.minYear}-${f.maxYear}'
          : f.minYear != null
              ? '${f.minYear} or newer'
              : '${f.maxYear} or older';
      chips.add((label, f.copyWith(minYear: null, maxYear: null)));
    }
    if (f.city != null) chips.add((f.city!, f.copyWith(city: null)));
    return chips;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.buy,
      title: 'Cars for sale',
      showBottomNav: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= Breakpoints.expanded;
          final gutter = AppSpacing.pageGutter(constraints.maxWidth);
          final results = _results(wide: wide, gutter: wide ? 0 : gutter);
          if (!wide) return results;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth + 80),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: gutter),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 280,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(0, 28, 8, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Filters', style: AppText.heading(17)),
                            const SizedBox(height: 16),
                            ListingFilterPanel(initial: _filters, brands: _brands, onApply: _applyPanel, instant: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    const VerticalDivider(width: 1),
                    const SizedBox(width: 24),
                    Expanded(child: results),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _results({required bool wide, required double gutter}) {
    final compact = Breakpoints.isCompact(context);
    final chips = _activeChips();
    return RefreshIndicator(
      onRefresh: () => _load(page: _page),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, compact ? 16 : 28, gutter, 0),
            sliver: SliverList.list(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(header: true, child: Text('Cars for sale', style: AppText.heading(compact ? 22 : 28))),
                          const SizedBox(height: 4),
                          Semantics(
                            liveRegion: true,
                            child: Text(_summary(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ),
                        ],
                      ),
                    ),
                    if (!compact) _SortMenu(sort: _filters.sort, onSort: (s) => _setFilters(_filters.withSort(s))),
                  ],
                ),
                const SizedBox(height: 16),
                _SearchRow(
                  controller: _searchController,
                  onSubmitted: _submitSearch,
                  onClear: () {
                    _searchController.clear();
                    _submitSearch('');
                  },
                  filterButton: wide
                      ? null
                      : _FilterButton(count: _filters.activeCount, onTap: _openFilterSheet, iconOnly: Breakpoints.isNarrow(context)),
                  sortButton: compact ? _SortMenu(sort: _filters.sort, onSort: (s) => _setFilters(_filters.withSort(s)), iconOnly: true) : null,
                ),
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      for (final c in chips)
                        InputChip(
                          label: Text(c.$1),
                          onDeleted: () {
                            if (c.$2.search == null) _searchController.clear();
                            _setFilters(c.$2);
                          },
                          deleteButtonTooltipMessage: 'Remove ${c.$1}',
                          deleteIcon: const Icon(Icons.close, size: 16),
                          backgroundColor: AppColors.chromeTint,
                          side: BorderSide.none,
                          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink),
                        ),
                      if (chips.length > 1)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            _setFilters(ListingFilters(sort: _filters.sort));
                          },
                          child: const Text('Clear all'),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                if (_loading && _listings.isNotEmpty) const LinearProgressIndicator(minHeight: 2),
                if (_error != null && _listings.isNotEmpty)
                  InlineError(_error is ApiException ? (_error as ApiException).message : 'This page could not be refreshed.'),
              ],
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 40),
            sliver: SliverToBoxAdapter(child: _body(wide)),
          ),
        ],
      ),
    );
  }

  Widget _body(bool wide) {
    if (_loading && _listings.isEmpty) return ListingCollectionSkeleton(count: 6, maxColumns: wide ? 3 : 4);
    if (_error != null && _listings.isEmpty) {
      return SizedBox(height: 420, child: ApiErrorView(error: _error!, onRetry: () => _load(page: _page), fallback: 'Cars could not be loaded.'));
    }
    if (_listings.isEmpty) {
      final filtered = _filters.activeCount > 0 || _filters.search != null;
      return SizedBox(
        height: 420,
        child: EmptyStateView(
          icon: Icons.search_off,
          title: 'No cars match this search',
          message: filtered
              ? 'Remove a filter or widen your budget to see more cars.'
              : 'There are no cars for sale right now. New listings appear as soon as they are approved.',
          action: filtered
              ? OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    _setFilters(ListingFilters(sort: _filters.sort));
                  },
                  child: const Text('Clear search and filters'),
                )
              : null,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListingCollection(
          listings: _listings,
          favoriteCarIds: _favoriteCarIds,
          maxColumns: wide ? 3 : 4,
          minTileWidth: 240,
          onOpen: (l) => Navigator.of(context).pushNamed(AppRoutes.carDetails(l.id, l.title)),
          onFavorite: SessionController.instance.isAdmin ? null : (l, v) => _toggleFavorite(l.car.id, v),
        ),
        const SizedBox(height: 28),
        PaginationBar(meta: _meta, busy: _loading, itemLabel: 'cars', onPageChanged: _goToPage),
      ],
    );
  }
}

class _SearchRow extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final Widget? filterButton;
  final Widget? sortButton;

  const _SearchRow({required this.controller, required this.onSubmitted, required this.onClear, this.filterButton, this.sortButton});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmitted,
            decoration: InputDecoration(
              hintText: 'Search brand, model or variant',
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, _) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(tooltip: 'Clear search', icon: const Icon(Icons.close, size: 18), onPressed: onClear),
              ),
            ),
          ),
        ),
        if (sortButton != null) ...[const SizedBox(width: 8), sortButton!],
        if (filterButton != null) ...[const SizedBox(width: 8), filterButton!],
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  final bool iconOnly;
  const _FilterButton({required this.count, required this.onTap, this.iconOnly = false});

  @override
  Widget build(BuildContext context) {
    final label = count == 0 ? 'Filters' : 'Filters ($count)';
    final button = iconOnly
        ? OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48), padding: EdgeInsets.zero),
            child: Icon(Icons.tune, semanticLabel: label),
          )
        : OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 48)),
            icon: const Icon(Icons.tune, size: 20),
            label: Text(label),
          );
    return Badge(isLabelVisible: iconOnly && count > 0, label: Text('$count'), child: button);
  }
}

class _SortMenu extends StatelessWidget {
  final ListingSort sort;
  final ValueChanged<ListingSort> onSort;
  final bool iconOnly;
  const _SortMenu({required this.sort, required this.onSort, this.iconOnly = false});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ListingSort>(
      tooltip: 'Sort: ${sort.label}',
      initialValue: sort,
      onSelected: onSort,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final option in ListingSort.values)
          PopupMenuItem<ListingSort>(
            value: option,
            child: Row(children: [
              SizedBox(width: 24, child: option == sort ? const Icon(Icons.check, size: 18) : null),
              const SizedBox(width: 8),
              Text(option.label),
            ]),
          ),
      ],
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(horizontal: iconOnly ? 12 : 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.lineStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_vert, size: 20, semanticLabel: iconOnly ? 'Sort: ${sort.label}' : null),
            if (!iconOnly) ...[
              const SizedBox(width: 8),
              Text(sort.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              const Icon(Icons.expand_more, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}
