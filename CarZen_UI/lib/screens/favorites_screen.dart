import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/listing_models.dart';
import '../services/api_exception.dart';
import '../services/marketplace_service.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';
import 'car_details_screen.dart';

/// The signed-in user's favorited cars — `GET /v1/users/me/favorites`.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final _marketplaceService = MarketplaceService();
  late Future<List<Favorite>> _future;

  @override
  void initState() {
    super.initState();
    _future = _marketplaceService.listFavorites();
  }

  void _refresh() => setState(() => _future = _marketplaceService.listFavorites());

  Future<void> _remove(int carId) async {
    try {
      await _marketplaceService.removeFavorite(carId);
      _refresh();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Favorites'), backgroundColor: AppColors.background),
      body: SafeArea(
        child: FutureBuilder<List<Favorite>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading favorites...');
            }
            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Could not load favorites.';
              return ErrorStateView(message: message, onRetry: _refresh);
            }
            final favorites = snapshot.data!;
            if (favorites.isEmpty) {
              return const EmptyStateView(
                icon: Icons.favorite_border_rounded,
                title: 'No favorites yet',
                message: 'Tap the heart icon on any car to save it here.',
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final favorite = favorites[index];
                final car = favorite.car;
                return InkWell(
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => CarDetailsScreen(listingId: car.id))),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: car.media.isEmpty
                                ? Container(color: AppColors.divider, child: const Icon(Icons.directions_car))
                                : Image.network(car.media.first.absoluteUrl(ApiConfig.baseUrl),
                                    fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: AppColors.divider)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${car.brandName} ${car.modelName}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                              const SizedBox(height: 3),
                              Text('${car.city}, ${car.state}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                              if (car.expectedMarketPrice != null) ...[
                                const SizedBox(height: 4),
                                Text('₹${car.expectedMarketPrice!.toStringAsFixed(0)}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: AppColors.favorite),
                          onPressed: () => _remove(car.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
