import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_filters.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The Browse page's filter form. Edits a private draft and only reports it
/// through [onApply] when the user taps Apply, so results don't reload on
/// every keystroke. Brands and models come from the real catalog endpoints.
class ListingFilterPanel extends StatefulWidget {
  final ListingFilters initial;
  final List<CatalogBrand> brands;
  final ValueChanged<ListingFilters> onApply;

  const ListingFilterPanel({super.key, required this.initial, required this.brands, required this.onApply});

  @override
  State<ListingFilterPanel> createState() => _ListingFilterPanelState();
}

class _ListingFilterPanelState extends State<ListingFilterPanel> {
  final _catalog = CatalogService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _minPrice = TextEditingController();
  final TextEditingController _maxPrice = TextEditingController();
  final TextEditingController _minYear = TextEditingController();
  final TextEditingController _maxYear = TextEditingController();
  final TextEditingController _maxMileage = TextEditingController();
  final TextEditingController _city = TextEditingController();

  int? _brandId;
  int? _modelId;
  FuelType? _fuel;
  TransmissionType? _transmission;
  CarCondition? _condition;

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
    for (final c in [_minPrice, _maxPrice, _minYear, _maxYear, _maxMileage, _city]) {
      c.dispose();
    }
    super.dispose();
  }

  String _text(num? value) => value == null ? '' : value.toString();

  void _loadFrom(ListingFilters f) {
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
    _models = const [];
    final brandId = _brandId;
    if (brandId != null) {
      // Deferred: this runs from initState/didUpdateWidget, where setState is not allowed.
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
        _models = page.data;
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

  num? _num(TextEditingController c) => num.tryParse(c.text.trim().replaceAll(',', ''));
  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  void _apply() {
    if (!_formKey.currentState!.validate()) return;
    final city = _city.text.trim();
    widget.onApply(ListingFilters(
      search: widget.initial.search,
      sort: widget.initial.sort,
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

  void _reset() {
    setState(() => _loadFrom(const ListingFilters()));
    widget.onApply(widget.initial.clearedPanel());
  }

  String? _validateRange(TextEditingController low, TextEditingController high, {bool integer = false}) {
    final a = integer ? _int(low) : _num(low);
    final b = integer ? _int(high) : _num(high);
    if (low.text.trim().isNotEmpty && a == null) return 'Enter a valid number';
    if (high.text.trim().isNotEmpty && b == null) return 'Enter a valid number';
    if (a != null && b != null && a > b) return 'Min is above max';
    return null;
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 8),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
      );

  Widget _numberField(TextEditingController controller, String label, {String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
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
          ChoiceChip(
            label: Text(label(value)),
            selected: selected == value,
            onSelected: (isSelected) => setState(() => onChanged(isSelected ? value : null)),
            selectedColor: AppColors.secondary.withValues(alpha: 0.25),
            checkmarkColor: AppColors.primary,
            side: const BorderSide(color: AppColors.divider),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Brand'),
          DropdownButtonFormField<int?>(
            initialValue: _brandId,
            isExpanded: true,
            decoration: const InputDecoration(isDense: true),
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
            },
          ),
          if (_brandId != null) ...[
            _label('Model'),
            if (_modelsLoading)
              const LinearProgressIndicator(color: AppColors.secondary)
            else if (_modelsError != null)
              Text(_modelsError!, style: const TextStyle(color: AppColors.favorite, fontSize: 12.5))
            else
              DropdownButtonFormField<int?>(
                initialValue: _modelId,
                isExpanded: true,
                decoration: const InputDecoration(isDense: true),
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text('Any model')),
                  for (final m in _models) DropdownMenuItem<int?>(value: m.id, child: Text(m.name)),
                ],
                onChanged: (value) => setState(() => _modelId = value),
              ),
          ],
          _label('Price (₹)'),
          Row(
            children: [
              Expanded(child: _numberField(_minPrice, 'Min', validator: (_) => _validateRange(_minPrice, _maxPrice))),
              const SizedBox(width: 10),
              Expanded(child: _numberField(_maxPrice, 'Max')),
            ],
          ),
          _label('Fuel'),
          _chips<FuelType>(FuelType.values, _fuel, (v) => v.label, (v) => _fuel = v),
          _label('Transmission'),
          _chips<TransmissionType>(TransmissionType.values, _transmission, (v) => v.label, (v) => _transmission = v),
          _label('Condition'),
          _chips<CarCondition>(
            const [CarCondition.excellent, CarCondition.good, CarCondition.fair, CarCondition.poor],
            _condition,
            (v) => v.label,
            (v) => _condition = v,
          ),
          _label('Manufacturing year'),
          Row(
            children: [
              Expanded(
                child: _numberField(_minYear, 'From', validator: (_) => _validateRange(_minYear, _maxYear, integer: true)),
              ),
              const SizedBox(width: 10),
              Expanded(child: _numberField(_maxYear, 'To')),
            ],
          ),
          _label('Maximum kilometres driven'),
          _numberField(_maxMileage, 'e.g. 60000'),
          _label('City'),
          TextFormField(
            controller: _city,
            decoration: const InputDecoration(labelText: 'e.g. Ahmedabad', isDense: true),
          ),
          const SizedBox(height: 22),
          FilledButton(onPressed: _apply, child: const Text('Apply filters')),
          const SizedBox(height: 8),
          TextButton(onPressed: _reset, child: const Text('Reset all')),
        ],
      ),
    );
  }
}
