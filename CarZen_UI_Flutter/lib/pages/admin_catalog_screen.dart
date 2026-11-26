import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/utils/slugs.dart';
import 'package:carzen_flutter/widgets/admin_widgets.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/form_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';

/// The make / model / variant catalogue that sellers pick from.
/// Brands `/v1/car-brands`, models `/v1/car-models`, variants `/v1/car-variants`.
class AdminCatalogScreen extends StatefulWidget {
  const AdminCatalogScreen({super.key});

  @override
  State<AdminCatalogScreen> createState() => _AdminCatalogScreenState();
}

class _AdminCatalogScreenState extends State<AdminCatalogScreen> {
  final _service = CatalogService();

  List<CatalogBrand>? _brands;
  List<CatalogCarModel>? _models;
  List<CatalogVariant>? _variants;
  Object? _brandsError;
  Object? _modelsError;
  Object? _variantsError;
  String _search = '';

  CatalogBrand? _brand;
  CatalogCarModel? _model;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  Future<void> _loadBrands() async {
    setState(() => _brandsError = null);
    try {
      final res = await _service.listBrands(limit: 100, search: _search.isEmpty ? null : _search);
      if (!mounted) return;
      setState(() {
        _brands = res.data;
        if (_brand != null) _brand = res.data.where((b) => b.id == _brand!.id).firstOrNull ?? _brand;
      });
    } catch (e) {
      if (mounted) setState(() => _brandsError = e);
    }
  }

  Future<void> _loadModels() async {
    final brand = _brand;
    if (brand == null) return;
    setState(() {
      _modelsError = null;
      _models = null;
    });
    try {
      final res = await _service.listModelsForBrand(brand.id);
      if (mounted && _brand?.id == brand.id) setState(() => _models = res.data);
    } catch (e) {
      if (mounted) setState(() => _modelsError = e);
    }
  }

  Future<void> _loadVariants() async {
    final model = _model;
    if (model == null) return;
    setState(() {
      _variantsError = null;
      _variants = null;
    });
    try {
      final res = await _service.listVariantsForModel(model.id);
      if (mounted && _model?.id == model.id) setState(() => _variants = res.data);
    } catch (e) {
      if (mounted) setState(() => _variantsError = e);
    }
  }

  void _selectBrand(CatalogBrand? b) {
    setState(() {
      _brand = b;
      _model = null;
      _models = null;
      _variants = null;
    });
    _loadModels();
  }

  void _selectModel(CatalogCarModel? m) {
    setState(() {
      _model = m;
      _variants = null;
    });
    _loadVariants();
  }

  Future<void> _guard(Future<void> Function() action, String done) async {
    try {
      await action();
      if (mounted) showAppSnack(context, done);
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  // ---- brand actions ----

  Future<void> _editBrand([CatalogBrand? b]) async {
    final saved = await showDialog<bool>(context: context, builder: (_) => _BrandDialog(service: _service, brand: b));
    if (saved == true) {
      if (mounted) showAppSnack(context, b == null ? 'Brand added' : 'Brand updated');
      await _loadBrands();
    }
  }

  Future<void> _toggleBrand(CatalogBrand b) => _guard(() async {
        await _service.setBrandStatus(b.id, !b.isActive);
        await _loadBrands();
      }, b.isActive ? '${b.name} hidden from sellers' : '${b.name} available to sellers');

  Future<void> _deleteBrand(CatalogBrand b) async {
    final ok = await confirmAction(context,
        title: 'Delete ${b.name}?',
        message: 'Only brands with no models or cars can be deleted. Hiding the brand is usually safer.',
        confirmLabel: 'Delete brand',
        destructive: true);
    if (!ok) return;
    await _guard(() async {
      await _service.deleteBrand(b.id);
      if (_brand?.id == b.id) _selectBrand(null);
      await _loadBrands();
    }, '${b.name} deleted');
  }

  // ---- model actions ----

  Future<void> _editModel([CatalogCarModel? m]) async {
    final brand = _brand;
    if (brand == null) return;
    final saved = await showDialog<bool>(context: context, builder: (_) => _ModelDialog(service: _service, brand: brand, model: m));
    if (saved == true) {
      if (mounted) showAppSnack(context, m == null ? 'Model added' : 'Model updated');
      await _loadModels();
    }
  }

  Future<void> _toggleModel(CatalogCarModel m) => _guard(() async {
        await _service.setModelStatus(m.id, !m.isActive);
        await _loadModels();
      }, m.isActive ? '${m.name} hidden from sellers' : '${m.name} available to sellers');

  Future<void> _deleteModel(CatalogCarModel m) async {
    final ok = await confirmAction(context,
        title: 'Delete ${m.name}?',
        message: 'Only models with no variants or cars can be deleted.',
        confirmLabel: 'Delete model',
        destructive: true);
    if (!ok) return;
    await _guard(() async {
      await _service.deleteModel(m.id);
      if (_model?.id == m.id) _selectModel(null);
      await _loadModels();
    }, '${m.name} deleted');
  }

  // ---- variant actions ----

  Future<void> _editVariant([CatalogVariant? v]) async {
    final model = _model;
    if (model == null) return;
    final saved = await showDialog<bool>(context: context, builder: (_) => _VariantDialog(service: _service, model: model, variant: v));
    if (saved == true) {
      if (mounted) showAppSnack(context, v == null ? 'Variant added' : 'Variant updated');
      await _loadVariants();
    }
  }

  Future<void> _deleteVariant(CatalogVariant v) async {
    final ok = await confirmAction(context,
        title: 'Delete ${v.variantName}?',
        message: 'Only variants that no car uses can be deleted.',
        confirmLabel: 'Delete variant',
        destructive: true);
    if (!ok) return;
    await _guard(() async {
      await _service.deleteVariant(v.id);
      await _loadVariants();
    }, '${v.variantName} deleted');
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      section: NavSection.adminCatalog,
      title: 'Car catalogue',
      subtitle: 'The makes, models and variants sellers choose from when they add a car.',
      onRefresh: _loadBrands,
      child: LayoutBuilder(builder: (context, c) {
        final brands = _brandsColumn();
        final models = _modelsColumn();
        final variants = _variantsColumn();
        if (c.maxWidth >= 1000) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: brands),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: models),
              const SizedBox(width: 16),
              Expanded(flex: 5, child: variants),
            ],
          );
        }
        // Narrow: drill down brand -> model -> variants.
        if (_model != null) return variants;
        if (_brand != null) return models;
        return brands;
      }),
    );
  }

  bool get _narrow => MediaQuery.sizeOf(context).width < 1000 + 300;

  Widget _brandsColumn() {
    final brands = _brands;
    return _Pane(
      title: 'Brands',
      count: brands?.length,
      action: FilledButton.icon(onPressed: () => _editBrand(), icon: const Icon(Icons.add, size: 18), label: const Text('Brand')),
      header: AdminSearchField(
        hint: 'Search brands',
        width: double.infinity,
        onSubmitted: (v) {
          _search = v;
          _loadBrands();
        },
      ),
      child: _brandsError != null
          ? ApiErrorView(error: _brandsError!, onRetry: _loadBrands, compact: true)
          : brands == null
              ? const _PaneLoading()
              : brands.isEmpty
                  ? const EmptyStateView(compact: true, icon: Icons.category_outlined, title: 'No brands', message: 'Add the first brand.')
                  : Column(children: [
                      for (final b in brands)
                        _Row(
                          title: b.name,
                          subtitle: [b.slug, if (b.country != null) b.country!].join('  |  '),
                          selected: _brand?.id == b.id,
                          inactive: !b.isActive,
                          onTap: () => _selectBrand(b),
                          menu: [
                            ('Edit', () => _editBrand(b)),
                            (b.isActive ? 'Hide from sellers' : 'Show to sellers', () => _toggleBrand(b)),
                            ('Delete', () => _deleteBrand(b)),
                          ],
                        ),
                    ]),
    );
  }

  Widget _modelsColumn() {
    final brand = _brand;
    final models = _models;
    return _Pane(
      title: brand == null ? 'Models' : brand.name,
      count: models?.length,
      onBack: brand != null && _narrow ? () => _selectBrand(null) : null,
      action: brand == null ? null : FilledButton.icon(onPressed: () => _editModel(), icon: const Icon(Icons.add, size: 18), label: const Text('Model')),
      child: brand == null
          ? const EmptyStateView(compact: true, icon: Icons.touch_app_outlined, title: 'Choose a brand', message: 'Its models are listed here.')
          : _modelsError != null
              ? ApiErrorView(error: _modelsError!, onRetry: _loadModels, compact: true)
              : models == null
                  ? const _PaneLoading()
                  : models.isEmpty
                      ? EmptyStateView(compact: true, icon: Icons.category_outlined, title: 'No models yet', message: 'Add the first ${brand.name} model.')
                      : Column(children: [
                          for (final m in models)
                            _Row(
                              title: m.name,
                              subtitle: [if (m.bodyType != null) m.bodyType!.label, if (m.seatingCapacity != null) '${m.seatingCapacity} seats', m.slug].join('  |  '),
                              selected: _model?.id == m.id,
                              inactive: !m.isActive,
                              onTap: () => _selectModel(m),
                              menu: [
                                ('Edit', () => _editModel(m)),
                                (m.isActive ? 'Hide from sellers' : 'Show to sellers', () => _toggleModel(m)),
                                ('Delete', () => _deleteModel(m)),
                              ],
                            ),
                        ]),
    );
  }

  Widget _variantsColumn() {
    final model = _model;
    final variants = _variants;
    return _Pane(
      title: model == null ? 'Variants' : '${model.name} variants',
      count: variants?.length,
      onBack: model != null && _narrow ? () => _selectModel(null) : null,
      action: model == null ? null : FilledButton.icon(onPressed: () => _editVariant(), icon: const Icon(Icons.add, size: 18), label: const Text('Variant')),
      child: model == null
          ? const EmptyStateView(compact: true, icon: Icons.touch_app_outlined, title: 'Choose a model', message: 'Its variants are listed here.')
          : _variantsError != null
              ? ApiErrorView(error: _variantsError!, onRetry: _loadVariants, compact: true)
              : variants == null
                  ? const _PaneLoading()
                  : variants.isEmpty
                      ? EmptyStateView(compact: true, icon: Icons.category_outlined, title: 'No variants yet', message: 'Add the first ${model.name} variant.')
                      : Column(children: [
                          for (final v in variants)
                            _Row(
                              title: v.variantName,
                              subtitle: [
                                v.fuelType.label,
                                v.transmission.label,
                                if (v.engineCc != null) '${v.engineCc} cc',
                                if (v.horsepower != null) '${v.horsepower} bhp',
                                if (v.exShowroomPrice != null) formatLakh(v.exShowroomPrice!),
                              ].join('  |  '),
                              menu: [('Edit', () => _editVariant(v)), ('Delete', () => _deleteVariant(v))],
                            ),
                        ]),
    );
  }
}

class _Pane extends StatelessWidget {
  final String title;
  final int? count;
  final Widget? action;
  final Widget? header;
  final Widget child;
  final VoidCallback? onBack;

  const _Pane({required this.title, required this.child, this.count, this.action, this.header, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
            child: Row(
              children: [
                if (onBack != null) IconButton(tooltip: 'Back', onPressed: onBack, icon: const Icon(Icons.arrow_back)),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: onBack == null ? 4 : 0),
                    child: Text(
                      count == null ? title : '$title ($count)',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.heading(16),
                    ),
                  ),
                ),
                ?action,
              ],
            ),
          ),
          if (header != null) Padding(padding: const EdgeInsets.fromLTRB(12, 0, 12, 10), child: header),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }
}

class _PaneLoading extends StatelessWidget {
  const _PaneLoading();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: [SkeletonLine(), SizedBox(height: 14), SkeletonLine(), SizedBox(height: 14), SkeletonLine()]),
      );
}

class _Row extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final bool inactive;
  final VoidCallback? onTap;
  final List<(String, VoidCallback)> menu;

  const _Row({required this.title, required this.subtitle, required this.menu, this.selected = false, this.inactive = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.chromeTint : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: selected ? AppColors.chrome : Colors.transparent, width: 3),
              bottom: const BorderSide(color: AppColors.divider),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
                      if (inactive) ...[const SizedBox(width: 8), const StatusPill(label: 'Hidden')],
                    ]),
                    if (subtitle.isNotEmpty)
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                  ],
                ),
              ),
              PopupMenuButton<int>(
                tooltip: 'Actions for $title',
                onSelected: (i) => menu[i].$2(),
                itemBuilder: (_) => [
                  for (var i = 0; i < menu.length; i++)
                    PopupMenuItem(
                      value: i,
                      child: Text(menu[i].$1, style: menu[i].$1 == 'Delete' ? const TextStyle(color: AppColors.danger) : null),
                    ),
                ],
              ),
              if (onTap != null) const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dialogs
// ---------------------------------------------------------------------------

String? _slugValidator(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Enter a URL name';
  if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(t)) return 'Use lowercase letters, numbers and single hyphens';
  return null;
}

num? _num(String s) => s.trim().isEmpty ? null : num.tryParse(s.trim());

String? _optionalNumber(String? v, {bool integer = false}) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return null;
  final n = integer ? int.tryParse(t) : num.tryParse(t);
  if (n == null || n < 0) return 'Enter a valid number';
  if (integer && n < 1) return 'Must be at least 1';
  return null;
}

/// Shared dialog frame with save handling.
class _FormDialog extends StatelessWidget {
  final String title;
  final GlobalKey<FormState> formKey;
  final List<Widget> children;
  final bool saving;
  final String? error;
  final VoidCallback onSave;

  const _FormDialog({required this.title, required this.formKey, required this.children, required this.saving, required this.error, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(padding: const EdgeInsets.fromLTRB(24, 22, 24, 12), child: Text(title, style: AppText.heading(19))),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [if (error != null) InlineError(error!), ...children]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: saving ? null : () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: saving ? null : onSave,
                      child: saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                          : const Text('Save'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandDialog extends StatefulWidget {
  final CatalogService service;
  final CatalogBrand? brand;
  const _BrandDialog({required this.service, this.brand});

  @override
  State<_BrandDialog> createState() => _BrandDialogState();
}

class _BrandDialogState extends State<_BrandDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.brand?.name);
  late final _slug = TextEditingController(text: widget.brand?.slug);
  late final _country = TextEditingController(text: widget.brand?.country);
  late final _logo = TextEditingController(text: widget.brand?.logoUrl);
  late final _description = TextEditingController(text: widget.brand?.description);
  late bool _slugTouched = widget.brand != null;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _slug, _country, _logo, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _clean(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (widget.brand == null) {
        await widget.service.createBrand(
            name: _name.text.trim(), slug: _slug.text.trim(), country: _clean(_country), logoUrl: _clean(_logo), description: _clean(_description));
      } else {
        await widget.service.updateBrand(widget.brand!.id, {
          'name': _name.text.trim(),
          'slug': _slug.text.trim(),
          'country': _clean(_country),
          'logo_url': _clean(_logo),
          'description': _clean(_description),
        });
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialog(
      title: widget.brand == null ? 'Add a brand' : 'Edit ${widget.brand!.name}',
      formKey: _formKey,
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        AuthTextField(
          controller: _name,
          label: 'Brand name',
          required: true,
          maxLength: 100,
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v ?? '').trim().isEmpty ? 'Enter the brand name' : null,
          onChanged: (v) {
            if (!_slugTouched) _slug.text = Slugs.slugify(v);
          },
        ),
        AuthTextField(
          controller: _slug,
          label: 'URL name',
          required: true,
          helper: 'Lowercase, e.g. maruti-suzuki',
          validator: _slugValidator,
          onChanged: (_) => _slugTouched = true,
        ),
        AuthTextField(controller: _country, label: 'Country', maxLength: 100),
        AuthTextField(controller: _logo, label: 'Logo URL', keyboardType: TextInputType.url, maxLength: 500),
        AuthTextField(controller: _description, label: 'Description', maxLines: 3),
      ],
    );
  }
}

class _ModelDialog extends StatefulWidget {
  final CatalogService service;
  final CatalogBrand brand;
  final CatalogCarModel? model;
  const _ModelDialog({required this.service, required this.brand, this.model});

  @override
  State<_ModelDialog> createState() => _ModelDialogState();
}

class _ModelDialogState extends State<_ModelDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.model?.name);
  late final _slug = TextEditingController(text: widget.model?.slug);
  late final _seats = TextEditingController(text: widget.model?.seatingCapacity?.toString());
  late final _description = TextEditingController(text: widget.model?.description);
  late BodyType? _body = widget.model?.bodyType;
  late bool _slugTouched = widget.model != null;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _slug, _seats, _description]) {
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
    final seats = int.tryParse(_seats.text.trim());
    final description = _description.text.trim().isEmpty ? null : _description.text.trim();
    try {
      if (widget.model == null) {
        await widget.service.createModel(
            brandId: widget.brand.id, name: _name.text.trim(), slug: _slug.text.trim(), bodyType: _body, seatingCapacity: seats, description: description);
      } else {
        await widget.service.updateModel(widget.model!.id, {
          'name': _name.text.trim(),
          'slug': _slug.text.trim(),
          'body_type': _body?.apiValue,
          'seating_capacity': seats,
          'description': description,
        });
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialog(
      title: widget.model == null ? 'Add a ${widget.brand.name} model' : 'Edit ${widget.model!.name}',
      formKey: _formKey,
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        AuthTextField(
          controller: _name,
          label: 'Model name',
          required: true,
          maxLength: 100,
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v ?? '').trim().isEmpty ? 'Enter the model name' : null,
          onChanged: (v) {
            if (!_slugTouched) _slug.text = Slugs.slugify(v);
          },
        ),
        AuthTextField(controller: _slug, label: 'URL name', required: true, helper: 'Lowercase, e.g. swift', validator: _slugValidator, onChanged: (_) => _slugTouched = true),
        FieldPair(
          DropdownField<BodyType?>(
            label: 'Body type',
            value: _body,
            items: [
              const DropdownMenuItem(value: null, child: Text('Not set')),
              for (final b in BodyType.values) DropdownMenuItem(value: b, child: Text(b.label)),
            ],
            onChanged: (v) => setState(() => _body = v),
          ),
          AuthTextField(controller: _seats, label: 'Seats', keyboardType: TextInputType.number, validator: (v) => _optionalNumber(v, integer: true)),
        ),
        AuthTextField(controller: _description, label: 'Description', maxLines: 3),
      ],
    );
  }
}

class _VariantDialog extends StatefulWidget {
  final CatalogService service;
  final CatalogCarModel model;
  final CatalogVariant? variant;
  const _VariantDialog({required this.service, required this.model, this.variant});

  @override
  State<_VariantDialog> createState() => _VariantDialogState();
}

class _VariantDialogState extends State<_VariantDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.variant?.variantName);
  late final _engine = TextEditingController(text: widget.variant?.engineCc?.toString());
  late final _power = TextEditingController(text: widget.variant?.horsepower?.toString());
  late final _seats = TextEditingController(text: widget.variant?.seatingCapacity?.toString());
  late final _price = TextEditingController(text: widget.variant?.exShowroomPrice?.toString());
  late FuelType _fuel = widget.variant?.fuelType ?? FuelType.petrol;
  late TransmissionType _transmission = widget.variant?.transmission ?? TransmissionType.manual;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _engine, _power, _seats, _price]) {
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
    try {
      if (widget.variant == null) {
        await widget.service.createVariant(
          modelId: widget.model.id,
          name: _name.text.trim(),
          fuelType: _fuel,
          transmission: _transmission,
          engineCc: _num(_engine.text),
          horsepower: _num(_power.text),
          seatingCapacity: int.tryParse(_seats.text.trim()),
          exShowroomPrice: _num(_price.text),
        );
      } else {
        await widget.service.updateVariant(widget.variant!.id, {
          'variant_name': _name.text.trim(),
          'fuel_type': _fuel.apiValue,
          'transmission': _transmission.apiValue,
          'engine_cc': _num(_engine.text),
          'horsepower': _num(_power.text),
          'seating_capacity': int.tryParse(_seats.text.trim()),
          'ex_showroom_price': _num(_price.text),
        });
      }
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _FormDialog(
      title: widget.variant == null ? 'Add a ${widget.model.name} variant' : 'Edit ${widget.variant!.variantName}',
      formKey: _formKey,
      saving: _saving,
      error: _error,
      onSave: _save,
      children: [
        AuthTextField(
          controller: _name,
          label: 'Variant name',
          required: true,
          hint: 'e.g. VXi AMT',
          validator: (v) => (v ?? '').trim().isEmpty ? 'Enter the variant name' : null,
        ),
        FieldPair(
          DropdownField<FuelType>(
            label: 'Fuel',
            required: true,
            value: _fuel,
            items: [for (final f in FuelType.values) DropdownMenuItem(value: f, child: Text(f.label))],
            onChanged: (v) => setState(() => _fuel = v ?? _fuel),
          ),
          DropdownField<TransmissionType>(
            label: 'Transmission',
            required: true,
            value: _transmission,
            items: [for (final t in TransmissionType.values) DropdownMenuItem(value: t, child: Text(t.label))],
            onChanged: (v) => setState(() => _transmission = v ?? _transmission),
          ),
        ),
        FieldPair(
          AuthTextField(controller: _engine, label: 'Engine (cc)', keyboardType: TextInputType.number, validator: _optionalNumber),
          AuthTextField(controller: _power, label: 'Power (bhp)', keyboardType: TextInputType.number, validator: _optionalNumber),
        ),
        FieldPair(
          AuthTextField(controller: _seats, label: 'Seats', keyboardType: TextInputType.number, validator: (v) => _optionalNumber(v, integer: true)),
          AuthTextField(controller: _price, label: 'Ex-showroom price (Rs)', keyboardType: TextInputType.number, validator: _optionalNumber),
        ),
      ],
    );
  }
}
