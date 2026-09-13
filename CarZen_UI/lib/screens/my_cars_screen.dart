import 'package:flutter/material.dart';
import '../models/car_models.dart';
import '../models/enums.dart';
import '../services/api_exception.dart';
import '../services/car_service.dart';
import '../theme/app_theme.dart';
import '../widgets/state_views.dart';
import 'add_edit_car_screen.dart';
import 'car_manage_screen.dart';

/// The signed-in user's own car listings — `GET /v1/cars`. Each row opens
/// [CarManageScreen] (edit / media / features / listing). The FAB opens
/// [AddEditCarScreen] to create a new car.
class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final _carService = CarService();
  late Future<List<CarRecord>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _carService.listMyCars(limit: 50).then((p) => p.data);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Cars'), backgroundColor: AppColors.background),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Car'),
        onPressed: () async {
          final created = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddEditCarScreen()),
          );
          if (created == true) _refresh();
        },
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<CarRecord>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const LoadingView(label: 'Loading your cars...');
              }
              if (snapshot.hasError) {
                final message =
                    snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Could not load your cars.';
                return ErrorStateView(message: message, onRetry: _refresh);
              }
              final cars = snapshot.data!;
              if (cars.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 80),
                    EmptyStateView(
                      icon: Icons.directions_car_outlined,
                      title: 'No cars yet',
                      message: 'Tap "Add Car" to list your first car for sale.',
                    ),
                  ],
                );
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                itemCount: cars.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final car = cars[index];
                  return _OwnedCarTile(
                    car: car,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CarManageScreen(carId: car.id)),
                      );
                      _refresh();
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OwnedCarTile extends StatelessWidget {
  final CarRecord car;
  final VoidCallback onTap;
  const _OwnedCarTile({required this.car, required this.onTap});

  Color _statusColor() {
    switch (car.approvalStatus.apiValue) {
      case 'approved':
      case 'published':
        return AppColors.success;
      case 'rejected':
        return AppColors.favorite;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.directions_car_rounded, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${car.manufacturingYear} · ${car.city}',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5)),
                  const SizedBox(height: 4),
                  Text('${car.fuelType.label} · ${car.transmission.label}',
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                car.approvalStatus.label,
                style: TextStyle(color: _statusColor(), fontWeight: FontWeight.w700, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
