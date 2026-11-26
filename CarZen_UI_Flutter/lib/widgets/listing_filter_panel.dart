import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_filters.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Budget presets in rupees (min, max).
const listingBudgets = <(String, num?, num?)>[
  ('Under ₹5 lakh', null, 500000),
  ('₹5-10 lakh', 500000, 1000000),
  ('₹10-20 lakh', 1000000, 2000000),
  ('Above ₹20 lakh', 2000000, null),
];

const _kmPresets = <num>[25000, 50000, 75000, 100000];

/// The Browse filter form. Brands and models come from the catalogue API.
///
/// * [instant] (desktop rail): choices apply as soon as they are made; typed
///   values apply on Enter or with the Apply button.
/// * otherwise (bottom sheet): edits a draft and applies it with
///   "Show results".
class ListingFilterPanel extends StatefulWidget {
  final ListingFilters initial;
  final List<CatalogBrand> brands;
  final ValueChanged<ListingFilters> onApply;
  final bool instant;

  const ListingFilterPanel({super.key, required this.initial, required this.brands, required this.onApply, this.instant = false});

  @override
  State<ListingFilterPanel> createState() => _ListingFilterPanelState();
}

class _ListingFilterPanelState extends State<ListingFilterPanel> {
  final _catalog = CatalogService();
  final _formKey = GlobalKey<FormState>();

  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  final _minYear = TextEditingController();
  final _maxYear = TextEditingController();
  final _city = TextEditingController();

  int? _brandId;
  int? _modelId;
  FuelType? _fuel;
  TransmissionType? _transmission;
  CarCondition? _condition;
  num? _maxKm;

  List<CatalogCarModel> _models = const [];
  bool _modelsLoading = false;
  String? _modelsError;

  @override
  void initState() {
    super.initState();
    _loadFrom(widget.initial);
  }

  @override
  void didUpdateWidget(covariant ListingFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.initial, widget.initial)) _loadFrom(widget.initial);
  }

  @override
  void dispose() {
    for (final c in [_minPrice, _maxPrice, _minYear, _maxYear, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  String _lakhText(num? rupees) {
    if (rupees == null) return '';
    final l = rupees / 100000;
    return l == l.roundToDouble() ? l.round().toString() : l.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '');
  }

  void _loadFrom(ListingFilters f) {
    final brandChanged = f.brandId != _brandId;
    _brandId = f.brandId;
    _modelId = f.modelId;
    _fuel = f.fuelType;
    _transmission = f.transmission;
    _condition = f.condition;
    _maxKm = f.maxMileage;
    _minPrice.text = _lakhText(f.minPrice);
    _maxPrice.text = _lakhText(f.maxPrice);
    _minYear.text = f.minYear?.toString() ?? '';
    _maxYear.text = f.maxYear?.toString() ?? '';
    _city.text = f.city ?? '';
    final brandId = _brandId;
    if (brandChanged) _models = const [];
    if (brandId != null && (brandChanged || _models.isEmpty)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _brandId == brandId) _loadModels(brandId);
      });
    }
  }

  Future<void> _loadModels(int brandId) async {
    setState(() {
      _modelsLoading = true;
      _modelsError = null;
    });
    try {
      final page = await _catalog.listModelsForBrand(brandId);
      if (!mounted || _brandId != brandId) return;
      setState(() {
        _models = page.data.where((m) => m.isActive).toList();
        _modelsLoading = false;
        if (_modelId != null && !_models.any((m) => m.id == _modelId)) _modelId = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _modelsLoading = false;
        _modelsError = e.message;
      });
    }
  }

  num? _lakh(TextEditingController c) {
    final v = num.tryParse(c.text.trim().replaceAll(',', ''));
    return v == null ? null : (v * 100000).round();
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  ListingFilters _current() {
    final city = _city.text.trim();
    return ListingFilters(
      search: widget.initial.search,
      sort: widget.initial.sort,
      brandId: _brandId,
      modelId: _modelId,
      fuelType: _fuel,
      transmission: _transmission,
      condition: _condition,
      minPrice: _lakh(_minPrice),
      maxPrice: _lakh(_maxPrice),
      minYear: _int(_minYear),
      maxYear: _int(_maxYear),
      maxMileage: _maxKm,
      city: city.isEmpty ? null : city,
    );
  }

  void _apply() {
    if (!_formKey.currentState!.validate()) return;
    widget.onApply(_current());
  }

  /// In instant mode, apply right after a choice.
  void _changed() {
    if (widget.instant) _apply();
  }

  void _reset() {
    setState(() => _loadFrom(ListingFilters(search: widget.initial.search, sort: widget.initial.sort)));
    widget.onApply(widget.initial.clearedPanel());
  }

  String? _validateRange(TextEditingController low, TextEditingController high, {bool integer = false}) {
    num? parse(TextEditingController c) => integer ? _int(c) : num.tryParse(c.text.trim());
    final a = parse(low);
    final b = parse(high);
    if (low.text.trim().isNotEmpty && a == null) return 'Enter a number';
    if (high.text.trim().isNotEmpty && b == null) return 'Enter a number';
    if (a != null && b != null && a > b) return 'Minimum is above maximum';
    if (integer) {
      final now = DateTime.now().year + 1;
      for (final v in [a, b]) {
        if (v != null && (v < 1950 || v > now)) return 'Use a year between 1950 and $now';
      }
    }
    return null;
  }

  Widget _section(String title, Widget child, {bool first = false}) => Padding(
        padding: EdgeInsets.only(top: first ? 0 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(header: true, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink))),
            const SizedBox(height: 10),
            child,
          ],
        ),
      );

  Widget _numberField(TextEditingController controller, String label, {String? Function(String?)? validator, bool decimal = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: decimal),
      inputFormatters: [FilteringTextInputFormatter.allow(decimal ? RegExp(r'[0-9.]') : RegExp(r'[0-9]'))],
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _changed(),
      decoration: InputDecoration(labelText: label, isDense: true),
      validator: validator,
    );
  }

  Widget _chips<T>(List<T> values, T? selected, String Function(T) label, ValueChanged<T?> onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          FilterChip(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            label: Text(label(value)),
            selected: selected == value,
            showCheckmark: false,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: selected == value ? Colors.white : AppColors.textPrimary,
            ),
            onSelected: (isSelected) {
              setState(() => onChanged(isSelected ? value : null));
              _changed();
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetIndex = listingBudgets.indexWhere((b) => _lakh(_minPrice) == b.$2 && _lakh(_maxPrice) == b.$3);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _section(
            'Brand and model',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<int?>(
                  style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontFamily: AppText.body),
                  key: ValueKey('brand-$_brandId'),
                  initialValue: _brandId,
                  isExpanded: true,
                  decoration: const InputDecoration(isDense: true, labelText: 'Brand'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('Any brand')),
                    for (final b in widget.brands) DropdownMenuItem<int?>(value: b.id, child: Text(b.name)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _brandId = value;
                      _modelId = null;
                      _models = const [];
                    });
                    if (value != null) _loadModels(value);
                    _changed();
                  },
                ),
                if (_brandId != null) ...[
                  const SizedBox(height: 10),
                  if (_modelsLoading)
                    const LinearProgressIndicator()
                  else if (_modelsError != null)
                    Text(_modelsError!, style: const TextStyle(color: AppColors.danger, fontSize: 12.5))
                  else
                    DropdownButtonFormField<int?>(
                      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontFamily: AppText.body),
                      key: ValueKey('model-$_brandId-$_modelId'),
                      initialValue: _modelId,
                      isExpanded: true,
                      decoration: const InputDecoration(isDense: true, labelText: 'Model'),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('Any model')),
                        for (final m in _models) DropdownMenuItem<int?>(value: m.id, child: Text(m.name)),
                      ],
                      onChanged: (value) {
                        setState(() => _modelId = value);
                        _changed();
                      },
                    ),
                ],
              ],
            ),
            first: true,
          ),
          _section(
            'Budget',
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (var i = 0; i < listingBudgets.length; i++)
                      FilterChip(
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(listingBudgets[i].$1),
                        selected: budgetIndex == i,
                        showCheckmark: false,
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: budgetIndex == i ? Colors.white : AppColors.textPrimary,
                        ),
                        onSelected: (sel) {
                          setState(() {
                            _minPrice.text = sel ? _lakhText(listingBudgets[i].$2) : '';
                            _maxPrice.text = sel ? _lakhText(listingBudgets[i].$3) : '';
                          });
                          _changed();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _numberField(_minPrice, 'Min (lakh)', decimal: true, validator: (_) => _validateRange(_minPrice, _maxPrice)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: _numberField(_maxPrice, 'Max (lakh)', decimal: true)),
                  ],
                ),
              ],
            ),
          ),
          _section('Fuel', _chips<FuelType>(FuelType.values, _fuel, (v) => v.label, (v) => _fuel = v)),
          _section(
            'Gearbox',
            _chips<TransmissionType>(TransmissionType.values, _transmission, (v) => v.label, (v) => _transmission = v),
          ),
          _section(
            'Kilometres driven',
            _chips<num>(_kmPresets, _maxKm, (v) => 'Up to ${formatKm(v)}', (v) => _maxKm = v),
          ),
          _section(
            'Condition',
            _chips<CarCondition>(
              const [CarCondition.excellent, CarCondition.good, CarCondition.fair, CarCondition.poor, CarCondition.newCar],
              _condition,
              (v) => v.label,
              (v) => _condition = v,
            ),
          ),
          _section(
            'Year',
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _numberField(_minYear, 'From', validator: (_) => _validateRange(_minYear, _maxYear, integer: true))),
                const SizedBox(width: 10),
                Expanded(child: _numberField(_maxYear, 'To')),
              ],
            ),
          ),
          _section(
            'City',
            TextFormField(
              controller: _city,
              textInputAction: TextInputAction.done,
              textCapitalization: TextCapitalization.words,
              onFieldSubmitted: (_) => _changed(),
              decoration: const InputDecoration(hintText: 'e.g. Ahmedabad', isDense: true),
            ),
          ),
          const SizedBox(height: 24),
          if (widget.instant)
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: _apply, child: const Text('Apply'))),
                const SizedBox(width: 10),
                TextButton(onPressed: _reset, child: const Text('Clear all')),
              ],
            )
          else
            Row(
              children: [
                TextButton(onPressed: _reset, child: const Text('Clear all')),
                const SizedBox(width: 10),
                Expanded(child: FilledButton(onPressed: _apply, child: const Text('Show results'))),
              ],
            ),
        ],
      ),
    );
  }
}
