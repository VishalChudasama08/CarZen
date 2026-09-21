import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'add_edit_car_screen.dart';
import 'car_features_screen.dart';
import 'car_listing_screen.dart';
import 'car_media_screen.dart';

/// Hub for a single owned car: shows its full detail (`GET /v1/cars/{id}`)
/// and links out to editing, media, features and listing management —
/// each of those is its own screen to keep this one simple.
class CarManageScreen extends StatefulWidget {
  final int carId;
  const CarManageScreen({super.key, required this.carId});

  @override
  State<CarManageScreen> createState() => _CarManageScreenState();
}

class _CarManageScreenState extends State<CarManageScreen> {
  final _carService = CarService();
  late Future<CarRecordDetail> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = _carService.getCar(widget.carId);

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this car?'),
        content: const Text('This cannot be undone. Any listing for this car will be removed too.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.favorite)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _carService.deleteCar(widget.carId);
      if (!mounted) return;
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Car'),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.favorite),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: ContentWidth(
        maxWidth: 900,
        child: SafeArea(
        child: FutureBuilder<CarRecordDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading car...');
            }
            if (snapshot.hasError) {
              final message =
                  snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Could not load this car.';
              return ErrorStateView(message: message, onRetry: _refresh);
            }
            final car = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text('${car.brandName} ${car.modelName} ${car.variantName}',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text('${car.manufacturingYear} · ${car.city}, ${car.state}',
                      style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  _StatusBadge(car: car),
                  if (car.approvalStatus.apiValue == 'rejected' && car.rejectionReason != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.favorite.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Rejection reason: ${car.rejectionReason}',
                          style: const TextStyle(color: AppColors.favorite, fontSize: 13)),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _ManageTile(
                    icon: Icons.edit_outlined,
                    title: 'Edit Details',
                    subtitle: 'Year, mileage, price, description and more',
                    onTap: () async {
                      final saved = await Navigator.of(context)
                          .push<bool>(MaterialPageRoute(builder: (_) => AddEditCarScreen(existingCar: car)));
                      if (saved == true) _refresh();
                    },
                  ),
                  _ManageTile(
                    icon: Icons.photo_library_outlined,
                    title: 'Photos & Media',
                    subtitle: '${car.media.length} item(s)',
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CarMediaScreen(carId: car.id)));
                      _refresh();
                    },
                  ),
                  _ManageTile(
                    icon: Icons.checklist_rtl_outlined,
                    title: 'Features',
                    subtitle: '${car.features.length} item(s)',
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CarFeaturesScreen(carId: car.id)));
                      _refresh();
                    },
                  ),
                  _ManageTile(
                    icon: Icons.campaign_outlined,
                    title: 'Listing',
                    subtitle: 'Publish this car for sale',
                    onTap: () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CarListingScreen(carId: car.id)));
                      _refresh();
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CarRecordDetail car;
  const _StatusBadge({required this.car});

  @override
  Widget build(BuildContext context) {
    final color = switch (car.approvalStatus.apiValue) {
      'approved' || 'published' => AppColors.success,
      'rejected' => AppColors.favorite,
      _ => AppColors.secondary,
    };
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Text(car.approvalStatus.label, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        if (car.isVerified) ...[
          const SizedBox(width: 8),
          const Icon(Icons.verified_rounded, size: 16, color: AppColors.success),
          const SizedBox(width: 3),
          const Text('Verified', style: TextStyle(fontSize: 12, color: AppColors.success)),
        ],
      ],
    );
  }
}

class _ManageTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManageTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
