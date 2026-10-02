import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';
import 'add_edit_car_screen.dart';
import 'car_manage_screen.dart';

StatusTone approvalTone(CarApprovalStatus status) => switch (status) {
      CarApprovalStatus.approved || CarApprovalStatus.published => StatusTone.success,
      CarApprovalStatus.rejected => StatusTone.danger,
      CarApprovalStatus.sold || CarApprovalStatus.inactive => StatusTone.neutral,
      CarApprovalStatus.draft => StatusTone.neutral,
      CarApprovalStatus.pendingApproval => StatusTone.warning,
    };

/// The Sell Car page: the signed-in user's own cars — `GET /v1/cars`
/// (paginated). A short guide explains the four steps of selling; each car
/// opens [CarManageScreen]; "Add car" opens [AddEditCarScreen].
class MyCarsScreen extends StatefulWidget {
  const MyCarsScreen({super.key});

  @override
  State<MyCarsScreen> createState() => _MyCarsScreenState();
}

class _MyCarsScreenState extends State<MyCarsScreen> {
  final _carService = CarService();
  late final PagedController<CarRecord> _paged;

  /// True when the backend refused because it still ties selling to a legacy
  /// role (see [ApiException.isRoleRestriction]); the page then explains it
  /// instead of offering actions that would fail.
  bool get _sellingUnavailable {
    final e = _paged.error;
    return e is ApiException && e.isRoleRestriction;
  }

  @override
  void initState() {
    super.initState();
    _paged = PagedController<CarRecord>(
      limit: 8,
      fetch: (page, limit) => _carService.listMyCars(page: page, limit: limit),
    )..load();
    _paged.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _paged.removeListener(_onChanged);
    _paged.dispose();
    super.dispose();
  }

  Future<void> _addCar() async {
    final created = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const AddEditCarScreen()));
    if (created == true) _paged.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.sell, title: 'Sell Car'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.sell),
      floatingActionButton: _sellingUnavailable
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add car'),
              onPressed: _addCar,
            ),
      body: SafeArea(
        bottom: false,
        child: PagedListView<CarRecord>(
          controller: _paged,
          maxWidth: 900,
          itemLabel: 'cars',
          header: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(
                title: 'Sell your car',
                subtitle: 'List a car in four simple steps. Your cars and their progress are below.',
                icon: Icons.sell_rounded,
              ),
              if (!_sellingUnavailable) ...[const SizedBox(height: AppSpacing.lg), const _HowItWorks()],
              if (_paged.meta != null && _paged.hasData) ...[
                const SizedBox(height: AppSpacing.xl),
                SectionTitle('Your cars', subtitle: '${formatCount(_paged.meta!.total)} in total'),
              ],
            ],
          ),
          empty: _sellingUnavailable
              ? const SizedBox.shrink()
              : EmptyStateView(
                  icon: Icons.directions_car_outlined,
                  title: 'No cars yet',
                  message: 'Add your first car to start selling. It only takes a few minutes.',
                  action: FilledButton.icon(onPressed: _addCar, icon: const Icon(Icons.add_rounded), label: const Text('Add your first car')),
                ),
          errorFallback: 'Could not load your cars.',
          itemBuilder: (context, car) => _OwnedCarTile(
            car: car,
            onTap: () async {
              await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CarManageScreen(carId: car.id)));
              if (mounted) _paged.refresh();
            },
          ),
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const _steps = <(IconData, String, String)>[
    (Icons.edit_note_rounded, 'Add details', 'Brand, model, year, mileage and location.'),
    (Icons.photo_camera_outlined, 'Photos & features', 'Good photos help buyers trust your car.'),
    (Icons.fact_check_outlined, 'Approval', 'The CarZen team reviews your car.'),
    (Icons.campaign_outlined, 'Publish', 'Set a price and go live in the marketplace.'),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    Widget step(int i) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.cyanTint, borderRadius: BorderRadius.circular(AppRadii.md)),
              child: Icon(_steps[i].$1, size: 20, color: AppColors.secondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i + 1}. ${_steps[i].$2}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(_steps[i].$3, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        );
    return SurfaceCard(
      padding: const EdgeInsets.all(18),
      child: compact
          ? Column(children: [for (var i = 0; i < _steps.length; i++) Padding(padding: EdgeInsets.only(bottom: i == _steps.length - 1 ? 0 : 14), child: step(i))])
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [for (var i = 0; i < _steps.length; i++) ...[Expanded(child: step(i)), if (i < _steps.length - 1) const SizedBox(width: 14)]],
            ),
    );
  }
}

class _OwnedCarTile extends StatelessWidget {
  final CarRecord car;
  final VoidCallback onTap;
  const _OwnedCarTile({required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.cyanTint, borderRadius: BorderRadius.circular(AppRadii.md)),
            child: const Icon(Icons.directions_car_rounded, color: AppColors.secondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    '${car.manufacturingYear}',
                    if (car.registrationNumber != null && car.registrationNumber!.isNotEmpty) car.registrationNumber!,
                  ].join(' · '),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text('${car.fuelType.label} · ${car.transmission.label} · ${car.city}', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusPill(label: car.approvalStatus.label, tone: approvalTone(car.approvalStatus)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
