import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/marketplace_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/listing_card.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Saved cars - `GET /v1/users/me/favorites` (one plain list, no pages).
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _service = MarketplaceService();
  late Future<List<Favorite>> _future = _service.listFavorites();
  final Set<int> _busy = {};
  final Set<int> _removed = {};

  Future<void> _refresh() async {
    setState(() {
      _removed.clear();
      _future = _service.listFavorites();
    });
    await _future;
  }

  /// Favorites are stored per car; the car page is addressed by listing.
  Future<void> _open(ListingCar car) async {
    if (_busy.contains(car.id)) return;
    setState(() => _busy.add(car.id));
    try {
      final listingId = await _service.findPublicListingIdForCar(car.id);
      if (!mounted) return;
      if (listingId == null) {
        showAppSnack(context, 'This car is not on sale right now.');
        return;
      }
      Navigator.of(context).pushNamed(AppRoutes.carDetails(listingId, '${car.brandName} ${car.modelName}'));
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(car.id));
    }
  }

  Future<void> _remove(ListingCar car) async {
    setState(() => _busy.add(car.id));
    try {
      await _service.removeFavorite(car.id);
      if (!mounted) return;
      setState(() => _removed.add(car.id));
      showAppSnack(
        context,
        'Removed from saved cars',
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.plate,
          onPressed: () async {
            try {
              await _service.addFavorite(car.id);
              if (mounted) setState(() => _removed.remove(car.id));
            } on ApiException catch (e) {
              if (mounted) showAppSnack(context, e.message, error: true);
            }
          },
        ),
      );
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(car.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.favorites,
      title: 'Saved cars',
      fallbackRoute: AppRoutes.account,
      body: FutureBuilder<List<Favorite>>(
        future: _future,
        builder: (context, snap) {
          final favorites = snap.data?.where((f) => !_removed.contains(f.carId)).toList();
          return PageScroll(
            maxWidth: 1120,
            verticalPadding: Breakpoints.isCompact(context) ? 18 : 32,
            onRefresh: _refresh,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PageHeader(
                  title: 'Saved cars',
                  subtitle: favorites == null
                      ? 'Cars you saved to compare and come back to.'
                      : favorites.isEmpty
                          ? 'Cars you saved to compare and come back to.'
                          : '${favorites.length} saved car${favorites.length == 1 ? '' : 's'}. We let you know when the price or status changes.',
                ),
                const SizedBox(height: 22),
                if (snap.connectionState != ConnectionState.done)
                  const ListingCollectionSkeleton(count: 3, maxColumns: 3)
                else if (snap.hasError)
                  ApiErrorView(error: snap.error!, onRetry: _refresh, fallback: 'Saved cars could not be loaded.', compact: true)
                else if (favorites!.isEmpty)
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: EmptyStateView(
                      compact: true,
                      icon: Icons.favorite_border,
                      title: 'No saved cars yet',
                      message: 'Tap the heart on any car to keep it here.',
                      action: FilledButton(onPressed: () => AppNav.goFrom(context, AppRoutes.browse), child: const Text('Browse cars')),
                    ),
                  )
                else
                  ResponsiveGrid(
                    minTileWidth: 280,
                    maxColumns: 3,
                    children: [
                      for (final f in favorites)
                        _SavedCarTile(
                          car: f.car,
                          busy: _busy.contains(f.carId),
                          onOpen: () => _open(f.car),
                          onRemove: () => _remove(f.car),
                        ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SavedCarTile extends StatelessWidget {
  final ListingCar car;
  final bool busy;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const _SavedCarTile({required this.car, required this.busy, required this.onOpen, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final title = '${car.manufacturingYear} ${car.brandName} ${car.modelName}';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: busy ? null : onOpen,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 10,
                    child: NetworkPhoto(url: car.media.cover?.absoluteUrl(ApiConfig.baseUrl), cacheWidth: 520, semanticLabel: title),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 1,
                      child: IconButton(
                        tooltip: 'Remove from saved cars',
                        onPressed: busy ? null : onRemove,
                        icon: const Icon(Icons.favorite, color: AppColors.danger, size: 21),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
                    const SizedBox(height: 2),
                    Text(
                      <String>[car.variantName, car.fuelType.label, formatKm(car.mileageKm)].where((s) => s.isNotEmpty).join('  |  '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (car.expectedMarketPrice != null) ...[
                          Text(formatLakh(car.expectedMarketPrice!), style: AppText.price(17)),
                          const SizedBox(width: 6),
                          const Text('expected', style: TextStyle(color: AppColors.textTertiary, fontSize: 12.5)),
                        ],
                        const Spacer(),
                        const Icon(Icons.place_outlined, size: 15, color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(car.city, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        ),
                      ],
                    ),
                    if (busy) const Padding(padding: EdgeInsets.only(top: 10), child: LinearProgressIndicator(minHeight: 2)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
