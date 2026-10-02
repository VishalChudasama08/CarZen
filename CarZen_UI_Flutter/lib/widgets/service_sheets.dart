import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/services/address_service.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/services/service_request_api.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Shared chrome for the "add something" bottom sheets.
class _SheetFrame extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _SheetFrame({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92, maxWidth: 640),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 18),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            maxLines: maxLines,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet that adds a car for service use (`POST /v1/service/my-cars`).
/// Pops with the created [CarRecord]. It never touches the marketplace
/// "sell" flow: the car is service-only until its owner decides otherwise.
class AddServiceCarSheet extends StatefulWidget {
  const AddServiceCarSheet({super.key});

  static Future<CarRecord?> show(BuildContext context) => showModalBottomSheet<CarRecord>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AddServiceCarSheet(),
      );

  @override
  State<AddServiceCarSheet> createState() => _AddServiceCarSheetState();
}

class _AddServiceCarSheetState extends State<AddServiceCarSheet> {
  final _formKey = GlobalKey<FormState>();
  final _catalog = CatalogService();
  final _api = ServiceRequestApi();

  final _year = TextEditingController();
  final _mileage = TextEditingController();
  final _registration = TextEditingController();
  final _color = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();

  List<CatalogBrand> _brands = [];
  List<CatalogCarModel> _models = [];
  List<CatalogVariant> _variants = [];
  CatalogBrand? _brand;
  CatalogCarModel? _model;
  CatalogVariant? _variant;
  FuelType _fuel = FuelType.petrol;
  TransmissionType _transmission = TransmissionType.manual;

  bool _loadingBrands = true;
  bool _loadingModels = false;
  bool _loadingVariants = false;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBrands();
  }

  @override
  void dispose() {
    for (final c in [_year, _mileage, _registration, _color, _city, _state]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadBrands() async {
    try {
      final result = await _catalog.listBrands(limit: 100);
      if (!mounted) return;
      setState(() {
        _brands = result.data;
        _loadingBrands = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBrands = false;
        _error = 'Could not load car brands: ${e.message}';
      });
    }
  }

  Future<void> _pickBrand(CatalogBrand? brand) async {
    setState(() {
      _brand = brand;
      _model = null;
      _variant = null;
      _models = [];
      _variants = [];
      _loadingModels = brand != null;
    });
    if (brand == null) return;
    try {
      final result = await _catalog.listModelsForBrand(brand.id, limit: 100);
      if (!mounted) return;
      setState(() {
        _models = result.data;
        _loadingModels = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingModels = false;
        _error = 'Could not load models: ${e.message}';
      });
    }
  }

  Future<void> _pickModel(CatalogCarModel? model) async {
    setState(() {
      _model = model;
      _variant = null;
      _variants = [];
      _loadingVariants = model != null;
    });
    if (model == null) return;
    try {
      final result = await _catalog.listVariantsForModel(model.id, limit: 100);
      if (!mounted) return;
      setState(() {
        _variants = result.data;
        _loadingVariants = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingVariants = false;
        _error = 'Could not load variants: ${e.message}';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final variant = _variant;
    if (variant == null) {
      setState(() => _error = 'Please choose the brand, model and variant of your car.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final car = await _api.addServiceCar(
        variantId: variant.id,
        registrationNumber: _registration.text.trim(),
        manufacturingYear: int.parse(_year.text.trim()),
        fuelType: _fuel,
        transmission: _transmission,
        mileageKm: num.parse(_mileage.text.trim()),
        color: _color.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(car);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _dropdown<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) text,
    required ValueChanged<T?>? onChanged,
    bool loading = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          if (loading)
            const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: LinearProgressIndicator())
          else
            DropdownButtonFormField<T>(
              value: value,
              isExpanded: true,
              items: [for (final e in items) DropdownMenuItem<T>(value: e, child: Text(text(e), overflow: TextOverflow.ellipsis))],
              onChanged: onChanged,
              hint: Text(onChanged == null ? 'Choose the previous field first' : 'Select'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Add your car',
      subtitle: 'Used only to book services — it will not be listed for sale.',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) InlineError(_error!),
            _dropdown<CatalogBrand>(
              label: 'Brand *',
              value: _brand,
              items: _brands,
              text: (b) => b.name,
              onChanged: _pickBrand,
              loading: _loadingBrands,
            ),
            _dropdown<CatalogCarModel>(
              label: 'Model *',
              value: _model,
              items: _models,
              text: (m) => m.name,
              onChanged: _brand == null ? null : _pickModel,
              loading: _loadingModels,
            ),
            _dropdown<CatalogVariant>(
              label: 'Variant *',
              value: _variant,
              items: _variants,
              text: (v) => v.variantName,
              onChanged: _model == null
                  ? null
                  : (v) => setState(() {
                        _variant = v;
                        if (v != null) {
                          _fuel = v.fuelType;
                          _transmission = v.transmission;
                        }
                      }),
              loading: _loadingVariants,
            ),
            _LabeledField(
              label: 'Registration number',
              controller: _registration,
              hint: 'e.g. GJ01AB1234',
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'Year *',
                    controller: _year,
                    hint: '2021',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final required = Validators.required(v, message: 'Required');
                      if (required != null) return required;
                      final year = int.tryParse(v!.trim());
                      if (year == null || year < 1886 || year > 2030) return 'Enter a valid year';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'Odometer (km) *',
                    controller: _mileage,
                    hint: '42000',
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final required = Validators.required(v, message: 'Required');
                      if (required != null) return required;
                      final value = num.tryParse(v!.trim());
                      if (value == null || value < 0) return 'Enter a valid number';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Fuel *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<FuelType>(
                          value: _fuel,
                          isExpanded: true,
                          items: [for (final f in FuelType.values) DropdownMenuItem(value: f, child: Text(f.label))],
                          onChanged: (v) => setState(() => _fuel = v ?? _fuel),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transmission *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<TransmissionType>(
                          value: _transmission,
                          isExpanded: true,
                          items: [
                            for (final t in TransmissionType.values) DropdownMenuItem(value: t, child: Text(t.label))
                          ],
                          onChanged: (v) => setState(() => _transmission = v ?? _transmission),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _LabeledField(label: 'Colour', controller: _color, hint: 'White'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'City *',
                    controller: _city,
                    hint: 'Ahmedabad',
                    validator: (v) => Validators.required(v, message: 'Required'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'State *',
                    controller: _state,
                    hint: 'Gujarat',
                    validator: (v) => Validators.required(v, message: 'Required'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Save car'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that saves an address (`POST /v1/address-add`). Pops with the new [AddressRecord].
class AddAddressSheet extends StatefulWidget {
  const AddAddressSheet({super.key});

  static Future<AddressRecord?> show(BuildContext context) => showModalBottomSheet<AddressRecord>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AddAddressSheet(),
      );

  @override
  State<AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<AddAddressSheet> {
  final _formKey = GlobalKey<FormState>();
  final _service = AddressService();
  final _line1 = TextEditingController();
  final _line2 = TextEditingController();
  final _landmark = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _postal = TextEditingController();
  bool _default = false;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_line1, _line2, _landmark, _city, _state, _postal]) {
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
      final address = await _service.create(
        addressLine1: _line1.text.trim(),
        addressLine2: _line2.text.trim(),
        landmark: _landmark.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        postalCode: _postal.text.trim(),
        isDefault: _default,
      );
      if (!mounted) return;
      Navigator.of(context).pop(address);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetFrame(
      title: 'Add an address',
      subtitle: 'Where should the CarZen team pick up or service your car?',
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) InlineError(_error!),
            _LabeledField(
              label: 'Address line 1 *',
              controller: _line1,
              hint: 'House / building, street',
              validator: (v) => Validators.required(v, message: 'Required'),
            ),
            _LabeledField(label: 'Address line 2', controller: _line2, hint: 'Area, locality'),
            _LabeledField(label: 'Landmark', controller: _landmark, hint: 'Near…'),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _LabeledField(
                    label: 'City *',
                    controller: _city,
                    validator: (v) => Validators.required(v, message: 'Required'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _LabeledField(
                    label: 'State *',
                    controller: _state,
                    validator: (v) => Validators.required(v, message: 'Required'),
                  ),
                ),
              ],
            ),
            _LabeledField(
              label: 'Postal code *',
              controller: _postal,
              keyboardType: TextInputType.number,
              validator: (v) {
                final required = Validators.required(v, message: 'Required');
                if (required != null) return required;
                if (v!.trim().length < 4 || v.trim().length > 20) return 'Enter a valid postal code';
                return null;
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _default,
              onChanged: (v) => setState(() => _default = v),
              title: const Text('Make this my default address', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                    : const Text('Save address'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
