import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// The signed-in user's favorited cars — `GET /v1/users/me/favorites`.
/// That endpoint returns one plain list (no pages), so everything is shown.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _marketplaceService = MarketplaceService();
  late Future<List<Favorite>> _future;
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _future = _marketplaceService.listFavorites();
  }

  void _refresh() => setState(() => _future = _marketplaceService.listFavorites());

  /// Favorites are stored per car, but the details page is addressed by
  /// listing id, so the listing is looked up first.
  Future<void> _openDetails(int carId) async {
    try {
      final listingId = await _marketplaceService.findPublicListingIdForCar(carId);
      if (!mounted) return;
      if (listingId == null) {
        showAppSnack(context, 'This car is no longer listed for sale.');
        return;
      }
      Navigator.of(context).pushNamed(AppRoutes.carDetails(listingId));
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  Future<void> _remove(int carId) async {
    setState(() => _busy.add(carId));
    try {
      await _marketplaceService.removeFavorite(carId);
      if (!mounted) return;
      showAppSnack(context, 'Removed from favorites.');
      _refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(carId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.favorites, title: 'Favorites'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.favorites),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<List<Favorite>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return SingleChildScrollView(
                child: PageContainer(child: const SkeletonGrid(count: 4, tileHeight: 250, minTileWidth: 300)),
              );
            }
            if (snapshot.hasError) {
              return ApiErrorView(error: snapshot.error!, onRetry: _refresh, fallback: 'Could not load favorites.');
            }
            final favorites = snapshot.data!;
            if (favorites.isEmpty) {
              return EmptyStateView(
                icon: Icons.favorite_border_rounded,
                title: 'No favorites yet',
                message: 'Tap the heart on any car to save it here for later.',
                action: FilledButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.browse, (r) => false),
                  child: const Text('Browse cars'),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                _refresh();
                await _future;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PageContainer(
                  maxWidth: 1000,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      PageHeader(
                        title: 'Favorites',
                        subtitle: '${favorites.length} saved car${favorites.length == 1 ? '' : 's'}',
                        icon: Icons.favorite_rounded,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 14.0;
                          final columns = constraints.maxWidth >= 700 ? 2 : 1;
                          final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [for (final f in favorites) SizedBox(width: width, child: _tile(context, f.car))],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, ListingCar car) {
    return SurfaceCard(
      padding: const EdgeInsets.all(12),
      onTap: () => _openDetails(car.id),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(
              width: 104,
              height: 80,
              child: NetworkPhoto(url: car.media.cover?.absoluteUrl(ApiConfig.baseUrl), cacheWidth: 400),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${car.brandName} ${car.modelName}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text('${car.manufacturingYear} · ${car.city}, ${car.state}', maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                if (car.expectedMarketPrice != null) ...[
                  const SizedBox(height: 6),
                  Text(formatInr(car.expectedMarketPrice!), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 16)),
                ],
              ],
            ),
          ),
          _busy.contains(car.id)
              ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(
                  tooltip: 'Remove from favorites',
                  icon: const Icon(Icons.favorite_rounded, color: AppColors.favorite),
                  onPressed: () => _remove(car.id),
                ),
        ],
      ),
    );
  }
}
