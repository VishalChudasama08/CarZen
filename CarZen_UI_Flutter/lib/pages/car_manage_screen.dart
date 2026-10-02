import 'package:carzen_flutter/pages/my_cars_screen.dart' show approvalTone;
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
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
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete car'),
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
      showAppSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage car'),
        actions: [
          IconButton(
            tooltip: 'Delete car',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<CarRecordDetail>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading car...');
            }
            if (snapshot.hasError) {
              return ApiErrorView(error: snapshot.error!, onRetry: _refresh, fallback: 'Could not load this car.');
            }
            final car = snapshot.data!;
            final nav = Navigator.of(context);
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PageContainer(
                  maxWidth: 760,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('${car.brandName} ${car.modelName} ${car.variantName}', style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 6),
                      Text('${car.manufacturingYear} · ${car.city}, ${car.state}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          StatusPill(label: car.approvalStatus.label, tone: approvalTone(car.approvalStatus)),
                          if (car.isVerified) const StatusPill(label: 'Verified', tone: StatusTone.success, icon: Icons.verified_rounded),
                        ],
                      ),
                      if (car.approvalStatus == CarApprovalStatus.rejected && car.rejectionReason != null) ...[
                        const SizedBox(height: 14),
                        InlineError('Rejected by the CarZen team: ${car.rejectionReason}'),
                      ] else if (car.approvalStatus == CarApprovalStatus.pendingApproval) ...[
                        const SizedBox(height: 14),
                        Text(
                          'Waiting for the CarZen team to review this car. You can keep adding photos and features meanwhile.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      _ManageTile(
                        step: 1,
                        icon: Icons.edit_outlined,
                        title: 'Edit details',
                        subtitle: 'Year, mileage, price, description and more',
                        onTap: () async {
                          final saved = await nav.push<bool>(MaterialPageRoute(builder: (_) => AddEditCarScreen(existingCar: car)));
                          if (saved == true) _refresh();
                        },
                      ),
                      _ManageTile(
                        step: 2,
                        icon: Icons.photo_library_outlined,
                        title: 'Photos & media',
                        subtitle: car.media.isEmpty ? 'No photos yet — add some to attract buyers' : '${car.media.length} item${car.media.length == 1 ? '' : 's'}',
                        done: car.media.isNotEmpty,
                        onTap: () async {
                          await nav.push(MaterialPageRoute(builder: (_) => CarMediaScreen(carId: car.id)));
                          _refresh();
                        },
                      ),
                      _ManageTile(
                        step: 3,
                        icon: Icons.checklist_rtl_outlined,
                        title: 'Features',
                        subtitle: car.features.isEmpty ? 'Sunroof, airbags, infotainment…' : '${car.features.length} item${car.features.length == 1 ? '' : 's'}',
                        done: car.features.isNotEmpty,
                        onTap: () async {
                          await nav.push(MaterialPageRoute(builder: (_) => CarFeaturesScreen(carId: car.id)));
                          _refresh();
                        },
                      ),
                      _ManageTile(
                        step: 4,
                        icon: Icons.campaign_outlined,
                        title: 'Listing',
                        subtitle: 'Set your price and publish this car for sale',
                        onTap: () async {
                          await nav.push(MaterialPageRoute(builder: (_) => CarListingScreen(carId: car.id)));
                          _refresh();
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
}

class _ManageTile extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;

  const _ManageTile({
    required this.step,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SurfaceCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: done ? AppColors.success.withValues(alpha: 0.12) : AppColors.cyanTint,
                borderRadius: BorderRadius.circular(AppRadii.md),
              ),
              child: Icon(done ? Icons.check_rounded : icon, color: done ? AppColors.success : AppColors.secondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Step $step · $title', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
