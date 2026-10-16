import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:flutter/material.dart';

/// Marketplace car card for a [ListingDetail] (`GET /v1/listings`).
///
/// The photo gets the most room (4:3) with the year and a favourite button
/// laid over it; below it the title, location, price and three scannable
/// specs (distance, fuel, gearbox). Pass `width: double.infinity` inside grids.
class ListingCard extends StatefulWidget {
  final ListingDetail listing;
  final VoidCallback? onTap;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteToggle;
  final double width;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.width = 260,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

class _ListingCardState extends State<ListingCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final car = listing.car;
    final imageUrl = car.media.cover?.absoluteUrl(ApiConfig.baseUrl);
    final status = listing.listingStatus;

    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: widget.width,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: _hover ? AppColors.secondary.withValues(alpha: 0.45) : AppColors.divider),
          boxShadow: _hover ? AppShadows.raised : AppShadows.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 4 / 3,
                      child: NetworkPhoto(
                        url: imageUrl,
                        cacheWidth: 700,
                        fallbackLabel: imageUrl == null ? 'Photos coming soon' : null,
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Semantics(
                        button: true,
                        label: widget.isFavorite ? 'Remove from favorites' : 'Save to favorites',
                        child: InkWell(
                          onTap: () => widget.onFavoriteToggle?.call(!widget.isFavorite),
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              shape: BoxShape.circle,
                              boxShadow: AppShadows.card,
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 180),
                              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                              child: Icon(
                                widget.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                key: ValueKey(widget.isFavorite),
                                size: 19,
                                color: widget.isFavorite ? AppColors.favorite : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Wrap(
                        spacing: 6,
                        children: [
                          _Tag('${car.manufacturingYear}'),
                          if (status == ListingStatus.reserved) const _Tag('Reserved', color: AppColors.warm, dark: true),
                          if (status == ListingStatus.sold) const _Tag('Sold', color: AppColors.favorite),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.brandName} ${car.modelName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        car.variantName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Text(
                              formatInr(listing.askingPrice),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19, color: AppColors.primary, letterSpacing: -0.3),
                            ),
                          ),
                          if (listing.negotiable) ...[
                            const SizedBox(width: 8),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Text('Negotiable', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _Spec(Icons.speed_rounded, formatKm(car.mileageKm)),
                          _Spec(Icons.local_gas_station_rounded, car.fuelType.label),
                          _Spec(Icons.settings_rounded, car.transmission.label),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 15, color: AppColors.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${car.city}, ${car.state}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color? color;
  final bool dark;
  const _Tag(this.text, {this.color, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        text,
        style: TextStyle(color: dark ? AppColors.primary : Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Spec(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadii.sm)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
