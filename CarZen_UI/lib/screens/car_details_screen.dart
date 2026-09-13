import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/enums.dart';
import '../models/listing_models.dart';
import '../services/api_exception.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';

/// Shows one public listing in full — `GET /v1/listings/{listingId}`.
/// Reached from the Home page's Featured Cars row and from search results.
class CarDetailsScreen extends StatefulWidget {
  final int listingId;
  const CarDetailsScreen({super.key, required this.listingId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  final _marketplaceService = MarketplaceService();

  late Future<ListingDetail> _future;
  bool _isFavorite = false;
  bool _favoriteBusy = false;

  @override
  void initState() {
    super.initState();
    _future = _marketplaceService.getPublicListing(widget.listingId);
  }

  Future<void> _toggleFavorite(int carId) async {
    setState(() => _favoriteBusy = true);
    try {
      if (_isFavorite) {
        await _marketplaceService.removeFavorite(carId);
      } else {
        await _marketplaceService.addFavorite(carId);
      }
      if (!mounted) return;
      setState(() => _isFavorite = !_isFavorite);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _favoriteBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FutureBuilder<ListingDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading car details...');
            }
            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Could not load this listing.';
              return ErrorStateView(
                message: message,
                onRetry: () => setState(() => _future = _marketplaceService.getPublicListing(widget.listingId)),
              );
            }

            final listing = snapshot.data!;
            final car = listing.car;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: AppColors.background,
                  pinned: true,
                  leading: const BackButton(color: AppColors.textPrimary),
                  flexibleSpace: FlexibleSpaceBar(
                    background: car.media.isEmpty
                        ? Container(color: AppColors.divider, child: const Icon(Icons.directions_car, size: 60))
                        : PageView(
                            children: car.media
                                .map((m) => Image.network(m.absoluteUrl(ApiConfig.baseUrl),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: AppColors.divider)))
                                .toList(),
                          ),
                  ),
                  expandedHeight: 260,
                  actions: [
                    IconButton(
                      onPressed: _favoriteBusy ? null : () => _toggleFavorite(car.id),
                      icon: Icon(
                        _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: _isFavorite ? AppColors.favorite : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${car.brandName} ${car.modelName} ${car.variantName}',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                            const SizedBox(width: 2),
                            Text('${car.city}, ${car.state}', style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '₹${listing.askingPrice.toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 26, color: AppColors.primary),
                        ),
                        if (listing.negotiable)
                          const Text('Negotiable', style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                        const Divider(height: 32, color: AppColors.divider),
                        _SpecsGrid(car: car),
                        if (car.features.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Features', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: car.features
                                .map((f) => Chip(
                                      label: Text(f.featureValue == null ? f.featureName : '${f.featureName}: ${f.featureValue}'),
                                      backgroundColor: AppColors.surface,
                                      side: const BorderSide(color: AppColors.divider),
                                    ))
                                .toList(),
                          ),
                        ],
                        if (listing.description != null && listing.description!.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text('Description', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(listing.description!, style: const TextStyle(color: AppColors.textSecondary, height: 1.5)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  final ListingCar car;
  const _SpecsGrid({required this.car});

  @override
  Widget build(BuildContext context) {
    final specs = <IconData, String>{
      Icons.calendar_today_outlined: '${car.manufacturingYear}',
      Icons.speed_outlined: '${car.mileageKm} km',
      Icons.local_gas_station_outlined: car.fuelType.label,
      Icons.settings_outlined: car.transmission.label,
      Icons.event_seat_outlined: car.seatingCapacity?.toString() ?? '-',
      Icons.verified_outlined: car.condition.label,
    };
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: specs.entries
          .map((e) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(e.key, color: AppColors.secondary, size: 22),
                  const SizedBox(height: 4),
                  Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ))
          .toList(),
    );
  }
}
