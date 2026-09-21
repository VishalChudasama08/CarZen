import 'package:carzen_flutter/widgets/content_width.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/state_views.dart';

/// Admin-only car moderation — `GET /v1/admin/cars`,
/// `POST /v1/admin/cars/{id}/approve|reject|verify|unverify`.
/// Only reachable from [ProfileScreen] when `role == "admin"`.
class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  final _carService = CarService();
  CarApprovalStatus? _filter = CarApprovalStatus.pendingApproval;
  late Future<List<CarRecord>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _carService.listAdminCars(limit: 50, status: _filter).then((p) => p.data);
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  Future<void> _approve(int carId) => _runAction(() => _carService.approveCar(carId));
  Future<void> _verify(int carId) => _runAction(() => _carService.verifyCar(carId));
  Future<void> _unverify(int carId) => _runAction(() => _carService.unverifyCar(carId));

  Future<void> _reject(int carId) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Car'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Reason (min 5 characters)'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reject')),
        ],
      ),
    );
    if (confirmed != true || controller.text.trim().length < 5) return;
    await _runAction(() => _carService.rejectCar(carId, controller.text.trim()));
  }

  Future<void> _runAction(Future<void> Function() action) async {
    try {
      await action();
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
      appBar: const CarZenNavBar(current: NavSection.adminCars, title: 'Car Approvals'),
      body: ContentWidth(
        maxWidth: 1000,
        child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _FilterChip(
                        label: 'Pending',
                        selected: _filter == CarApprovalStatus.pendingApproval,
                        onTap: () => setState(() {
                              _filter = CarApprovalStatus.pendingApproval;
                              _load();
                            })),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Approved',
                        selected: _filter == CarApprovalStatus.approved,
                        onTap: () => setState(() {
                              _filter = CarApprovalStatus.approved;
                              _load();
                            })),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'Rejected',
                        selected: _filter == CarApprovalStatus.rejected,
                        onTap: () => setState(() {
                              _filter = CarApprovalStatus.rejected;
                              _load();
                            })),
                    const SizedBox(width: 8),
                    _FilterChip(
                        label: 'All',
                        selected: _filter == null,
                        onTap: () => setState(() {
                              _filter = null;
                              _load();
                            })),
                  ],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: FutureBuilder<List<CarRecord>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LoadingView(label: 'Loading cars...');
                    }
                    if (snapshot.hasError) {
                      final message = snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Could not load cars.';
                      return ErrorStateView(message: message, onRetry: _refresh);
                    }
                    final cars = snapshot.data!;
                    if (cars.isEmpty) {
                      return ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 80),
                          EmptyStateView(title: 'No cars', message: 'Nothing matches this filter right now.'),
                        ],
                      );
                    }
                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      itemCount: cars.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final car = cars[index];
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${car.manufacturingYear} · ${car.city}, ${car.state}',
                                  style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 3),
                              Text('${car.fuelType.label} · ${car.transmission.label} · ${car.approvalStatus.label}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (car.approvalStatus == CarApprovalStatus.pendingApproval) ...[
                                    OutlinedButton(onPressed: () => _approve(car.id), child: const Text('Approve')),
                                    OutlinedButton(
                                      onPressed: () => _reject(car.id),
                                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.favorite),
                                      child: const Text('Reject'),
                                    ),
                                  ],
                                  OutlinedButton(
                                    onPressed: () => car.isVerified ? _unverify(car.id) : _verify(car.id),
                                    child: Text(car.isVerified ? 'Unverify' : 'Verify'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label, style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontSize: 13)),
      ),
    );
  }
}
