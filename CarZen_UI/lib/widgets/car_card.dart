import 'package:flutter/material.dart';
import '../models/car.dart';
import '../theme/app_theme.dart';

/// A single car listing card: image, favorite toggle, name/year, price and
/// location. Used inside a horizontal [ListView] on the Home screen and,
/// later, inside the full listing/search results grid too.
class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onFavoriteToggle;
  final double width;

  const CarCard({
    super.key,
    required this.car,
    this.onTap,
    this.onFavoriteToggle,
    this.width = 220,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 11,
                  child: Image.network(
                    car.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: AppColors.divider);
                    },
                    errorBuilder: (context, error, stack) =>
                        Container(color: AppColors.divider, child: const Icon(Icons.directions_car)),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _FavoriteButton(
                    isFavorite: car.isFavorite,
                    onToggle: onFavoriteToggle,
                  ),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _Pill(text: car.year.toString()),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${car.brand} ${car.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          car.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        car.formattedPrice,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        car.fuelType,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final ValueChanged<bool>? onToggle;

  const _FavoriteButton({required this.isFavorite, this.onToggle});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onToggle?.call(!isFavorite),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 17,
          color: isFavorite ? AppColors.favorite : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
