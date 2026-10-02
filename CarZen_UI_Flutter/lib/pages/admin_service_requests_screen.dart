import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/service_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';

/// Admin service-request queue — `/v1/admin/service-requests` (paginated,
/// status filter) plus the lifecycle actions the backend supports: accept,
/// reject, schedule, start, complete and cancel. Payment actions are not
/// part of this app. Wrap with `RequireAuth(adminOnly: true)`.
class AdminServiceRequestsScreen extends StatefulWidget {
  const AdminServiceRequestsScreen({super.key});

  @override
  State<AdminServiceRequestsScreen> createState() => _AdminServiceRequestsScreenState();
}

/// Which lifecycle actions the backend accepts for a status
/// (`service_request_service.py`, `admin_*_request`).
Set<String> _actionsFor(ServiceRequestStatus status) => switch (status) {
      ServiceRequestStatus.requested => {'accept', 'schedule', 'reject', 'cancel'},
      ServiceRequestStatus.accepted => {'schedule', 'start', 'complete', 'reject', 'cancel'},
      ServiceRequestStatus.scheduled => {'schedule', 'start', 'complete', 'cancel'},
      ServiceRequestStatus.inProgress => {'complete', 'cancel'},
      ServiceRequestStatus.completed || ServiceRequestStatus.cancelled || ServiceRequestStatus.rejected => <String>{},
    };

class _AdminServiceRequestsScreenState extends State<AdminServiceRequestsScreen> {
  final _api = ServiceRequestApi();
  late final PagedController<ServiceRequestRecord> _paged;
  ServiceRequestStatus? _status;

  @override
  void initState() {
    super.initState();
    _paged = PagedController<ServiceRequestRecord>(
      limit: 10,
      fetch: (page, limit) => _api.adminList(page: page, limit: limit, status: _status),
    )..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _setStatus(ServiceRequestStatus? status) {
    _status = status;
    _paged.reset();
  }

  Future<void> _open(ServiceRequestRecord request) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _RequestSheet(api: _api, initial: request),
    );
    if (changed == true && mounted) _paged.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.adminServiceRequests, title: 'Service Requests'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.adminServiceRequests),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _paged.refresh,
          child: AnimatedBuilder(
            animation: _paged,
            builder: (context, _) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: PageContainer(
                maxWidth: 1000,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PageHeader(
                      title: 'Service requests',
                      subtitle: _paged.meta == null
                          ? 'Review, schedule and complete customer bookings.'
                          : '${formatCount(_paged.meta!.total)} request${_paged.meta!.total == 1 ? '' : 's'} ${_status == null ? 'in total' : 'with status ${_status!.label.toLowerCase()}'}.',
                      icon: Icons.assignment_rounded,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        _chip('All', null),
                        for (final s in ServiceRequestStatus.values) _chip(s.label, s),
                      ]),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_paged.loading && _paged.hasData) const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator(minHeight: 3)),
                    _body(),
                    const SizedBox(height: AppSpacing.xl),
                    PaginationBar(meta: _paged.meta, busy: _paged.loading, itemLabel: 'requests', onPageChanged: _paged.goTo),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(String label, ServiceRequestStatus? value) {
    final on = _status == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: on,
        showCheckmark: false,
        selectedColor: AppColors.cyanTint,
        side: BorderSide(color: on ? AppColors.secondary : AppColors.divider),
        labelStyle: TextStyle(fontWeight: FontWeight.w700, color: on ? AppColors.secondary : AppColors.textPrimary),
        onSelected: (_) => _setStatus(value),
      ),
    );
  }

  Widget _body() {
    if (_paged.isFirstLoad) {
      return Column(children: [
        for (var i = 0; i < 4; i++) const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 120, radius: AppRadii.lg)),
      ]);
    }
    if (_paged.error != null && !_paged.hasData) {
      return SizedBox(height: 360, child: ApiErrorView(error: _paged.error!, onRetry: _paged.refresh, fallback: 'Could not load service requests.'));
    }
    if (!_paged.hasData) {
      return SizedBox(
        height: 360,
        child: EmptyStateView(
          icon: Icons.assignment_outlined,
          title: _status == null ? 'No service requests yet' : 'No ${_status!.label.toLowerCase()} requests',
          message: _status == null ? 'Customer bookings will show up here.' : 'Try another status.',
          action: _status == null ? null : OutlinedButton(onPressed: () => _setStatus(null), child: const Text('Show all')),
        ),
      );
    }
    return Column(
      children: [
        if (_paged.error != null) InlineError('Could not refresh: ${_paged.error}'),
        for (final r in _paged.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ServiceRequestCard(request: r, showCustomer: true, onTap: () => _open(r)),
          ),
      ],
    );
  }
}

/// Details of one request plus the actions allowed for its current status.
class _RequestSheet extends StatefulWidget {
  final ServiceRequestApi api;
  final ServiceRequestRecord initial;
  const _RequestSheet({required this.api, required this.initial});

  @override
  State<_RequestSheet> createState() => _RequestSheetState();
}

class _RequestSheetState extends State<_RequestSheet> {
  late ServiceRequestRecord _request = widget.initial;
  bool _changed = false;
  bool _busy = false;
  String? _error;

  Future<void> _run(Future<ServiceRequestRecord> Function() action, String success) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final updated = await action();
      if (!mounted) return;
      setState(() {
        _request = updated;
        _changed = true;
      });
      showAppSnack(context, success);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String message, String action) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Not now')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(action)),
        ],
      ),
    );
    return ok == true;
  }

  /// A dialog with one text field. Returns the text, or null when dismissed.
  Future<String?> _askText({
    required String title,
    required String label,
    required String action,
    bool required = false,
    bool danger = false,
  }) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            maxLines: 3,
            maxLength: 2000,
            decoration: InputDecoration(labelText: required ? '$label *' : label, alignLabelWithHint: true),
            validator: required ? (v) => (v == null || v.trim().isEmpty) ? 'Please enter a reason' : null : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
          FilledButton(
            style: danger ? FilledButton.styleFrom(backgroundColor: AppColors.favorite) : null,
            onPressed: () {
              if (formKey.currentState!.validate()) Navigator.pop(context, controller.text.trim());
            },
            child: Text(action),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _accept() async {
    if (!await _confirm('Accept request #${_request.id}?', 'The customer will be notified that the request is accepted.', 'Accept')) return;
    await _run(() => widget.api.adminAccept(_request.id), 'Request accepted.');
  }

  Future<void> _start() async {
    if (!await _confirm('Start work on #${_request.id}?', 'The request moves to In progress.', 'Start work')) return;
    await _run(() => widget.api.adminStart(_request.id), 'Work started.');
  }

  Future<void> _reject() async {
    final note = await _askText(title: 'Reject request #${_request.id}', label: 'Reason for the customer', action: 'Reject', required: true, danger: true);
    if (note == null) return;
    await _run(() => widget.api.adminReject(_request.id, note), 'Request rejected.');
  }

  Future<void> _cancel() async {
    final note = await _askText(title: 'Cancel request #${_request.id}', label: 'Reason (optional)', action: 'Cancel request', danger: true);
    if (note == null) return;
    await _run(() => widget.api.adminCancel(_request.id, notes: note), 'Request cancelled.');
  }

  Future<void> _schedule() async {
    final result = await showDialog<_ScheduleResult>(
      context: context,
      builder: (_) => _ScheduleDialog(api: widget.api, request: _request),
    );
    if (result == null) return;
    await _run(
      () => widget.api.adminSchedule(_request.id, date: result.date, time: result.time, adminNote: result.note),
      'Appointment scheduled for ${formatDate(result.date)} at ${formatClock(result.time)}.',
    );
  }

  Future<void> _complete() async {
    final result = await showDialog<_CompleteResult>(context: context, builder: (_) => _CompleteDialog(request: _request));
    if (result == null) return;
    await _run(
      () => widget.api.adminComplete(
        _request.id,
        adminNote: result.note,
        odometerReading: result.odometer,
        partsCost: result.parts,
        laborCost: result.labor,
        nextServiceDate: result.nextDate,
        nextServiceMileage: result.nextMileage,
      ),
      'Request completed and added to the car\'s service history.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = _request;
    final actions = _actionsFor(r.status);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_changed);
      },
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92, maxWidth: 720),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Request #${r.id}', style: Theme.of(context).textTheme.headlineSmall)),
                    StatusPill(label: r.status.label, tone: r.status.tone),
                  ],
                ),
                const SizedBox(height: 4),
                Text(r.title, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 16),
                RequestProgress(request: r),
                const SizedBox(height: 16),
                if (_error != null) InlineError(_error!),
                if (r.user != null) ...[
                  DetailRow('Customer', r.user!.displayName, emphasize: true),
                  DetailRow('Email', r.user!.email),
                  if (r.user!.phoneNumber != null && r.user!.phoneNumber!.isNotEmpty) DetailRow('Phone', r.user!.phoneNumber!),
                ],
                if (r.car != null) DetailRow('Car', r.car!.label),
                DetailRow('Appointment', '${formatDate(r.scheduledDate)} · ${formatClock(r.scheduledTime)}', emphasize: true),
                for (final item in r.items)
                  DetailRow(
                    item == r.items.first ? 'Services' : '',
                    '${item.serviceName}  —  ${formatInr(item.unitPrice)}',
                  ),
                DetailRow('Total', formatInr(r.amount), emphasize: true),
                if (r.paymentStatus.isNotEmpty) DetailRow('Payment', paymentInfo(r)),
                if (r.notes != null && r.notes!.isNotEmpty) DetailRow('Customer notes', r.notes!),
                if (r.adminNote != null && r.adminNote!.isNotEmpty) DetailRow('Admin note', r.adminNote!),
                const SizedBox(height: 16),
                if (actions.isEmpty)
                  Text('This request is ${r.status.label.toLowerCase()}; no further actions are available.', style: Theme.of(context).textTheme.bodySmall)
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (actions.contains('accept'))
                        FilledButton.icon(onPressed: _busy ? null : _accept, icon: const Icon(Icons.check_rounded), label: const Text('Accept')),
                      if (actions.contains('schedule'))
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _schedule,
                          icon: const Icon(Icons.event_rounded),
                          label: Text(r.status == ServiceRequestStatus.scheduled ? 'Reschedule' : 'Schedule'),
                        ),
                      if (actions.contains('start'))
                        FilledButton.icon(onPressed: _busy ? null : _start, icon: const Icon(Icons.play_arrow_rounded), label: const Text('Start work')),
                      if (actions.contains('complete'))
                        FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                          onPressed: _busy ? null : _complete,
                          icon: const Icon(Icons.task_alt_rounded),
                          label: const Text('Complete'),
                        ),
                      if (actions.contains('reject'))
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _reject,
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.favorite),
                          icon: const Icon(Icons.block_rounded),
                          label: const Text('Reject'),
                        ),
                      if (actions.contains('cancel'))
                        OutlinedButton.icon(
                          onPressed: _busy ? null : _cancel,
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.favorite),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Cancel request'),
                        ),
                    ],
                  ),
                if (_busy) const Padding(padding: EdgeInsets.only(top: 14), child: LinearProgressIndicator(minHeight: 3)),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.of(context).pop(_changed), child: const Text('Close')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScheduleResult {
  final DateTime date;
  final String time;
  final String? note;
  const _ScheduleResult(this.date, this.time, this.note);
}

/// Date + slot picker for `POST …/schedule`.
class _ScheduleDialog extends StatefulWidget {
  final ServiceRequestApi api;
  final ServiceRequestRecord request;
  const _ScheduleDialog({required this.api, required this.request});

  @override
  State<_ScheduleDialog> createState() => _ScheduleDialogState();
}

class _ScheduleDialogState extends State<_ScheduleDialog> {
  late DateTime _date = widget.request.scheduledDate;
  String? _time;
  List<ServiceSlot>? _slots;
  Object? _error;
  bool _loading = true;
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final date = _date;
    setState(() {
      _loading = true;
      _error = null;
      _time = null;
    });
    try {
      final slots = await widget.api.slots(date);
      if (!mounted || date != _date) return;
      setState(() {
        _slots = slots;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || date != _date) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isBefore(today) ? today : _date,
      firstDate: today,
      lastDate: today.add(const Duration(days: 180)),
    );
    if (picked == null || !mounted) return;
    setState(() => _date = picked);
    _load();
  }

  bool _past(ServiceSlot slot) {
    final now = DateTime.now();
    if (_date.year != now.year || _date.month != now.month || _date.day != now.day) return false;
    final p = slot.time.split(':');
    return DateTime(now.year, now.month, now.day, int.tryParse(p[0]) ?? 0, p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0).isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Schedule request #${widget.request.id}'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(formatDate(_date)),
                style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
              ),
              const SizedBox(height: 14),
              if (_loading)
                const SkeletonBox(height: 44, radius: AppRadii.md)
              else if (_error != null)
                ApiErrorView(error: _error!, onRetry: _load, fallback: 'Could not load time slots.')
              else if (_slots == null || _slots!.isEmpty)
                const Text('No time slots are offered on this date.')
              else
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
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: (!slot.available || _past(slot)) ? TextDecoration.lineThrough : null,
                          color: _time == slot.time ? Colors.white : ((!slot.available || _past(slot)) ? AppColors.textSecondary : AppColors.textPrimary),
                        ),
                        onSelected: (!slot.available || _past(slot)) ? null : (_) => setState(() => _time = slot.time),
                      ),
                  ],
                ),
              const SizedBox(height: 14),
              TextField(
                controller: _note,
                maxLines: 2,
                maxLength: 2000,
                decoration: const InputDecoration(labelText: 'Note for the customer (optional)', alignLabelWithHint: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
        FilledButton(
          onPressed: _time == null ? null : () => Navigator.pop(context, _ScheduleResult(_date, _time!, _note.text)),
          child: const Text('Schedule'),
        ),
      ],
    );
  }
}

class _CompleteResult {
  final String? note;
  final num? odometer;
  final num? parts;
  final num? labor;
  final DateTime? nextDate;
  final num? nextMileage;
  const _CompleteResult({this.note, this.odometer, this.parts, this.labor, this.nextDate, this.nextMileage});
}

/// All fields are optional in `ServiceRequestAdminComplete`; the values end up
/// on the car's permanent service record.
class _CompleteDialog extends StatefulWidget {
  final ServiceRequestRecord request;
  const _CompleteDialog({required this.request});

  @override
  State<_CompleteDialog> createState() => _CompleteDialogState();
}

class _CompleteDialogState extends State<_CompleteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _note = TextEditingController();
  final _odometer = TextEditingController();
  final _parts = TextEditingController();
  final _labor = TextEditingController();
  final _nextMileage = TextEditingController();
  DateTime? _nextDate;

  @override
  void dispose() {
    for (final c in [_note, _odometer, _parts, _labor, _nextMileage]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _optionalNumber(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final n = num.tryParse(v.trim());
    if (n == null || n < 0) return 'Enter a number (0 or more)';
    return null;
  }

  num? _num(TextEditingController c) => c.text.trim().isEmpty ? null : num.parse(c.text.trim());

  Widget _field(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(labelText: label),
          validator: _optionalNumber,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Complete request #${widget.request.id}'),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Everything below is optional. It is saved on the car\'s service history.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _note,
                  maxLines: 2,
                  maxLength: 2000,
                  decoration: const InputDecoration(labelText: 'Work completion notes', alignLabelWithHint: true),
                ),
                const SizedBox(height: 8),
                _field(_odometer, 'Odometer reading (km)'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _field(_parts, 'Parts cost (₹)')),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_labor, 'Labour cost (₹)')),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _nextDate ?? now.add(const Duration(days: 180)),
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 1500)),
                          );
                          if (picked != null) setState(() => _nextDate = picked);
                        },
                        icon: const Icon(Icons.event_repeat_rounded),
                        label: Text(_nextDate == null ? 'Next service date' : formatDate(_nextDate)),
                        style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft),
                      ),
                    ),
                    if (_nextDate != null) IconButton(tooltip: 'Clear', onPressed: () => setState(() => _nextDate = null), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: 12),
                _field(_nextMileage, 'Next service at (km)'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _CompleteResult(
                note: _note.text,
                odometer: _num(_odometer),
                parts: _num(_parts),
                labor: _num(_labor),
                nextDate: _nextDate,
                nextMileage: _num(_nextMileage),
              ),
            );
          },
          child: const Text('Mark completed'),
        ),
      ],
    );
  }
}
