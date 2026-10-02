import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/service_catalog_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// Admin service catalog — `/v1/admin/services` (paginated, status + search
/// filters) with create, edit, activate / deactivate and delete.
/// Wrap with `RequireAuth(adminOnly: true)`.
class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  final _api = ServiceCatalogApi();
  final _searchController = TextEditingController();
  late final PagedController<ServiceOffering> _paged;

  String _search = '';

  /// `null` = all, otherwise `active` / `inactive` (the backend's filter values).
  String? _status;

  /// Ids with an action in flight (disables their menu).
  final Set<int> _busy = {};

  @override
  void initState() {
    super.initState();
    _paged = PagedController<ServiceOffering>(
      limit: 10,
      fetch: (page, limit) => _api.adminList(page: page, limit: limit, status: _status, search: _search),
    )..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _setStatus(String? status) {
    _status = status;
    _paged.reset();
  }

  void _submitSearch(String value) {
    _search = value.trim();
    _paged.reset();
  }

  Future<void> _edit([ServiceOffering? service]) async {
    final saved = await showDialog<ServiceOffering>(
      context: context,
      builder: (_) => _ServiceFormDialog(api: _api, existing: service),
    );
    if (saved == null || !mounted) return;
    showAppSnack(context, service == null ? 'Service "${saved.name}" created.' : 'Service "${saved.name}" updated.');
    // A new service starts active and is sorted by the backend; show it from page 1.
    service == null ? _paged.reset() : _paged.refresh();
  }

  Future<void> _run(ServiceOffering service, Future<Object?> Function() action, String success) async {
    setState(() => _busy.add(service.id));
    try {
      await action();
      if (!mounted) return;
      showAppSnack(context, success);
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(service.id));
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
    bool danger = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: danger ? FilledButton.styleFrom(backgroundColor: AppColors.favorite) : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );
    return result == true;
  }

  Future<void> _toggleActive(ServiceOffering service) async {
    if (service.isActive) {
      final ok = await _confirm(
        title: 'Deactivate "${service.name}"?',
        message: 'Customers will no longer see or book this service. Existing requests are not affected. You can activate it again later.',
        action: 'Deactivate',
      );
      if (!ok) return;
      await _run(service, () => _api.adminDeactivate(service.id), '"${service.name}" deactivated.');
    } else {
      await _run(service, () => _api.adminActivate(service.id), '"${service.name}" is active again.');
    }
  }

  Future<void> _delete(ServiceOffering service) async {
    final ok = await _confirm(
      title: 'Delete "${service.name}"?',
      message: 'The service is removed from the catalog. Past requests that used it keep their record. This cannot be undone from the app.',
      action: 'Delete',
      danger: true,
    );
    if (!ok) return;
    await _run(service, () => _api.adminDelete(service.id), '"${service.name}" deleted.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.adminServices, title: 'Service Catalog'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.adminServices),
      floatingActionButton: Breakpoints.isCompact(context)
          ? FloatingActionButton.extended(onPressed: _edit, icon: const Icon(Icons.add_rounded), label: const Text('New service'))
          : null,
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
                      title: 'Service catalog',
                      subtitle: _paged.meta == null
                          ? 'Create and manage the services customers can book.'
                          : '${formatCount(_paged.meta!.total)} service${_paged.meta!.total == 1 ? '' : 's'} match the current filters.',
                      icon: Icons.build_circle_rounded,
                      actions: Breakpoints.isCompact(context)
                          ? const []
                          : [FilledButton.icon(onPressed: _edit, icon: const Icon(Icons.add_rounded), label: const Text('New service'))],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _filters(),
                    const SizedBox(height: AppSpacing.lg),
                    if (_paged.loading && _paged.hasData) const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator(minHeight: 3)),
                    _body(),
                    const SizedBox(height: AppSpacing.xl),
                    PaginationBar(meta: _paged.meta, busy: _paged.loading, itemLabel: 'services', onPageChanged: _paged.goTo),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filters() {
    final search = TextField(
      controller: _searchController,
      textInputAction: TextInputAction.search,
      onSubmitted: _submitSearch,
      decoration: InputDecoration(
        hintText: 'Search by service name',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  tooltip: 'Clear search',
                  onPressed: () {
                    _searchController.clear();
                    _submitSearch('');
                  },
                ),
        ),
      ),
    );
    final status = SegmentedButton<String>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: 'all', label: Text('All')),
        ButtonSegment(value: 'active', label: Text('Active')),
        ButtonSegment(value: 'inactive', label: Text('Inactive')),
      ],
      selected: {_status ?? 'all'},
      onSelectionChanged: (s) => _setStatus(s.first == 'all' ? null : s.first),
    );
    if (Breakpoints.isCompact(context)) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [search, const SizedBox(height: 10), status]);
    }
    return Row(children: [Expanded(child: search), const SizedBox(width: 12), status]);
  }

  Widget _body() {
    if (_paged.isFirstLoad) {
      return Column(children: [
        for (var i = 0; i < 4; i++) const Padding(padding: EdgeInsets.only(bottom: 12), child: SkeletonBox(height: 96, radius: AppRadii.lg)),
      ]);
    }
    if (_paged.error != null && !_paged.hasData) {
      return SizedBox(height: 360, child: ApiErrorView(error: _paged.error!, onRetry: _paged.refresh, fallback: 'Could not load services.'));
    }
    if (!_paged.hasData) {
      final filtered = _search.isNotEmpty || _status != null;
      return SizedBox(
        height: 360,
        child: EmptyStateView(
          icon: Icons.build_circle_outlined,
          title: filtered ? 'No services match these filters' : 'The catalog is empty',
          message: filtered ? 'Change the search or status filter.' : 'Create the first service so customers can start booking.',
          action: filtered
              ? OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    _search = '';
                    _setStatus(null);
                  },
                  child: const Text('Clear filters'),
                )
              : FilledButton(onPressed: _edit, child: const Text('Create service')),
        ),
      );
    }
    return Column(
      children: [
        if (_paged.error != null) InlineError('Could not refresh: ${_paged.error}'),
        for (final s in _paged.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ServiceRow(
              service: s,
              busy: _busy.contains(s.id),
              onEdit: () => _edit(s),
              onToggle: () => _toggleActive(s),
              onDelete: () => _delete(s),
            ),
          ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final ServiceOffering service;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _ServiceRow({required this.service, required this.busy, required this.onEdit, required this.onToggle, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final s = service;
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      onTap: busy ? null : onEdit,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: SizedBox(width: 72, height: 72, child: NetworkPhoto(url: s.imageUrl, fallbackIcon: Icons.build_rounded)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(s.name, style: Theme.of(context).textTheme.titleMedium),
                    StatusPill(label: s.isActive ? 'Active' : 'Inactive', tone: s.isActive ? StatusTone.success : StatusTone.neutral),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [formatInr(s.price), if (s.durationMinutes != null) formatDuration(s.durationMinutes!)].join(' · '),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
                if (s.description != null && s.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(s.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (busy)
            const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5)))
          else
            PopupMenuButton<String>(
              tooltip: 'Actions',
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                  case 'toggle':
                    onToggle();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit_outlined), title: Text('Edit'), contentPadding: EdgeInsets.zero)),
                PopupMenuItem(
                  value: 'toggle',
                  child: ListTile(
                    leading: Icon(s.isActive ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    title: Text(s.isActive ? 'Deactivate' : 'Activate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline_rounded, color: AppColors.favorite),
                    title: Text('Delete', style: TextStyle(color: AppColors.favorite)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Create (`POST /v1/admin/services`) or edit (`PATCH /v1/admin/services/{id}`).
/// Pops with the saved [ServiceOffering]. Edit sends only the fields that changed.
class _ServiceFormDialog extends StatefulWidget {
  final ServiceCatalogApi api;
  final ServiceOffering? existing;
  const _ServiceFormDialog({required this.api, this.existing});

  @override
  State<_ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<_ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name = TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _description = TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _price = TextEditingController(text: widget.existing == null ? '' : _plain(widget.existing!.price));
  late final TextEditingController _duration =
      TextEditingController(text: widget.existing?.durationMinutes?.toString() ?? '');
  late final TextEditingController _image = TextEditingController(text: widget.existing?.imageUrl ?? '');
  bool _saving = false;
  String? _error;

  bool get _editing => widget.existing != null;

  static String _plain(num value) => value == value.roundToDouble() ? value.round().toString() : value.toString();

  @override
  void dispose() {
    for (final c in [_name, _description, _price, _duration, _image]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    final name = _name.text.trim();
    final description = _description.text.trim();
    final price = num.parse(_price.text.trim());
    final duration = _duration.text.trim().isEmpty ? null : int.parse(_duration.text.trim());
    final image = _image.text.trim();
    try {
      final ServiceOffering saved;
      if (_editing) {
        final old = widget.existing!;
        final changes = <String, dynamic>{
          if (name != old.name) 'name': name,
          if (description != (old.description ?? '')) 'description': description,
          if (price != old.price) 'price': price,
          if (duration != null && duration != old.durationMinutes) 'duration_minutes': duration,
          if (image != (old.imageUrl ?? '')) 'image_url': image,
        };
        if (changes.isEmpty) {
          // Nothing changed: close without claiming anything was saved.
          Navigator.of(context).pop();
          return;
        }
        saved = await widget.api.adminUpdate(old.id, changes);
      } else {
        saved = await widget.api.adminCreate(
          name: name,
          description: description,
          price: price,
          durationMinutes: duration,
          imageUrl: image,
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(saved);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Edit service' : 'New service'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_error != null) InlineError(_error!),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name *'),
                  maxLength: 150,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _description,
                  decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                  maxLines: 3,
                  maxLength: 5000,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _price,
                        decoration: const InputDecoration(labelText: 'Price (₹) *'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          final value = num.tryParse((v ?? '').trim());
                          if (value == null) return 'Enter a price';
                          if (value <= 0) return 'Must be above 0';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _duration,
                        decoration: const InputDecoration(labelText: 'Duration (min)'),
                        keyboardType: TextInputType.number,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          final value = int.tryParse(v.trim());
                          if (value == null || value <= 0) return 'Whole minutes > 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _image,
                  decoration: const InputDecoration(labelText: 'Image URL', hintText: 'https://…'),
                  keyboardType: TextInputType.url,
                  maxLength: 500,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return null;
                    final uri = Uri.tryParse(value);
                    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) return 'Use a full http(s) link';
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
              : Text(_editing ? 'Save changes' : 'Create service'),
        ),
      ],
    );
  }
}
