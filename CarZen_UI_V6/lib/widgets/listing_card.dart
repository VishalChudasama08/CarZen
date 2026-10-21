import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:flutter/material.dart';

/// Marketplace car card for a [ListingDetail].
///
/// * [ListingCardLayout.grid] - photo on top (4:3), for grids on tablets and
///   desktops.
/// * [ListingCardLayout.row] - photo on the left, details on the right; a
///   denser layout that lets phones show more cars per screen.
class ListingCard extends StatefulWidget {
  final ListingDetail listing;
  final VoidCallback? onTap;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteToggle;
  final ListingCardLayout layout;

  /// Kept for older call sites; the card fills the width it is given.
  final double? width;

  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.layout = ListingCardLayout.grid,
    this.width,
  });

  @override
  State<ListingCard> createState() => _ListingCardState();
}

enum ListingCardLayout { grid, row }

class _ListingCardState extends State<ListingCard> {
  bool _hover = false;

  String get _semantic {
    final l = widget.listing;
    final c = l.car;
    return '${c.manufacturingYear} ${c.brandName} ${c.modelName} ${c.variantName}, ${formatInr(l.askingPrice)}, '
        '${formatKm(c.mileageKm)}, ${c.fuelType.label}, ${c.transmission.label}, ${c.city}';
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.layout == ListingCardLayout.row ? _row(context) : _grid(context);
    return Semantics(
      button: widget.onTap != null,
      label: _semantic,
      child: MouseRegion(
        cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: _hover ? AppColors.lineStrong : AppColors.divider),
            boxShadow: _hover ? AppShadows.raised : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: widget.onTap, child: card),
          ),
        ),
      ),
    );
  }

  String? get _photo => widget.listing.car.media.cover?.absoluteUrl(ApiConfig.baseUrl);
  int get _photoCount => widget.listing.car.media.where((m) => m.mediaType == MediaType.image).length;

  Widget _favorite({double size = 36}) {
    if (widget.onFavoriteToggle == null) return const SizedBox.shrink();
    final fav = widget.isFavorite;
    return Tooltip(
      message: fav ? 'Remove from saved cars' : 'Save this car',
      child: Semantics(
        button: true,
        toggled: fav,
        label: fav ? 'Saved. Remove from saved cars' : 'Save this car',
        excludeSemantics: true,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 1,
          shadowColor: const Color(0x330F1C2E),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => widget.onFavoriteToggle!(!fav),
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(
                fav ? Icons.favorite : Icons.favorite_border,
                size: size * 0.52,
                color: fav ? AppColors.danger : AppColors.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusTag() {
    final status = widget.listing.listingStatus;
    if (status == ListingStatus.reserved) return const _Tag('Reserved', background: AppColors.plate, foreground: AppColors.ink);
    if (status == ListingStatus.sold) return const _Tag('Sold', background: AppColors.danger, foreground: Colors.white);
    return const SizedBox.shrink();
  }

  Widget _grid(BuildContext context) {
    final listing = widget.listing;
    final car = listing.car;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: NetworkPhoto(url: _photo, cacheWidth: 520, fallbackLabel: 'No photos yet'),
            ),
            Positioned(top: 10, right: 10, child: _favorite()),
            Positioned(
              left: 10,
              bottom: 10,
              right: 10,
              child: Row(
                children: [
                  _Tag('${car.manufacturingYear}'),
                  const SizedBox(width: 6),
                  _statusTag(),
                  const Spacer(),
                  if (_photoCount > 1) _Tag('$_photoCount photos', icon: Icons.photo_camera_outlined),
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
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.ink, height: 1.25),
              ),
              Text(
                car.variantName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 10),
              _PriceLine(price: listing.askingPrice, negotiable: listing.negotiable),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              _Specs(car: car),
              const SizedBox(height: 8),
              _Place(car: car),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(BuildContext context) {
    final listing = widget.listing;
    final car = listing.car;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            child: SizedBox(
              width: 124,
              height: 112,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkPhoto(url: _photo, cacheWidth: 260),
                  Positioned(left: 6, bottom: 6, child: _Tag('${car.manufacturingYear}', small: true)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '${car.brandName} ${car.modelName}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink, height: 1.25),
                      ),
                    ),
                    if (widget.onFavoriteToggle != null)
                      Transform.translate(offset: const Offset(4, -4), child: _favorite(size: 34)),
                  ],
                ),
                Text(
                  car.variantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                _PriceLine(price: listing.askingPrice, negotiable: listing.negotiable, size: 17),
                const SizedBox(height: 6),
                Text(
                  [formatKm(car.mileageKm), car.fuelType.label, car.transmission.label].join('  |  '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(
                  car.city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final num price;
  final bool negotiable;
  final double size;
  const _PriceLine({required this.price, required this.negotiable, this.size = 19});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 2,
      children: [
        Text(formatLakh(price), style: AppText.price(size)),
        if (negotiable)
          const Text('Negotiable', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
      ],
    );
  }
}

class _Specs extends StatelessWidget {
  final ListingCar car;
  const _Specs({required this.car});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _Spec(Icons.speed_outlined, formatKm(car.mileageKm)),
        _Spec(Icons.local_gas_station_outlined, car.fuelType.label),
        _Spec(Icons.settings_outlined, car.transmission.label),
      ],
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Spec(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _Place extends StatelessWidget {
  final ListingCar car;
  const _Place({required this.car});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.place_outlined, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            '${car.city}, ${car.state}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;
  final IconData? icon;
  final bool small;

  const _Tag(this.text, {this.background = const Color(0xD90A1422), this.foreground = Colors.white, this.icon, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 6 : 8, vertical: small ? 2 : 4),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppRadii.xs)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: foreground), const SizedBox(width: 4)],
          Text(text, style: AppText.figures(small ? 11 : 12, weight: FontWeight.w600, color: foreground)),
        ],
      ),
    );
  }
}

/// Loading placeholder shaped like [ListingCard].
class ListingCardSkeleton extends StatelessWidget {
  final ListingCardLayout layout;
  const ListingCardSkeleton({super.key, this.layout = ListingCardLayout.grid});

  @override
  Widget build(BuildContext context) {
    if (layout == ListingCardLayout.row) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonBox(width: 124, height: 112),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(height: 16, width: 150),
                  SizedBox(height: 8),
                  SkeletonBox(height: 12, width: 90),
                  SizedBox(height: 14),
                  SkeletonBox(height: 18, width: 110),
                  SizedBox(height: 10),
                  SkeletonBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(aspectRatio: 4 / 3, child: SkeletonBox(radius: 0)),
          Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(height: 16, width: 160),
                SizedBox(height: 8),
                SkeletonBox(height: 12, width: 100),
                SizedBox(height: 14),
                SkeletonBox(height: 20, width: 120),
                SizedBox(height: 16),
                SkeletonBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Lays out listing cards: a grid on wider screens, rows on phones.
class ListingCollection extends StatelessWidget {
  final List<ListingDetail> listings;
  final Set<int> favoriteCarIds;
  final void Function(ListingDetail listing)? onOpen;
  final void Function(ListingDetail listing, bool value)? onFavorite;
  final double minTileWidth;
  final int maxColumns;

  /// Force the phone layout regardless of width.
  final bool? rows;

  const ListingCollection({
    super.key,
    required this.listings,
    this.favoriteCarIds = const {},
    this.onOpen,
    this.onFavorite,
    this.minTileWidth = 250,
    this.maxColumns = 4,
    this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRows = rows ?? constraints.maxWidth < 560;
        if (useRows) {
          return Column(
            children: [
              for (final l in listings)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ListingCard(
                    listing: l,
                    layout: ListingCardLayout.row,
                    isFavorite: favoriteCarIds.contains(l.car.id),
                    onFavoriteToggle: onFavorite == null ? null : (v) => onFavorite!(l, v),
                    onTap: onOpen == null ? null : () => onOpen!(l),
                  ),
                ),
            ],
          );
        }
        const spacing = 16.0;
        final columns = ((constraints.maxWidth + spacing) / (minTileWidth + spacing)).floor().clamp(2, maxColumns);
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        // Rows of equal-height cards, so prices and specs line up across a row.
        final rowWidgets = <Widget>[];
        for (var i = 0; i < listings.length; i += columns) {
          final cells = <Widget>[];
          for (var j = 0; j < columns; j++) {
            if (j > 0) cells.add(const SizedBox(width: spacing));
            final index = i + j;
            if (index >= listings.length) {
              cells.add(SizedBox(width: width));
              continue;
            }
            final l = listings[index];
            cells.add(SizedBox(
              width: width,
              child: ListingCard(
                listing: l,
                isFavorite: favoriteCarIds.contains(l.car.id),
                onFavoriteToggle: onFavorite == null ? null : (v) => onFavorite!(l, v),
                onTap: onOpen == null ? null : () => onOpen!(l),
              ),
            ));
          }
          if (rowWidgets.isNotEmpty) rowWidgets.add(const SizedBox(height: spacing));
          rowWidgets.add(IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells)));
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rowWidgets);
      },
    );
  }
}

/// Skeleton version of [ListingCollection].
class ListingCollectionSkeleton extends StatelessWidget {
  final int count;
  final double minTileWidth;
  final int maxColumns;
  const ListingCollectionSkeleton({super.key, this.count = 6, this.minTileWidth = 250, this.maxColumns = 4});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 560) {
          return Column(
            children: [
              for (var i = 0; i < count.clamp(1, 4); i++)
                const Padding(padding: EdgeInsets.only(bottom: 10), child: ListingCardSkeleton(layout: ListingCardLayout.row)),
            ],
          );
        }
        const spacing = 16.0;
        final columns = ((constraints.maxWidth + spacing) / (minTileWidth + spacing)).floor().clamp(2, maxColumns);
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (var i = 0; i < count; i++) SizedBox(width: width, child: const ListingCardSkeleton())],
        );
      },
    );
  }
}
