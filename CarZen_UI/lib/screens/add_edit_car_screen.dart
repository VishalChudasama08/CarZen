import 'package:flutter/material.dart';
import '../models/car_models.dart';
import '../models/catalog_models.dart';
import '../models/enums.dart';
import '../services/api_exception.dart';
import '../services/car_service.dart';
import '../services/catalog_service.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/auth_error_banner.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/primary_button.dart';

/// Create (`POST /v1/cars`) or edit (`PATCH /v1/cars/{id}`) a car.
///
/// Only the fields the backend's `CarCreate`/`CarUpdate` schema requires,
/// plus a handful of the most useful optional ones, are collected here —
/// see `CarService._carPayload` for the exact set sent to the API.
class AddEditCarScreen extends StatefulWidget {
  /// Pass an existing [CarRecordDetail] to edit it; leave null to create.
  final CarRecordDetail? existingCar;

  const AddEditCarScreen({super.key, this.existingCar});

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _catalogService = CatalogService();
  final _carService = CarService();

  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _colorController = TextEditingController();
  final _registrationController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<CatalogBrand> _brands = [];
  List<CatalogCarModel> _models = [];
  List<CatalogVariant> _variants = [];

  CatalogBrand? _selectedBrand;
  CatalogCarModel? _selectedModel;
  CatalogVariant? _selectedVariant;
  FuelType _fuelType = FuelType.petrol;
  TransmissionType _transmission = TransmissionType.manual;
  CarCondition _condition = CarCondition.good;

  bool _loadingBrands = true;
  bool _loadingModels = false;
  bool _loadingVariants = false;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.existingCar != null;

  @override
  void initState() {
    super.initState();
    _prefillFromExisting();
    _loadBrands();
  }

  void _prefillFromExisting() {
    final car = widget.existingCar;
    if (car == null) return;
    _yearController.text = car.manufacturingYear.toString();
    _mileageController.text = car.mileageKm.toString();
    _cityController.text = car.city;
    _stateController.text = car.state;
    _colorController.text = car.color ?? '';
    _registrationController.text = car.registrationNumber ?? '';
    _priceController.text = car.expectedMarketPrice?.toString() ?? '';
    _descriptionController.text = car.description ?? '';
    _fuelType = car.fuelType;
    _transmission = car.transmission;
    _condition = car.condition;
  }

  Future<void> _loadBrands() async {
    setState(() => _loadingBrands = true);
    try {
      final result = await _catalogService.listBrands(limit: 100);
      if (!mounted) return;
      setState(() {
        _brands = result.data;
        _loadingBrands = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBrands = false;
        _errorMessage = 'Could not load car brands: ${e.message}';
      });
    }
  }

  Future<void> _onBrandSelected(CatalogBrand? brand) async {
    setState(() {
      _selectedBrand = brand;
      _selectedModel = null;
      _selectedVariant = null;
      _models = [];
      _variants = [];
      _loadingModels = brand != null;
    });
    if (brand == null) return;
    try {
      final result = await _catalogService.listModelsForBrand(brand.id, limit: 100);
      if (!mounted) return;
      setState(() {
        _models = result.data;
        _loadingModels = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingModels = false;
        _errorMessage = 'Could not load models: ${e.message}';
      });
    }
  }

  Future<void> _onModelSelected(CatalogCarModel? model) async {
    setState(() {
      _selectedModel = model;
      _selectedVariant = null;
      _variants = [];
      _loadingVariants = model != null;
    });
    if (model == null) return;
    try {
      final result = await _catalogService.listVariantsForModel(model.id, limit: 100);
      if (!mounted) return;
      setState(() {
        _variants = result.data;
        _loadingVariants = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingVariants = false;
        _errorMessage = 'Could not load variants: ${e.message}';
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isEditing && _selectedVariant == null) {
      setState(() => _errorMessage = 'Please select brand, model and variant.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      if (_isEditing) {
        await _carService.updateCar(widget.existingCar!.id, {
          'manufacturing_year': int.parse(_yearController.text.trim()),
          'fuel_type': _fuelType.apiValue,
          'transmission': _transmission.apiValue,
          'mileage_km': num.parse(_mileageController.text.trim()),
          'condition': _condition.apiValue,
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          if (_colorController.text.trim().isNotEmpty) 'color': _colorController.text.trim(),
          if (_registrationController.text.trim().isNotEmpty)
            'registration_number': _registrationController.text.trim(),
          if (_priceController.text.trim().isNotEmpty)
            'expected_market_price': num.parse(_priceController.text.trim()),
          if (_descriptionController.text.trim().isNotEmpty) 'description': _descriptionController.text.trim(),
        });
      } else {
        await _carService.createCar(
          variantId: _selectedVariant!.id,
          manufacturingYear: int.parse(_yearController.text.trim()),
          fuelType: _fuelType,
          transmission: _transmission,
          mileageKm: num.parse(_mileageController.text.trim()),
          condition: _condition,
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          color: _colorController.text.trim(),
          registrationNumber: _registrationController.text.trim(),
          expectedMarketPrice:
              _priceController.text.trim().isEmpty ? null : num.parse(_priceController.text.trim()),
          description: _descriptionController.text.trim(),
        );
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _yearController.dispose();
    _mileageController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _colorController.dispose();
    _registrationController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Car' : 'Add Car'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_errorMessage != null) AuthErrorBanner(message: _errorMessage!),
                if (!_isEditing) ...[
                  Text('Brand, Model & Variant', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  _loadingBrands
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: LinearProgressIndicator(color: AppColors.secondary),
                        )
                      : _CatalogDropdown<CatalogBrand>(
                          label: 'Brand',
                          value: _selectedBrand,
                          items: _brands,
                          itemLabel: (b) => b.name,
                          onChanged: _onBrandSelected,
                        ),
                  const SizedBox(height: 12),
                  _loadingModels
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: LinearProgressIndicator(color: AppColors.secondary),
                        )
                      : _CatalogDropdown<CatalogCarModel>(
                          label: 'Model',
                          value: _selectedModel,
                          items: _models,
                          itemLabel: (m) => m.name,
                          onChanged: _selectedBrand == null ? null : _onModelSelected,
                        ),
                  const SizedBox(height: 12),
                  _loadingVariants
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: LinearProgressIndicator(color: AppColors.secondary),
                        )
                      : _CatalogDropdown<CatalogVariant>(
                          label: 'Variant',
                          value: _selectedVariant,
                          items: _variants,
                          itemLabel: (v) => v.variantName,
                          onChanged: _selectedModel == null
                              ? null
                              : (v) => setState(() {
                                    _selectedVariant = v;
                                    if (v != null) {
                                      _fuelType = v.fuelType;
                                      _transmission = v.transmission;
                                    }
                                  }),
                        ),
                  const SizedBox(height: 20),
                ],
                Text('Car Details', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                AuthTextField(
                  controller: _yearController,
                  label: 'Manufacturing Year',
                  hint: 'e.g. 2021',
                  icon: Icons.calendar_today_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final required = Validators.required(v, message: 'Manufacturing year is required');
                    if (required != null) return required;
                    final year = int.tryParse(v!.trim());
                    if (year == null || year < 1980 || year > DateTime.now().year + 1) return 'Enter a valid year';
                    return null;
                  },
                ),
                AuthTextField(
                  controller: _mileageController,
                  label: 'Mileage (km)',
                  hint: 'e.g. 42000',
                  icon: Icons.speed_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final required = Validators.required(v, message: 'Mileage is required');
                    if (required != null) return required;
                    if (num.tryParse(v!.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                _EnumDropdown<FuelType>(
                  label: 'Fuel Type',
                  value: _fuelType,
                  values: FuelType.values,
                  labelOf: (f) => f.label,
                  onChanged: (v) => setState(() => _fuelType = v!),
                ),
                const SizedBox(height: 12),
                _EnumDropdown<TransmissionType>(
                  label: 'Transmission',
                  value: _transmission,
                  values: TransmissionType.values,
                  labelOf: (t) => t.label,
                  onChanged: (v) => setState(() => _transmission = v!),
                ),
                const SizedBox(height: 12),
                _EnumDropdown<CarCondition>(
                  label: 'Condition',
                  value: _condition,
                  values: const [
                    CarCondition.excellent,
                    CarCondition.good,
                    CarCondition.fair,
                    CarCondition.poor,
                    CarCondition.newCar,
                    CarCondition.old,
                  ],
                  labelOf: (c) => c.label,
                  onChanged: (v) => setState(() => _condition = v!),
                ),
                const SizedBox(height: 12),
                AuthTextField(
                  controller: _cityController,
                  label: 'City',
                  hint: 'Ahmedabad',
                  icon: Icons.location_city_outlined,
                  validator: (v) => Validators.required(v, message: 'City is required'),
                ),
                AuthTextField(
                  controller: _stateController,
                  label: 'State',
                  hint: 'Gujarat',
                  icon: Icons.map_outlined,
                  validator: (v) => Validators.required(v, message: 'State is required'),
                ),
                AuthTextField(
                  controller: _colorController,
                  label: 'Color (optional)',
                  hint: 'White',
                  icon: Icons.color_lens_outlined,
                ),
                AuthTextField(
                  controller: _registrationController,
                  label: 'Registration Number (optional)',
                  hint: 'GJ01AB1234',
                  icon: Icons.badge_outlined,
                ),
                AuthTextField(
                  controller: _priceController,
                  label: 'Expected Market Price (optional)',
                  hint: 'e.g. 650000',
                  icon: Icons.sell_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (num.tryParse(v.trim()) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                AuthTextField(
                  controller: _descriptionController,
                  label: 'Description (optional)',
                  hint: 'Anything buyers should know',
                  icon: Icons.notes_outlined,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  label: _isEditing ? 'Save Changes' : 'Add Car',
                  onPressed: _handleSave,
                  isLoading: _isSaving,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CatalogDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?>? onChanged;

  const _CatalogDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(itemLabel(e), overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
          ),
          hint: Text(items.isEmpty ? 'Select $label first' : 'Select $label'),
        ),
      ],
    );
  }
}

class _EnumDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> values;
  final String Function(T) labelOf;
  final ValueChanged<T?> onChanged;

  const _EnumDropdown({
    required this.label,
    required this.value,
    required this.values,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          items: values.map((e) => DropdownMenuItem(value: e, child: Text(labelOf(e)))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.divider)),
          ),
        ),
      ],
    );
  }
}
