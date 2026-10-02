import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// Admin-only car moderation — `GET /v1/admin/cars` (paginated, status
/// filter) and `POST /v1/admin/cars/{id}/approve|reject|verify|unverify`.
class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> {
  final _carService = CarService();
  late final PagedController<CarRecord> _paged;
  CarApprovalStatus? _filter = CarApprovalStatus.pendingApproval;
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _paged = PagedController<CarRecord>(
      limit: 10,
      fetch: (page, limit) => _carService.listAdminCars(page: page, limit: limit, status: _filter),
    )..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _setFilter(CarApprovalStatus? filter) {
    setState(() => _filter = filter);
    _paged.reset();
  }

  Future<void> _reject(int carId) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject car'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(labelText: 'Reason for the owner *', alignLabelWithHint: true),
            maxLines: 3,
            validator: (v) => (v == null || v.trim().length < 5) ? 'Please give a reason (at least 5 characters)' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, controller.text.trim());
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (reason == null) return;
    await _runAction(carId, () => _carService.rejectCar(carId, reason), 'Car rejected.');
  }

  Future<void> _runAction(int carId, Future<void> Function() action, String success) async {
    setState(() => _busy.add(carId));
    try {
      await action();
      if (!mounted) return;
      showAppSnack(context, success);
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(carId));
    }
  }

  Widget _chip(String label, CarApprovalStatus? value) {
    final on = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: on,
        showCheckmark: false,
        selectedColor: AppColors.cyanTint,
        side: BorderSide(color: on ? AppColors.secondary : AppColors.divider),
        labelStyle: TextStyle(fontWeight: FontWeight.w700, color: on ? AppColors.secondary : AppColors.textPrimary),
        onSelected: (_) => _setFilter(value),
      ),
    );
  }

  StatusTone _tone(CarApprovalStatus s) => switch (s) {
        CarApprovalStatus.approved => StatusTone.success,
        CarApprovalStatus.rejected => StatusTone.danger,
        _ => StatusTone.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.adminCars, title: 'Car Approvals'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.adminCars),
      body: SafeArea(
        bottom: false,
        child: PagedListView<CarRecord>(
          controller: _paged,
          maxWidth: 1000,
          itemLabel: 'cars',
          header: AnimatedBuilder(
            animation: _paged,
            builder: (context, _) => PageHeader(
              title: 'Car approvals',
              subtitle: _paged.meta == null
                  ? 'Review cars submitted by users.'
                  : '${formatCount(_paged.meta!.total)} car${_paged.meta!.total == 1 ? '' : 's'} match this filter.',
              icon: Icons.fact_check_rounded,
            ),
          ),
          filters: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _chip('Pending', CarApprovalStatus.pendingApproval),
              _chip('Approved', CarApprovalStatus.approved),
              _chip('Rejected', CarApprovalStatus.rejected),
              _chip('All', null),
            ]),
          ),
          empty: const EmptyStateView(
            icon: Icons.fact_check_outlined,
            title: 'No cars here',
            message: 'Nothing matches this filter right now.',
          ),
          errorFallback: 'Could not load cars.',
          itemBuilder: (context, car) {
            final busy = _busy.contains(car.id);
            return SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${car.manufacturingYear} · ${car.city}, ${car.state}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      StatusPill(label: car.approvalStatus.label, tone: _tone(car.approvalStatus)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      'Car #${car.id}',
                      car.fuelType.label,
                      car.transmission.label,
                      formatKm(car.mileageKm),
                      if (car.isVerified) 'Verified',
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (car.approvalStatus == CarApprovalStatus.pendingApproval) ...[
                        FilledButton(
                          onPressed: busy ? null : () => _runAction(car.id, () => _carService.approveCar(car.id), 'Car approved.'),
                          child: const Text('Approve'),
                        ),
                        OutlinedButton(
                          onPressed: busy ? null : () => _reject(car.id),
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.favorite),
                          child: const Text('Reject'),
                        ),
                      ],
                      OutlinedButton(
                        onPressed: busy
                            ? null
                            : () => car.isVerified
                                ? _runAction(car.id, () => _carService.unverifyCar(car.id), 'Verification removed.')
                                : _runAction(car.id, () => _carService.verifyCar(car.id), 'Car verified.'),
                        child: Text(car.isVerified ? 'Remove verification' : 'Verify'),
                      ),
                      if (busy) const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
