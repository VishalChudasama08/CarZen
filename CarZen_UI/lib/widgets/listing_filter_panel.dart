import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_filters.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Filter form for the Browse page. Edits a *draft*; nothing is requested
/// until the user taps Apply, so typing a price doesn't fire a request per key.
class ListingFilterPanel extends StatefulWidget {
  final ListingFilters filters;
  final List<CatalogBrand> brands;
  final ValueChanged<ListingFilters> onApply;

  const ListingFilterPanel({super.key, required this.filters, required this.brands, required this.onApply});

  @override
  State<ListingFilterPanel> createState() => _ListingFilterPanelState();
}

class _ListingFilterPanelState extends State<ListingFilterPanel> {
  final _catalogService = CatalogService();

  final _minPrice = TextEditingController();
  final _maxPrice = TextEditingController();
  final _minYear = TextEditingController();
  final _maxYear = TextEditingController();
  final _maxMileage = TextEditingController();
  final _city = TextEditingController();

  int? _brandId;
  int? _modelId;
  FuelType? _fuel;
  TransmissionType? _transmission;
  CarCondition? _condition;

  List<CatalogCarModel> _models = const [];
  bool _modelsLoading = false;

  @override
  void initState() {
    super.initState();
    _syncFrom(widget.filters);
  }

  @override
  void didUpdateWidget(covariant ListingFilterPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.filters, widget.filters)) _syncFrom(widget.filters);
  }

  @override
  void dispose() {
    for (final c in [_minPrice, _maxPrice, _minYear, _maxYear, _maxMileage, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  String _text(num? value) => value == null ? '' : '${value is double && value == value.roundToDouble() ? value.round() : value}';

  void _syncFrom(ListingFilters f) {
    _brandId = f.brandId;
    _modelId = f.modelId;
    _fuel = f.fuelType;
    _transmission = f.transmission;
    _condition = f.condition;
    _minPrice.text = _text(f.minPrice);
    _maxPrice.text = _text(f.maxPrice);
    _minYear.text = _text(f.minYear);
    _maxYear.text = _text(f.maxYear);
    _maxMileage.text = _text(f.maxMileage);
    _city.text = f.city ?? '';
    _loadModels(f.brandId);
  }

  Future<void> _loadModels(int? brandId) async {
    if (brandId == null) {
      setState(() => _models = const []);
      return;
    }
    setState(() => _modelsLoading = true);
    try {
      final page = await _catalogService.listModelsForBrand(brandId);
      if (!mounted || _brandId != brandId) return;
      setState(() {
        _models = page.data;
        _modelsLoading = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() {
        _models = const [];
        _modelsLoading = false;
      });
    }
  }

  num? _num(TextEditingController c) => num.tryParse(c.text.trim());
  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  void _apply() {
    final city = _city.text.trim();
    widget.onApply(widget.filters.copyWith(
      brandId: _brandId,
      modelId: _modelId,
      fuelType: _fuel,
      transmission: _transmission,
      condition: _condition,
      minPrice: _num(_minPrice),
      maxPrice: _num(_maxPrice),
      minYear: _int(_minYear),
      maxYear: _int(_maxYear),
      maxMileage: _num(_maxMileage),
      city: city.isEmpty ? null : city,
    ));
  }

  void _reset() => widget.onApply(widget.filters.clearedPanelFilters());

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
      );

  Widget _numberField(TextEditingController controller, String label, {String? prefix}) => Expanded(
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(labelText: label, prefixText: prefix, isDense: true),
        ),
      );

  Widget _chips<T>({
    required List<T> values,
    required T? selected,
    required String Function(T) label,
    required ValueChanged<T?> onChanged,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          FilterChip(
            label: Text(label(value)),
            selected: selected == value,
            onSelected: (isSelected) => onChanged(isSelected ? value : null),
            selectedColor: AppColors.secondary.withValues(alpha: 0.25),
            checkmarkColor: AppColors.primary,
            side: const BorderSide(color: AppColors.divider),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Text('Filters', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18))),
            TextButton(onPressed: _reset, child: const Text('Reset')),
          ],
        ),
        _heading('Brand'),
        DropdownButtonFormField<int?>(
          key: ValueKey('brand-$_brandId-${widget.brands.length}'),
          value: widget.brands.any((b) => b.id == _brandId) ? _brandId : null,
          isExpanded: true,
          decoration: const InputDecoration(isDense: true),
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('Any brand')),
            for (final brand in widget.brands) DropdownMenuItem<int?>(value: brand.id, child: Text(brand.name)),
          ],
          onChanged: (value) {
            setState(() {
              _brandId = value;
              _modelId = null;
            });
            _loadModels(value);
          },
        ),
        if (_brandId != null) ...[
          _heading('Model'),
          DropdownButtonFormField<int?>(
            key: ValueKey('model-$_brandId-$_modelId-${_models.length}'),
            value: _models.any((m) => m.id == _modelId) ? _modelId : null,
            isExpanded: true,
            decoration: InputDecoration(isDense: true, hintText: _modelsLoading ? 'Loading models...' : null),
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('Any model')),
              for (final model in _models) DropdownMenuItem<int?>(value: model.id, child: Text(model.name)),
            ],
            onChanged: (value) => setState(() => _modelId = value),
          ),
        ],
        _heading('Fuel type'),
        _chips<FuelType>(
          values: FuelType.values,
          selected: _fuel,
          label: (v) => v.label,
          onChanged: (v) => setState(() => _fuel = v),
        ),
        _heading('Transmission'),
        _chips<TransmissionType>(
          values: TransmissionType.values,
          selected: _transmission,
          label: (v) => v.label,
          onChanged: (v) => setState(() => _transmission = v),
        ),
        _heading('Condition'),
        _chips<CarCondition>(
          values: const [CarCondition.excellent, CarCondition.good, CarCondition.fair, CarCondition.poor],
          selected: _condition,
          label: (v) => v.label,
          onChanged: (v) => setState(() => _condition = v),
        ),
        _heading('Price (INR)'),
        Row(children: [_numberField(_minPrice, 'Min'), const SizedBox(width: 10), _numberField(_maxPrice, 'Max')]),
        _heading('Manufacturing year'),
        Row(children: [_numberField(_minYear, 'From'), const SizedBox(width: 10), _numberField(_maxYear, 'To')]),
        _heading('Maximum kilometres driven'),
        Row(children: [_numberField(_maxMileage, 'e.g. 60000')]),
        _heading('City'),
        TextField(controller: _city, decoration: const InputDecoration(isDense: true, hintText: 'e.g. Ahmedabad')),
        const SizedBox(height: 22),
        FilledButton(onPressed: _apply, child: const Text('Apply filters')),
      ],
    );
  }
}
