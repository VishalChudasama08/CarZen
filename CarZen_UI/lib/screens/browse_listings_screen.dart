import 'package:flutter/material.dart';
import '../models/enums.dart';
import '../models/listing_models.dart';
import '../services/api_exception.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import '../widgets/listing_card.dart';
import '../widgets/state_views.dart';
import 'car_details_screen.dart';

/// Full listing browser — `GET /v1/listings` (paginated), with an
/// optional set of filters passed in from the Home page's quick filters.
/// Since the list endpoint doesn't include car/media, each visible card's
/// detail is fetched individually via `GET /v1/listings/{id}` — the only
/// way to get images/brand data using the endpoints that actually exist.
class BrowseListingsScreen extends StatefulWidget {
  final int? brandId;
  final String? fuelType;
  final String? transmission;
  final num? minPrice;
  final num? maxPrice;
  final String title;

  const BrowseListingsScreen({
    super.key,
    this.brandId,
    this.fuelType,
    this.transmission,
    this.minPrice,
    this.maxPrice,
    this.title = 'Explore Cars',
  });

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  final _marketplaceService = MarketplaceService();

  final List<ListingDetail> _listings = [];
  int _page = 1;
  int _totalPages = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPage(reset: true);
  }

  Future<void> _loadPage({bool reset = false}) async {
    setState(() {
      if (reset) {
        _loading = true;
        _page = 1;
        _listings.clear();
      } else {
        _loadingMore = true;
      }
      _errorMessage = null;
    });

    try {
      final page = await _marketplaceService.listPublicListings(
        page: _page,
        limit: 10,
        brandId: widget.brandId,
        fuelType: widget.fuelType == null ? null : FuelTypeX.fromApi(widget.fuelType!),
        transmission: widget.transmission == null ? null : TransmissionTypeX.fromApi(widget.transmission!),
        minPrice: widget.minPrice,
        maxPrice: widget.maxPrice,
      );
      final details = await Future.wait(page.data.map((l) => _marketplaceService.getPublicListing(l.id)));
      if (!mounted) return;
      setState(() {
        _listings.addAll(details);
        _totalPages = page.pagination.totalPages;
        _loading = false;
        _loadingMore = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadingMore = false;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_page >= _totalPages) return;
    _page++;
    await _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(widget.title), backgroundColor: AppColors.background),
      body: SafeArea(
        child: _loading
            ? const LoadingView(label: 'Loading cars...')
            : _errorMessage != null && _listings.isEmpty
                ? ErrorStateView(message: _errorMessage!, onRetry: () => _loadPage(reset: true))
                : _listings.isEmpty
                    ? const EmptyStateView(
                        icon: Icons.directions_car_outlined,
                        title: 'No cars found',
                        message: 'Try adjusting your filters.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadPage(reset: true),
                        child: GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 0.68,
                          ),
                          itemCount: _listings.length + (_page < _totalPages ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _listings.length) {
                              if (!_loadingMore) {
                                WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
                              }
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 2.4),
                                ),
                              );
                            }
                            final listing = _listings[index];
                            return ListingCard(
                              listing: listing,
                              width: double.infinity,
                              onTap: () => Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (_) => CarDetailsScreen(listingId: listing.id))),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
