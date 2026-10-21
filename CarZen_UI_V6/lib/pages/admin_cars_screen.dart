import 'package:carzen_flutter/config/api_config.dart';
import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/admin_widgets.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

String adminApprovalLabel(CarApprovalStatus s) => switch (s) {
      CarApprovalStatus.pendingApproval => 'Pending review',
      CarApprovalStatus.approved => 'Approved',
      CarApprovalStatus.rejected => 'Rejected',
      CarApprovalStatus.draft => 'Draft',
      CarApprovalStatus.published => 'Published',
      CarApprovalStatus.sold => 'Sold',
      CarApprovalStatus.inactive => 'Inactive',
    };

StatusTone adminApprovalTone(CarApprovalStatus s) => switch (s) {
      CarApprovalStatus.approved || CarApprovalStatus.published => StatusTone.success,
      CarApprovalStatus.rejected => StatusTone.danger,
      CarApprovalStatus.pendingApproval => StatusTone.warning,
      CarApprovalStatus.sold => StatusTone.info,
      _ => StatusTone.neutral,
    };

/// Shared moderation actions (list rows and the detail page).
mixin _CarModeration<W extends StatefulWidget> on State<W> {
  final carService = CarService();

  Future<CarRecordDetail?> moderate(int carId, Future<CarRecordDetail> Function() action, String success) async {
    try {
      final updated = await action();
      if (mounted) showAppSnack(context, success);
      return updated;
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
      return null;
    }
  }

  Future<CarRecordDetail?> approve(int carId) => moderate(carId, () => carService.approveCar(carId), 'Car approved. The owner can now list it.');

  Future<CarRecordDetail?> reject(int carId) async {
    final reason = await showReasonDialog(
      context,
      title: 'Reject this car?',
      message: 'The owner sees this reason and can fix the details and resubmit.',
      label: 'Reason for the owner',
      hint: 'e.g. The registration number does not match the photos',
      confirmLabel: 'Reject car',
      minLength: 5,
      destructive: true,
    );
    if (reason == null) return null;
    return moderate(carId, () => carService.rejectCar(carId, reason), 'Car rejected. The owner has been told why.');
  }

  Future<CarRecordDetail?> toggleVerified(CarRecord car) => car.isVerified
      ? moderate(car.id, () => carService.unverifyCar(car.id), 'Verified badge removed')
      : moderate(car.id, () => carService.verifyCar(car.id), 'Car marked as verified');
}

/// Car approvals - `GET /v1/admin/cars` and the approve / reject / verify
/// actions.
class AdminCarsScreen extends StatefulWidget {
  const AdminCarsScreen({super.key});

  @override
  State<AdminCarsScreen> createState() => _AdminCarsScreenState();
}

class _AdminCarsScreenState extends State<AdminCarsScreen> with _CarModeration {
  CarApprovalStatus? _filter = CarApprovalStatus.pendingApproval;
  String _search = '';
  final Set<int> _busy = {};

  /// The list endpoint has no make/model or owner, so each visible car's
  /// detail is fetched once and cached.
  final Map<int, CarRecordDetail> _details = {};
  final Set<int> _loadingDetails = {};

  late final _paged = PagedController<CarRecord>(
    limit: 10,
    fetch: (page, limit) async {
      final result = await carService.listAdminCars(page: page, limit: limit, status: _filter, search: _search);
      _fetchDetails(result.data);
      return result;
    },
  )..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _fetchDetails(List<CarRecord> cars) {
    for (final car in cars) {
      if (_details.containsKey(car.id) || _loadingDetails.contains(car.id)) continue;
      _loadingDetails.add(car.id);
      carService.getAdminCar(car.id).then((d) {
        if (mounted) setState(() => _details[car.id] = d);
      }).catchError((Object _) {}).whenComplete(() => _loadingDetails.remove(car.id));
    }
  }

  void _setFilter(CarApprovalStatus? f) {
    setState(() => _filter = f);
    _paged.reset();
  }

  Future<void> _run(int carId, Future<CarRecordDetail?> Function() action) async {
    setState(() => _busy.add(carId));
    final updated = await action();
    if (updated != null) _details[carId] = updated;
    if (mounted) setState(() => _busy.remove(carId));
    if (updated != null) await _paged.refresh();
  }

  String _title(CarRecord car) {
    final d = _details[car.id];
    return d == null ? '${car.manufacturingYear} car #${car.id}' : d.fullTitle;
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      section: NavSection.adminCars,
      title: 'Car approvals',
      subtitle: 'Check each submitted car before its owner can list it for sale.',
      onRefresh: _paged.refresh,
      filters: AdminFilterBar(children: [
        SegmentFilter<CarApprovalStatus?>(
          options: const [
            (CarApprovalStatus.pendingApproval, 'Pending'),
            (CarApprovalStatus.approved, 'Approved'),
            (CarApprovalStatus.rejected, 'Rejected'),
            (null, 'All'),
          ],
          selected: _filter,
          onChanged: _setFilter,
        ),
        AdminSearchField(
          hint: 'Search make, model or registration',
          onSubmitted: (v) {
            _search = v;
            _paged.reset();
          },
        ),
      ]),
      child: AdminPagedTable<CarRecord>(
        controller: _paged,
        itemLabel: 'cars',
        empty: EmptyStateView(
          compact: true,
          icon: Icons.fact_check_outlined,
          title: _filter == CarApprovalStatus.pendingApproval ? 'Nothing waiting for review' : 'No cars match',
          message: _filter == CarApprovalStatus.pendingApproval ? 'New submissions will appear here.' : 'Try another filter or search.',
        ),
        builder: (context, cars) => AdminTable<CarRecord>(
          items: cars,
          onTap: (c) => Navigator.of(context).pushNamed(AppRoutes.adminCar(c.id)).then((_) => _paged.refresh()),
          cardTitle: (c) => Text(_title(c)),
          cardBadge: (c) => StatusPill(label: adminApprovalLabel(c.approvalStatus), tone: adminApprovalTone(c.approvalStatus)),
          actionsWidth: 200,
          columns: [
            AdminColumn('Car', (c) => _CarCell(car: c, detail: _details[c.id]), flex: 5, showInCard: false),
            AdminColumn('Owner', (c) => TextCell(_details[c.id]?.owner.fullName ?? 'User #${c.ownerId}'), flex: 2),
            AdminColumn('Location', (c) => TextCell('${c.city}, ${c.state}'), flex: 2),
            AdminColumn('Submitted', (c) => TextCell(formatDate(c.createdAtDate)), flex: 2),
            AdminColumn(
              'Status',
              (c) => Wrap(spacing: 6, runSpacing: 4, children: [
                StatusPill(label: adminApprovalLabel(c.approvalStatus), tone: adminApprovalTone(c.approvalStatus)),
                if (c.isVerified) const StatusPill(label: 'Verified', tone: StatusTone.info, icon: Icons.verified_outlined),
              ]),
              flex: 3,
              showInCard: false,
            ),
          ],
          actions: (c) {
            final busy = _busy.contains(c.id);
            if (busy) return const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))];
            return [
              if (c.approvalStatus == CarApprovalStatus.pendingApproval) ...[
                RowAction('Approve', primary: true, onPressed: () => _run(c.id, () => approve(c.id))),
                RowAction('Reject', destructive: true, onPressed: () => _run(c.id, () => reject(c.id))),
              ] else if (c.approvalStatus == CarApprovalStatus.approved)
                RowAction(c.isVerified ? 'Unverify' : 'Verify', onPressed: () => _run(c.id, () => toggleVerified(c)))
              else
                RowAction('Review', onPressed: () => Navigator.of(context).pushNamed(AppRoutes.adminCar(c.id)).then((_) => _paged.refresh())),
            ];
          },
        ),
      ),
    );
  }
}

class _CarCell extends StatelessWidget {
  final CarRecord car;
  final CarRecordDetail? detail;
  const _CarCell({required this.car, required this.detail});

  @override
  Widget build(BuildContext context) {
    final d = detail;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          child: SizedBox(
            width: 64,
            height: 46,
            child: NetworkPhoto(url: d?.media.cover?.absoluteUrl(ApiConfig.baseUrl), cacheWidth: 140),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StackedCell(
            d == null ? '${car.manufacturingYear} car #${car.id}' : d.fullTitle,
            [car.registrationNumber ?? 'No registration', car.fuelType.label, formatKm(car.mileageKm)].join('  |  '),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Car detail (admin)
// ---------------------------------------------------------------------------

class AdminCarDetailScreen extends StatefulWidget {
  final int carId;
  const AdminCarDetailScreen({super.key, required this.carId});

  @override
  State<AdminCarDetailScreen> createState() => _AdminCarDetailScreenState();
}

class _AdminCarDetailScreenState extends State<AdminCarDetailScreen> with _CarModeration {
  CarRecordDetail? _car;
  Object? _error;
  bool _busy = false;
  int _photo = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final car = await carService.getAdminCar(widget.carId);
      if (mounted) setState(() => _car = car);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _run(Future<CarRecordDetail?> Function() action) async {
    setState(() => _busy = true);
    final updated = await action();
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (updated != null) _car = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final car = _car;
    if (car == null) {
      return AppScaffold(
        section: NavSection.adminCars,
        title: 'Car #${widget.carId}',
        fallbackRoute: AppRoutes.adminCars,
        showBackButton: true,
        body: _error != null
            ? ApiErrorView(error: _error!, onRetry: _load, fallback: 'This car could not be loaded.')
            : const LoadingView(label: 'Loading car...'),
      );
    }
    final wide = Breakpoints.widthOf(context) >= 1100;
    final photos = car.media.inDisplayOrder.where((m) => m.mediaType == MediaType.image).toList();
    final gallery = _Gallery(photos: photos, index: _photo.clamp(0, photos.isEmpty ? 0 : photos.length - 1), onSelect: (i) => setState(() => _photo = i));
    final facts = _Facts(car: car);
    final side = _ModerationPanel(
      car: car,
      busy: _busy,
      onApprove: () => _run(() => approve(car.id)),
      onReject: () => _run(() => reject(car.id)),
      onVerify: () => _run(() => toggleVerified(car)),
    );

    return AdminPage(
      section: NavSection.adminCars,
      title: car.fullTitle,
      subtitle: 'Car #${car.id}  |  Submitted ${formatDate(car.createdAtDate)}',
      fallbackRoute: AppRoutes.adminCars,
      onRefresh: _load,
      maxWidth: 1240,
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [gallery, const SizedBox(height: 20), facts])),
                const SizedBox(width: 24),
                SizedBox(width: 360, child: side),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [side, const SizedBox(height: 20), gallery, const SizedBox(height: 20), facts],
            ),
    );
  }
}

class _Gallery extends StatelessWidget {
  final List<CarMedia> photos;
  final int index;
  final ValueChanged<int> onSelect;
  const _Gallery({required this.photos, required this.index, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: const AspectRatio(aspectRatio: 16 / 9, child: PhotoFallback(label: 'No photos uploaded')),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: NetworkPhoto(url: photos[index].absoluteUrl(ApiConfig.baseUrl), semanticLabel: 'Photo ${index + 1} of ${photos.length}'),
          ),
        ),
        if (photos.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 64,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => Semantics(
                button: true,
                selected: i == index,
                label: 'Show photo ${i + 1}',
                child: InkWell(
                  onTap: () => onSelect(i),
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                  child: Container(
                    width: 88,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: i == index ? AppColors.ink : Colors.transparent, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: NetworkPhoto(url: photos[i].absoluteUrl(ApiConfig.baseUrl), cacheWidth: 180),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Facts extends StatelessWidget {
  final CarRecordDetail car;
  const _Facts({required this.car});

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      ('Registration', car.registrationNumber ?? 'Not given'),
      ('VIN', car.vinNumber ?? 'Not given'),
      ('Variant', car.variantName),
      ('Fuel', car.fuelType.label),
      ('Transmission', car.transmission.label),
      ('Kilometres', formatKm(car.mileageKm)),
      ('Manufactured', '${car.manufacturingYear}'),
      if (car.registrationYear != null) ('Registered', '${car.registrationYear}'),
      ('Condition', car.condition.label),
      if (car.ownerCount != null) ('Owners', '${car.ownerCount}'),
      if (car.ownershipType != null) ('Ownership', car.ownershipType!.label),
      if (car.color != null) ('Colour', car.color!),
      if (car.engineCc != null) ('Engine', '${car.engineCc} cc'),
      if (car.horsepower != null) ('Power', '${car.horsepower} bhp'),
      if (car.seatingCapacity != null) ('Seats', '${car.seatingCapacity}'),
      if (car.insuranceCompany != null) ('Insurer', car.insuranceCompany!),
      if (car.insuranceType != null) ('Insurance', car.insuranceType!),
      if (car.insuranceExpiry != null) ('Insurance until', car.insuranceExpiry!),
      if (car.rcStatus != null) ('RC status', car.rcStatus!),
      ('Location', [car.city, car.state, car.postalCode].whereType<String>().where((s) => s.isNotEmpty).join(', ')),
      if (car.expectedMarketPrice != null) ('Expected price', formatInr(car.expectedMarketPrice!)),
    ];
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle('Details'),
          LayoutBuilder(builder: (context, c) {
            final two = c.maxWidth >= 560;
            final half = (rows.length / 2).ceil();
            Widget col(List<(String, String)> r) => Column(children: [for (final x in r) InfoRow(label: x.$1, value: x.$2)]);
            return two
                ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: col(rows.sublist(0, half))),
                    const SizedBox(width: 28),
                    Expanded(child: col(rows.sublist(half))),
                  ])
                : col(rows);
          }),
          if ((car.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionTitle('Owner\'s description'),
            Text(car.description!, style: const TextStyle(height: 1.55)),
          ],
          if (car.features.isNotEmpty) ...[
            const SizedBox(height: 16),
            const SectionTitle('Features'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in car.features)
                  Chip(label: Text(f.featureValue == null || f.featureValue!.isEmpty ? f.featureName : '${f.featureName}: ${f.featureValue}')),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ModerationPanel extends StatelessWidget {
  final CarRecordDetail car;
  final bool busy;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onVerify;

  const _ModerationPanel({required this.car, required this.busy, required this.onApprove, required this.onReject, required this.onVerify});

  @override
  Widget build(BuildContext context) {
    final pending = car.approvalStatus == CarApprovalStatus.pendingApproval;
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            StatusPill(label: adminApprovalLabel(car.approvalStatus), tone: adminApprovalTone(car.approvalStatus)),
            const SizedBox(width: 8),
            if (car.isVerified) const StatusPill(label: 'Verified', tone: StatusTone.info, icon: Icons.verified_outlined),
          ]),
          if (car.approvalStatus == CarApprovalStatus.rejected && (car.rejectionReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 12),
            Callout(title: 'Rejection reason', message: car.rejectionReason!, tone: CalloutTone.danger),
          ],
          const SizedBox(height: 16),
          const Text('Owner', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: StackedCell(car.owner.fullName, '@${car.owner.username}')),
              TextButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.adminUser(car.ownerId)), child: const Text('View user')),
            ],
          ),
          const Divider(height: 28),
          if (busy)
            const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()))
          else if (pending) ...[
            const Text('Does everything match the photos and documents?', style: TextStyle(height: 1.45)),
            const SizedBox(height: 12),
            FilledButton(onPressed: onApprove, child: const Text('Approve car')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
              child: const Text('Reject with a reason'),
            ),
          ] else if (car.approvalStatus == CarApprovalStatus.approved) ...[
            Text(
              car.isVerified
                  ? 'Buyers see a Verified badge on this car.'
                  : 'Add the Verified badge once you have inspected the car or its documents.',
              style: const TextStyle(height: 1.45),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onVerify,
              icon: Icon(car.isVerified ? Icons.remove_moderator_outlined : Icons.verified_outlined, size: 18),
              label: Text(car.isVerified ? 'Remove Verified badge' : 'Mark as verified'),
            ),
          ] else
            Text(
              car.approvalStatus == CarApprovalStatus.rejected
                  ? 'Waiting for the owner to update the car and resubmit it.'
                  : 'No moderation action is available in this state.',
              style: const TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
        ],
      ),
    );
  }
}
