import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/car.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// Horizontal list of brand logos for the "Popular Brands" section. Tapping
/// a brand should filter the car listing by that brand once it's wired to
/// the API/router.
class BrandList extends StatelessWidget {
  final List<CarBrand> brands;
  final ValueChanged<CarBrand>? onBrandTap;

  const BrandList({super.key, required this.brands, this.onBrandTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final brand = brands[index];
          return InkWell(
            onTap: () => onBrandTap?.call(brand),
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 68,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Image.network(
                      brand.logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.directions_car, color: AppColors.textSecondary, size: 20),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    brand.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
