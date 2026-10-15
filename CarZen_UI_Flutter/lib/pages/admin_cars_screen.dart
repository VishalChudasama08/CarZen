// TODO(Ayush): gap C — list endpoint lacks seller/brand (fetched lazily with detail cache)
import 'package:flutter/material.dart';
import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/service_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';

/// Admin car moderation — `GET /v1/admin/cars` (paginated, status filter)
/// and `POST /v1/admin/cars/{id}/approve|reject|verify|unverify`.
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
  final Map<int, CarRecordDetail> _detailCache = {};

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

  Future<void> _runAction(int carId, Future<CarRecordDetail> Function() action, String success) async {
    setState(() => _busy.add(carId));
    try {
      final updated = await action();
      _detailCache[carId] = updated;
      if (!mounted) return;
      showAppSnack(context, success);
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(carId));
    }
  }

  Future<void> _openCarDetail(CarRecord car) async {
    CarRecordDetail? detail = _detailCache[car.id];
    if (detail == null) {
      try {
        detail = await _carService.getAdminCar(car.id);
        _detailCache[car.id] = detail;
      } on ApiException catch (e) {
        if (mounted) showAppSnack(context, e.message, error: true);
        return;
      }
    }

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CarDetailSheet(
        car: detail!,
        busy: _busy.contains(car.id),
        onApprove: () async {
          Navigator.pop(ctx);
          await _runAction(car.id, () => _carService.approveCar(car.id), 'Car approved.');
        },
        onReject: () async {
          Navigator.pop(ctx);
          await _reject(car.id);
        },
        onVerifyToggle: () async {
          Navigator.pop(ctx);
          if (car.isVerified) {
            await _runAction(car.id, () => _carService.unverifyCar(car.id), 'Verification removed.');
          } else {
            await _runAction(car.id, () => _carService.verifyCar(car.id), 'Car verified.');
          }
        },
      ),
    );
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
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(
        current: NavSection.adminCars,
        title: 'Car Approvals',
        fallbackRoute: AppRoutes.admin,
      ),
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
                  ? 'Review cars submitted by sellers.'
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
            final cached = _detailCache[car.id];

            final title = cached != null
                ? '${car.manufacturingYear} ${cached.brandName} ${cached.modelName}'
                : '${car.manufacturingYear} Car #${car.id}';
            final seller = cached?.owner.fullName;

            return SurfaceCard(
              onTap: () => _openCarDetail(car),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(label: car.approvalStatus.label, tone: _tone(car.approvalStatus)),
                      if (car.isVerified) ...[
                        const SizedBox(width: 6),
                        const StatusPill(label: 'Verified', tone: StatusTone.success),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    [
                      if (seller != null) 'Seller: $seller' else 'Owner ID #${car.ownerId}',
                      '#${car.id}',
                      '${car.city}, ${car.state}',
                      car.fuelType.label,
                      car.transmission.label,
                      formatKm(car.mileageKm),
                    ].join(' · '),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => _openCarDetail(car),
                        icon: const Icon(Icons.open_in_new_rounded, size: 16),
                        label: const Text('View full details'),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (car.approvalStatus == CarApprovalStatus.pendingApproval) ...[
                            FilledButton(
                              onPressed: busy ? null : () => _runAction(car.id, () => _carService.approveCar(car.id), 'Car approved.'),
                              style: FilledButton.styleFrom(minimumSize: const Size(80, 36)),
                              child: const Text('Approve'),
                            ),
                            OutlinedButton(
                              onPressed: busy ? null : () => _reject(car.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.favorite,
                                minimumSize: const Size(70, 36),
                              ),
                              child: const Text('Reject'),
                            ),
                          ],
                          if (car.approvalStatus == CarApprovalStatus.approved) ...[
                            Tooltip(
                              message: 'Toggles trust verification badge for approved cars',
                              child: OutlinedButton.icon(
                                onPressed: busy
                                    ? null
                                    : () => car.isVerified
                                        ? _runAction(car.id, () => _carService.unverifyCar(car.id), 'Verification removed.')
                                        : _runAction(car.id, () => _carService.verifyCar(car.id), 'Car marked as verified.'),
                                style: OutlinedButton.styleFrom(minimumSize: const Size(120, 36)),
                                icon: Icon(car.isVerified ? Icons.verified_rounded : Icons.verified_outlined, size: 16),
                                label: Text(car.isVerified ? 'Remove verified' : 'Mark as verified'),
                              ),
                            ),
                          ],
                          if (busy)
                            const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                        ],
                      ),
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

class _CarDetailSheet extends StatelessWidget {
  final CarRecordDetail car;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onVerifyToggle;

  const _CarDetailSheet({
    required this.car,
    required this.busy,
    required this.onApprove,
    required this.onReject,
    required this.onVerifyToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${car.manufacturingYear} ${car.brandName} ${car.modelName}',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                      ),
                      Text(
                        'Owner: ${car.owner.fullName} (@${car.owner.username}) · Car #${car.id}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (car.media.isNotEmpty) ...[
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: car.media.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final m = car.media[i];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: NetworkPhoto(
                                url: m.absoluteUrl(ApiConfig.baseUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text('Specifications', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DetailRow('Registration Number', car.registrationNumber ?? 'Not provided'),
                  DetailRow('Fuel Type', car.fuelType.label),
                  DetailRow('Transmission', car.transmission.label),
                  DetailRow('Mileage', formatKm(car.mileageKm)),
                  DetailRow('Condition', car.condition.label),
                  DetailRow('Location', '${car.city}, ${car.state}'),
                  if (car.expectedMarketPrice != null)
                    DetailRow('Expected Market Price', formatInr(car.expectedMarketPrice!)),
                  if (car.features.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Features', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final f in car.features)
                          Chip(
                            label: Text(
                              f.featureValue == null ? f.featureName : '${f.featureName}: ${f.featureValue}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (car.approvalStatus == CarApprovalStatus.pendingApproval) ...[
                  FilledButton(
                    onPressed: busy ? null : onApprove,
                    child: const Text('Approve car'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: busy ? null : onReject,
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.favorite),
                    child: const Text('Reject car'),
                  ),
                  const SizedBox(width: 10),
                ],
                if (car.approvalStatus == CarApprovalStatus.approved) ...[
                  Tooltip(
                    message: 'Toggles trust verification badge for approved cars',
                    child: OutlinedButton.icon(
                      onPressed: busy ? null : onVerifyToggle,
                      icon: Icon(car.isVerified ? Icons.verified_rounded : Icons.verified_outlined, size: 16),
                      label: Text(car.isVerified ? 'Remove verification' : 'Mark as verified'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
