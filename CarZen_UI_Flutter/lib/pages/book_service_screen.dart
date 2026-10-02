import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/address_service.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/service_catalog_api.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/service_sheets.dart';
import 'package:carzen_flutter/widgets/service_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// Book one or more services for a car: services → car → date & time →
/// address → notes → review. Opened from the catalog (`/services/book?ids=…`).
///
/// Wrap with `RequireAuth(userOnly: true)`. Submits `POST /v1/service-requests`;
/// the total shown is an estimate, the backend calculates the real amount.
class BookServiceScreen extends StatefulWidget {
  final List<int> preselectedIds;
  const BookServiceScreen({super.key, this.preselectedIds = const []});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final _catalog = ServiceCatalogApi();
  final _requests = ServiceRequestApi();
  final _addresses = AddressService();
  final _notes = TextEditingController();

  // Services
  final Map<int, ServiceOffering> _services = {};
  bool _loadingServices = true;
  String? _servicesError;

  // Cars / addresses
  List<CarRecord>? _cars;
  Object? _carsError;
  List<AddressRecord>? _addressList;
  Object? _addressError;
  int? _carId;
  int? _addressId;

  // Date / time
  DateTime? _date;
  String? _time;
  List<ServiceSlot>? _slots;
  Object? _slotsError;
  bool _loadingSlots = false;

  bool _submitting = false;
  String? _submitError;

  @override
  void initState() {
    super.initState();
    _loadServices();
    _loadCars();
    _loadAddresses();
  }

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  // ---- loading ----

  Future<void> _loadServices() async {
    setState(() {
      _loadingServices = true;
      _servicesError = null;
    });
    final failed = <int>[];
    for (final id in widget.preselectedIds.toSet()) {
      if (_services.containsKey(id)) continue;
      try {
        _services[id] = await _catalog.get(id);
      } on ApiException catch (e) {
        if (e.isNetworkError || e.isAuthError) {
          if (mounted) {
            setState(() {
              _servicesError = e.message;
              _loadingServices = false;
            });
          }
          return;
        }
        failed.add(id); // inactive / deleted since the catalog was shown
      }
    }
    if (!mounted) return;
    setState(() {
      _loadingServices = false;
      if (failed.isNotEmpty) {
        _servicesError = failed.length == 1
            ? 'One selected service is no longer available and was removed.'
            : '${failed.length} selected services are no longer available and were removed.';
      }
    });
  }

  Future<void> _loadCars({int? selectId}) async {
    setState(() => _carsError = null);
    try {
      final cars = await _requests.listMyCars();
      if (!mounted) return;
      setState(() {
        _cars = cars;
        if (selectId != null) {
          _carId = selectId;
        } else if (_carId == null && cars.length == 1) {
          _carId = cars.first.id;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _carsError = e);
    }
  }

  Future<void> _loadAddresses({int? selectId}) async {
    setState(() => _addressError = null);
    try {
      final list = await _addresses.list();
      if (!mounted) return;
      setState(() {
        _addressList = list;
        if (selectId != null) {
          _addressId = selectId;
        } else if (_addressId == null && list.isNotEmpty) {
          _addressId = list.firstWhere((a) => a.isDefault, orElse: () => list.first).id;
        }
      });
    } catch (e) {
      if (mounted) setState(() => _addressError = e);
    }
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
      _slots = null;
      _time = null;
    });
    try {
      final slots = await _requests.slots(date);
      if (!mounted || _date != date) return;
      setState(() {
        _slots = slots;
        _loadingSlots = false;
      });
    } catch (e) {
      if (!mounted || _date != date) return;
      setState(() {
        _slotsError = e;
        _loadingSlots = false;
      });
    }
  }

  // ---- actions ----

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 90)),
      helpText: 'Choose a service date',
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    _loadSlots(picked);
  }

  Future<void> _addCar() async {
    final car = await AddServiceCarSheet.show(context);
    if (car != null && mounted) {
      showAppSnack(context, 'Car added.');
      _loadCars(selectId: car.id);
    }
  }

  Future<void> _addAddress() async {
    final address = await AddAddressSheet.show(context);
    if (address != null && mounted) {
      showAppSnack(context, 'Address saved.');
      _loadAddresses(selectId: address.id);
    }
  }

  Future<void> _addMoreServices() async {
    final chosen = await showModalBottomSheet<List<ServiceOffering>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ServicePickerSheet(alreadySelected: _services.keys.toSet()),
    );
    if (chosen == null || !mounted) return;
    setState(() {
      for (final s in chosen) {
        _services[s.id] = s;
      }
    });
  }

  bool _isPastToday(ServiceSlot slot) {
    final date = _date;
    if (date == null) return false;
    final now = DateTime.now();
    if (date.year != now.year || date.month != now.month || date.day != now.day) return false;
    final parts = slot.time.split(':');
    final h = int.tryParse(parts[0]) ?? 0;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return DateTime(now.year, now.month, now.day, h, m).isBefore(now);
  }

  num get _total => _services.values.fold<num>(0, (sum, s) => sum + s.price);

  /// Why the form can't be submitted yet, or null when it can.
  String? get _blocker {
    if (_services.isEmpty) return 'Choose at least one service.';
    if (_carId == null) return 'Choose the car to be serviced.';
    if (_date == null) return 'Choose a date.';
    if (_time == null) return 'Choose a time slot.';
    if (_addressId == null) return 'Choose or add an address.';
    return null;
  }

  Future<void> _submit() async {
    final blocker = _blocker;
    if (blocker != null) {
      setState(() => _submitError = blocker);
      return;
    }
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    try {
      final request = await _requests.create(
        carId: _carId!,
        serviceIds: _services.keys.toList(),
        addressId: _addressId!,
        date: _date!,
        time: _time!,
        notes: _notes.text,
      );
      if (!mounted) return;
      showAppSnack(context, 'Service request #${request.id} sent. We will confirm it shortly.');
      Navigator.of(context).pushReplacementNamed(AppRoutes.serviceRequest(request.id));
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.isAuthError) {
        Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
        return;
      }
      setState(() => _submitError = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ---- build ----

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isExpanded(context);
    final form = _buildForm(context);
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.services, title: 'Book a service'),
      bottomNavigationBar: wide ? null : _MobileSubmitBar(total: _total, submitting: _submitting, onSubmit: _submit),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: PageContainer(
            maxWidth: 1100,
            child: wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: form),
                      const SizedBox(width: 24),
                      SizedBox(width: 340, child: _buildSummary(context)),
                    ],
                  )
                : form,
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeader(
          title: 'Book a service',
          subtitle: 'Four quick steps. You can review everything before sending.',
          icon: Icons.event_available_rounded,
        ),
        const SizedBox(height: AppSpacing.xl),
        _StepCard(number: 1, title: 'Services', child: _servicesStep()),
        const SizedBox(height: AppSpacing.lg),
        _StepCard(number: 2, title: 'Your car', child: _carStep()),
        const SizedBox(height: AppSpacing.lg),
        _StepCard(number: 3, title: 'Date & time', child: _dateStep()),
        const SizedBox(height: AppSpacing.lg),
        _StepCard(number: 4, title: 'Address & notes', child: _addressStep()),
        if (!Breakpoints.isExpanded(context)) ...[
          const SizedBox(height: AppSpacing.lg),
          _buildSummary(context, compact: true),
        ],
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _servicesStep() {
    if (_loadingServices) return const SkeletonBox(height: 76, radius: AppRadii.md);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_servicesError != null) InlineError(_servicesError!),
        if (_services.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No services selected yet.', style: TextStyle(color: AppColors.textSecondary)),
          ),
        for (final s in _services.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppRadii.md),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: NetworkPhoto(url: s.imageUrl, fallbackIcon: Icons.build_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          [formatInr(s.price), if (s.durationMinutes != null) formatDuration(s.durationMinutes!)].join(' · '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Remove ${s.name}',
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => setState(() => _services.remove(s.id)),
                  ),
                ],
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _addMoreServices,
            icon: const Icon(Icons.add_rounded),
            label: Text(_services.isEmpty ? 'Choose services' : 'Add more services'),
          ),
        ),
      ],
    );
  }

  Widget _carStep() {
    if (_carsError != null) {
      return ApiErrorView(error: _carsError!, onRetry: () => _loadCars(), fallback: 'Could not load your cars.');
    }
    final cars = _cars;
    if (cars == null) return const SkeletonBox(height: 76, radius: AppRadii.md);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (cars.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'You have not added a car yet. Add the car you want serviced — it is only used for bookings.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ),
        for (final car in cars)
          _ChoiceTile(
            selected: _carId == car.id,
            icon: Icons.directions_car_filled_rounded,
            title: [
              '${car.manufacturingYear}',
              if (car.registrationNumber != null && car.registrationNumber!.isNotEmpty) car.registrationNumber!,
            ].join(' · '),
            subtitle: [car.fuelType.label, car.transmission.label, if (car.color != null && car.color!.isNotEmpty) car.color!, car.city]
                .join(' · '),
            onTap: () => setState(() => _carId = car.id),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: _addCar, icon: const Icon(Icons.add_rounded), label: const Text('Add a car')),
        ),
      ],
    );
  }

  Widget _dateStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _pickDate,
          icon: const Icon(Icons.calendar_month_rounded),
          label: Text(_date == null ? 'Choose a date' : formatDate(_date)),
          style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
        ),
        const SizedBox(height: 14),
        if (_date == null)
          const Text('Pick a date to see the available time slots.', style: TextStyle(color: AppColors.textSecondary))
        else if (_loadingSlots)
          const SkeletonBox(height: 48, radius: AppRadii.md)
        else if (_slotsError != null)
          ApiErrorView(error: _slotsError!, onRetry: () => _loadSlots(_date!), fallback: 'Could not load time slots.')
        else if (_slots != null && _slots!.isEmpty)
          const Text('No time slots are offered on this date. Try another day.', style: TextStyle(color: AppColors.textSecondary))
        else if (_slots != null) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final slot in _slots!)
                ChoiceChip(
                  label: Text(formatClock(slot.time)),
                  selected: _time == slot.time,
                  showCheckmark: false,
                  selectedColor: AppColors.primary,
                  disabledColor: AppColors.surfaceMuted,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    decoration: (!slot.available || _isPastToday(slot)) ? TextDecoration.lineThrough : null,
                    color: _time == slot.time
                        ? Colors.white
                        : (!slot.available || _isPastToday(slot))
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                  ),
                  onSelected: (!slot.available || _isPastToday(slot)) ? null : (_) => setState(() => _time = slot.time),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Struck-through times are already booked or have passed.', style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }

  Widget _addressStep() {
    if (_addressError != null) {
      return ApiErrorView(error: _addressError!, onRetry: () => _loadAddresses(), fallback: 'Could not load your addresses.');
    }
    final list = _addressList;
    if (list == null) return const SkeletonBox(height: 76, radius: AppRadii.md);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (list.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text(
              'Add the address where the service should take place. We need one to confirm your request.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.45),
            ),
          ),
        for (final a in list)
          _ChoiceTile(
            selected: _addressId == a.id,
            icon: Icons.location_on_outlined,
            title: a.isDefault ? '${a.addressLine1}  (default)' : a.addressLine1,
            subtitle: [a.city, a.state, a.postalCode].join(', '),
            onTap: () => setState(() => _addressId = a.id),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(onPressed: _addAddress, icon: const Icon(Icons.add_rounded), label: const Text('Add an address')),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notes,
          maxLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Notes for the workshop (optional)',
            hintText: 'Anything we should know about your car?',
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }

  Widget _buildSummary(BuildContext context, {bool compact = false}) {
    final blocker = _blocker;
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (_services.isEmpty)
            const Text('No services yet.', style: TextStyle(color: AppColors.textSecondary))
          else
            for (final s in _services.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(s.name, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    Text(formatInr(s.price), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
          const Divider(height: 24),
          Row(
            children: [
              const Expanded(child: Text('Estimated total', style: TextStyle(fontWeight: FontWeight.w700))),
              Text(formatInr(_total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Text('The final amount is confirmed by CarZen when the request is created.', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 14),
          _SummaryLine(Icons.event_rounded, _date == null ? 'Date not chosen' : '${formatDate(_date)}${_time == null ? '' : ' · ${formatClock(_time)}'}'),
          if (_carId != null && _cars != null)
            _SummaryLine(
              Icons.directions_car_outlined,
              _cars!.where((c) => c.id == _carId).map((c) => '${c.manufacturingYear} ${c.registrationNumber ?? ''}'.trim()).firstOrNull ?? '',
            ),
          if (_submitError != null) ...[const SizedBox(height: 12), InlineError(_submitError!)],
          if (!compact) ...[
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary))
                  : const Text('Request service'),
            ),
            if (blocker != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(blocker, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              ),
          ],
        ],
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SummaryLine(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int number;
  final String title;
  final Widget child;
  const _StepCard({required this.number, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text('$number', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? AppColors.cyanTint : AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: selected ? AppColors.secondary : AppColors.divider, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: selected ? AppColors.secondary : AppColors.textSecondary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.secondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileSubmitBar extends StatelessWidget {
  final num total;
  final bool submitting;
  final VoidCallback onSubmit;
  const _MobileSubmitBar({required this.total, required this.submitting, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Estimated total', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    Text(formatInr(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: submitting ? null : onSubmit,
                child: submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary))
                    : const Text('Request service'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Paginated, searchable picker used by "Add more services".
class _ServicePickerSheet extends StatefulWidget {
  final Set<int> alreadySelected;
  const _ServicePickerSheet({required this.alreadySelected});

  @override
  State<_ServicePickerSheet> createState() => _ServicePickerSheetState();
}

class _ServicePickerSheetState extends State<_ServicePickerSheet> {
  final _api = ServiceCatalogApi();
  final _search = TextEditingController();
  late final PagedController<ServiceOffering> _paged;
  String _query = '';
  final Map<int, ServiceOffering> _picked = {};

  @override
  void initState() {
    super.initState();
    _paged = PagedController<ServiceOffering>(
      limit: 6,
      fetch: (page, limit) => _api.list(page: page, limit: limit, search: _query),
    )..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9, maxWidth: 640),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + MediaQuery.viewInsetsOf(context).bottom),
          child: AnimatedBuilder(
            animation: _paged,
            builder: (context, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Choose services', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(hintText: 'Search services', prefixIcon: Icon(Icons.search_rounded)),
                  onSubmitted: (v) {
                    _query = v.trim();
                    _paged.reset();
                  },
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _paged.isFirstLoad
                      ? const LoadingView()
                      : (_paged.error != null && !_paged.hasData)
                          ? ApiErrorView(error: _paged.error!, onRetry: _paged.refresh)
                          : !_paged.hasData
                              ? const EmptyStateView(title: 'No services found', message: 'Try a different search.')
                              : ListView(
                                  children: [
                                    for (final s in _paged.items)
                                      CheckboxListTile(
                                        value: widget.alreadySelected.contains(s.id) || _picked.containsKey(s.id),
                                        onChanged: widget.alreadySelected.contains(s.id)
                                            ? null
                                            : (v) => setState(() {
                                                  if (v == true) {
                                                    _picked[s.id] = s;
                                                  } else {
                                                    _picked.remove(s.id);
                                                  }
                                                }),
                                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                                        subtitle: Text(
                                          [formatInr(s.price), if (s.durationMinutes != null) formatDuration(s.durationMinutes!)].join(' · '),
                                        ),
                                        controlAffinity: ListTileControlAffinity.leading,
                                      ),
                                  ],
                                ),
                ),
                PaginationBar(meta: _paged.meta, busy: _paged.loading, itemLabel: 'services', onPageChanged: _paged.goTo),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_picked.values.toList()),
                  child: Text(_picked.isEmpty ? 'Done' : 'Add ${_picked.length} service${_picked.length == 1 ? '' : 's'}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
