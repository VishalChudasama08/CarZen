import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/services/catalog_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/utils/india.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/form_widgets.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Add (`POST /v1/cars`) or edit (`PATCH /v1/cars/{id}`) a car in three
/// steps: the car itself, its history, and where it is. Every `CarCreate`
/// field is available; the ones resale requires are asked for up front so
/// the car can pass review.
class AddEditCarScreen extends StatefulWidget {
  final CarRecordDetail? existingCar;

  /// Load the car to edit by id (deep links).
  final int? carId;

  const AddEditCarScreen({super.key, this.existingCar, this.carId});

  @override
  State<AddEditCarScreen> createState() => _AddEditCarScreenState();
}

class _AddEditCarScreenState extends State<AddEditCarScreen> {
  static const _steps = ['Your car', 'History', 'Location and price'];

  final _formKeys = [GlobalKey<FormState>(), GlobalKey<FormState>(), GlobalKey<FormState>()];
  final _catalog = CatalogService();
  final _cars = CarService();
  final _scroll = ScrollController();

  final _year = TextEditingController();
  final _km = TextEditingController();
  final _regNumber = TextEditingController();
  final _regYear = TextEditingController();
  final _vin = TextEditingController();
  final _insurer = TextEditingController();
  final _city = TextEditingController();
  final _pin = TextEditingController();
  final _color = TextEditingController();
  final _engine = TextEditingController();
  final _power = TextEditingController();
  final _seats = TextEditingController();
  final _price = TextEditingController();
  final _description = TextEditingController();

  CarRecordDetail? _existing;
  bool _loadingExisting = false;
  Object? _loadError;

  List<CatalogBrand> _brands = [];
  List<CatalogCarModel> _models = [];
  List<CatalogVariant> _variants = [];
  int? _brandId;
  int? _modelId;
  int? _variantId;
  bool _loadingBrands = true;
  bool _loadingModels = false;
  bool _loadingVariants = false;

  FuelType? _fuel;
  TransmissionType? _gearbox;
  CarCondition? _condition;
  OwnershipType? _ownership;
  String? _insuranceType;
  DateTime? _insuranceExpiry;
  String? _rcStatus;
  String? _state;

  int _step = 0;
  bool _saving = false;
  String? _error;
  bool _triedStep0 = false;

  bool get _editing => _existing != null;

  @override
  void initState() {
    super.initState();
    _existing = widget.existingCar;
    if (_existing == null && widget.carId != null) {
      _loadExisting(widget.carId!);
    } else {
      _prefill();
    }
    _loadBrands();
  }

  @override
  void dispose() {
    for (final c in [_year, _km, _regNumber, _regYear, _vin, _insurer, _city, _pin, _color, _engine, _power, _seats, _price, _description]) {
      c.dispose();
    }
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadExisting(int id) async {
    setState(() {
      _loadingExisting = true;
      _loadError = null;
    });
    try {
      final car = await _cars.getCar(id);
      if (!mounted) return;
      setState(() {
        _existing = car;
        _loadingExisting = false;
      });
      _prefill();
      if (car.brandId != 0) await _selectBrand(car.brandId, keepSelection: true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadError = e;
          _loadingExisting = false;
        });
      }
    }
  }

  String _num(num? v) => v == null ? '' : (v == v.roundToDouble() ? v.round().toString() : v.toString());

  void _prefill() {
    final car = _existing;
    if (car == null) return;
    _brandId = car.brandId == 0 ? null : car.brandId;
    _modelId = car.modelId == 0 ? null : car.modelId;
    _variantId = car.variantId;
    _year.text = '${car.manufacturingYear}';
    _km.text = _num(car.mileageKm);
    _regNumber.text = car.registrationNumber ?? '';
    _regYear.text = car.registrationYear?.toString() ?? '';
    _vin.text = car.vinNumber ?? '';
    _insurer.text = car.insuranceCompany ?? '';
    _insuranceType = car.insuranceType;
    _insuranceExpiry = car.insuranceExpiry == null ? null : DateTime.tryParse(car.insuranceExpiry!);
    _rcStatus = car.rcStatus;
    _city.text = car.city;
    _state = indianStates.contains(car.state) ? car.state : null;
    _pin.text = car.postalCode ?? '';
    _color.text = car.color ?? '';
    _engine.text = _num(car.engineCc);
    _power.text = _num(car.horsepower);
    _seats.text = car.seatingCapacity?.toString() ?? '';
    _price.text = _num(car.expectedMarketPrice);
    _description.text = car.description ?? '';
    _fuel = car.fuelType;
    _gearbox = car.transmission;
    _condition = car.condition;
    _ownership = car.ownershipType;
  }

  Future<void> _loadBrands() async {
    try {
      final page = await _catalog.listBrands(limit: 100, isActive: true);
      if (!mounted) return;
      setState(() {
        _brands = page.data;
        _loadingBrands = false;
      });
      if (_brandId != null && _models.isEmpty) await _selectBrand(_brandId!, keepSelection: true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loadingBrands = false;
          _error = 'Car brands could not be loaded. ${e.message}';
        });
      }
    }
  }

  Future<void> _selectBrand(int? id, {bool keepSelection = false}) async {
    setState(() {
      _brandId = id;
      if (!keepSelection) {
        _modelId = null;
        _variantId = null;
      }
      _models = [];
      _variants = [];
      _loadingModels = id != null;
    });
    if (id == null) return;
    try {
      final page = await _catalog.listModelsForBrand(id);
      if (!mounted || _brandId != id) return;
      setState(() {
        _models = page.data.where((m) => m.isActive || m.id == _modelId).toList();
        _loadingModels = false;
      });
      if (keepSelection && _modelId != null) await _selectModel(_modelId, keepSelection: true);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loadingModels = false;
          _error = 'Models could not be loaded. ${e.message}';
        });
      }
    }
  }

  Future<void> _selectModel(int? id, {bool keepSelection = false}) async {
    setState(() {
      _modelId = id;
      if (!keepSelection) _variantId = null;
      _variants = [];
      _loadingVariants = id != null;
    });
    if (id == null) return;
    try {
      final page = await _catalog.listVariantsForModel(id);
      if (!mounted || _modelId != id) return;
      setState(() {
        _variants = page.data;
        _loadingVariants = false;
      });
      final model = _models.where((m) => m.id == id).firstOrNull;
      if (model?.seatingCapacity != null && _seats.text.isEmpty) _seats.text = '${model!.seatingCapacity}';
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _loadingVariants = false;
          _error = 'Variants could not be loaded. ${e.message}';
        });
      }
    }
  }

  /// Choosing a variant fills in what the catalogue already knows.
  void _selectVariant(int? id) {
    final v = _variants.where((v) => v.id == id).firstOrNull;
    setState(() {
      _variantId = id;
      if (v != null) {
        _fuel = v.fuelType;
        _gearbox = v.transmission;
        if (v.engineCc != null) _engine.text = _num(v.engineCc);
        if (v.horsepower != null) _power.text = _num(v.horsepower);
        if (v.seatingCapacity != null) _seats.text = '${v.seatingCapacity}';
      }
    });
  }

  bool _validateStep(int step) {
    if (step == 0) {
      setState(() => _triedStep0 = true);
      final formOk = _formKeys[0].currentState?.validate() ?? false;
      return formOk && _variantId != null && _fuel != null && _gearbox != null && _condition != null;
    }
    return _formKeys[step].currentState?.validate() ?? false;
  }

  void _goTo(int step) {
    setState(() {
      _step = step;
      _error = null;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _next() {
    if (!_validateStep(_step)) return;
    if (_step < _steps.length - 1) {
      _goTo(_step + 1);
    } else {
      _save();
    }
  }

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());
  num? _number(TextEditingController c) => num.tryParse(c.text.replaceAll(',', '').trim());
  String? _text(TextEditingController c) => c.text.trim().isEmpty ? null : c.text.trim();

  Map<String, dynamic> _payload() {
    final owners = switch (_ownership) {
      OwnershipType.firstOwner => 1,
      OwnershipType.secondOwner => 2,
      OwnershipType.thirdOwner => 3,
      OwnershipType.fourthOrMore => 4,
      null => null,
    };
    return {
      'variant_id': _variantId,
      'manufacturing_year': _int(_year),
      'registration_year': _int(_regYear),
      'registration_number': _text(_regNumber)?.toUpperCase().replaceAll(' ', ''),
      'vin_number': _text(_vin)?.toUpperCase(),
      'fuel_type': _fuel!.apiValue,
      'transmission': _gearbox!.apiValue,
      'mileage_km': _number(_km) ?? 0,
      'condition': _condition!.apiValue,
      'ownership_type': _ownership?.apiValue,
      'owner_count': owners,
      'insurance_company': _text(_insurer),
      'insurance_type': _insuranceType,
      'insurance_expiry': _insuranceExpiry == null ? null : toApiDate(_insuranceExpiry!),
      'rc_status': _rcStatus,
      'city': _city.text.trim(),
      'state': _state,
      'country': 'India',
      'postal_code': _text(_pin),
      'color': _text(_color),
      'engine_cc': _number(_engine),
      'horsepower': _number(_power),
      'seating_capacity': _int(_seats),
      'expected_market_price': _number(_price),
      'description': _text(_description),
    };
  }

  Future<void> _save() async {
    if (_saving) return;
    for (var i = 0; i < _steps.length; i++) {
      if (!_validateStep(i)) {
        _goTo(i);
        return;
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final body = _payload();
      if (_editing) {
        await _cars.updateCar(_existing!.id, body);
        if (!mounted) return;
        showAppSnack(context, 'Changes saved');
        Navigator.of(context).pop(true);
      } else {
        body.removeWhere((k, v) => v == null);
        final car = await _cars.createCarFromFields(body);
        if (!mounted) return;
        showAppSnack(context, 'Car saved. Add photos so our team can review it.');
        Navigator.of(context).pushReplacementNamed(AppRoutes.myCar(car.id));
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.sell,
      title: _editing ? 'Edit car details' : 'Add your car',
      fallbackRoute: AppRoutes.sell,
      showBackButton: true,
      body: _loadingExisting
          ? const LoadingView(label: 'Loading your car...')
          : _loadError != null
              ? ApiErrorView(error: _loadError!, onRetry: () => _loadExisting(widget.carId!))
              : _form(context),
    );
  }

  Widget _form(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            controller: _scroll,
            child: PageContainer(
              maxWidth: 760,
              verticalPadding: compact ? 18 : 32,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PageHeader(
                    title: _editing ? 'Edit car details' : 'Add your car',
                    subtitle: _editing
                        ? 'Changing key details sends the car back for a quick review.'
                        : 'Three short steps. Our team checks the details before your car can be listed.',
                  ),
                  const SizedBox(height: 22),
                  StepIndicator(steps: _steps, current: _step, onTap: _goTo),
                  const SizedBox(height: 22),
                  if (_error != null) InlineError(_error!),
                  IndexedStack(
                    index: _step,
                    sizing: StackFit.loose,
                    children: [
                      Visibility(visible: _step == 0, maintainState: true, child: _stepCar()),
                      Visibility(visible: _step == 1, maintainState: true, child: _stepHistory()),
                      Visibility(visible: _step == 2, maintainState: true, child: _stepPlace()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        _BottomBar(
          step: _step,
          total: _steps.length,
          saving: _saving,
          editing: _editing,
          onBack: _step == 0 ? null : () => _goTo(_step - 1),
          onNext: _next,
          onSaveNow: _editing && _step < _steps.length - 1 ? _save : null,
        ),
      ],
    );
  }

  Widget _stepCar() {
    final year = DateTime.now().year;
    return Form(
      key: _formKeys[0],
      child: FormPanel(
        title: 'Which car is it?',
        subtitle: 'Pick it from the catalogue so buyers see the right specifications.',
        children: [
          DropdownField<int>(
            label: 'Brand',
            required: true,
            value: _brandId,
            loading: _loadingBrands,
            items: [for (final b in _brands) DropdownMenuItem(value: b.id, child: Text(b.name))],
            onChanged: (v) => _selectBrand(v),
            validator: (v) => v == null ? 'Choose the brand' : null,
          ),
          FieldPair(
            DropdownField<int>(
              label: 'Model',
              required: true,
              value: _models.any((m) => m.id == _modelId) ? _modelId : null,
              loading: _loadingModels,
              hint: _brandId == null ? 'Choose a brand first' : 'Select',
              items: [for (final m in _models) DropdownMenuItem(value: m.id, child: Text(m.name))],
              onChanged: _brandId == null ? null : (v) => _selectModel(v),
              validator: (v) => v == null ? 'Choose the model' : null,
            ),
            DropdownField<int>(
              label: 'Variant',
              required: true,
              value: _variants.any((v) => v.id == _variantId) ? _variantId : null,
              loading: _loadingVariants,
              hint: _modelId == null ? 'Choose a model first' : 'Select',
              items: [
                for (final v in _variants)
                  DropdownMenuItem(value: v.id, child: Text('${v.variantName} (${v.fuelType.label}, ${v.transmission.label})', overflow: TextOverflow.ellipsis)),
              ],
              onChanged: _modelId == null ? null : _selectVariant,
              validator: (v) => v == null ? 'Choose the variant' : null,
            ),
          ),
          AuthTextField(
            controller: _year,
            label: 'Year of manufacture',
            required: true,
            hint: 'e.g. 2021',
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null) return 'Enter the year';
              if (n < 1950 || n > year) return 'Use a year between 1950 and $year';
              return null;
            },
          ),
          ChoiceField<FuelType>(
            label: 'Fuel',
            required: true,
            values: FuelType.values,
            selected: _fuel,
            labelOf: (v) => v.label,
            onSelected: (v) => setState(() => _fuel = v),
            errorText: _triedStep0 && _fuel == null ? 'Choose the fuel type' : null,
          ),
          ChoiceField<TransmissionType>(
            label: 'Gearbox',
            required: true,
            values: TransmissionType.values,
            selected: _gearbox,
            labelOf: (v) => v.label,
            onSelected: (v) => setState(() => _gearbox = v),
            errorText: _triedStep0 && _gearbox == null ? 'Choose the gearbox' : null,
          ),
          ChoiceField<CarCondition>(
            label: 'Condition',
            required: true,
            values: [
              CarCondition.excellent,
              CarCondition.good,
              CarCondition.fair,
              CarCondition.poor,
              CarCondition.newCar,
              if (_condition == CarCondition.old) CarCondition.old,
            ],
            selected: _condition,
            labelOf: (v) => v.label,
            onSelected: (v) => setState(() => _condition = v),
            errorText: _triedStep0 && _condition == null ? 'Choose the condition' : null,
          ),
        ],
      ),
    );
  }

  Widget _stepHistory() {
    final year = DateTime.now().year;
    final needsResaleDetails = _condition == CarCondition.old;
    return Form(
      key: _formKeys[1],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormPanel(
            title: 'Usage and ownership',
            children: [
              FieldPair(
                AuthTextField(
                  controller: _km,
                  label: 'Kilometres driven',
                  required: true,
                  hint: 'e.g. 42000',
                  keyboardType: TextInputType.number,
                  validator: (v) => Validators.positiveNumber(v, field: 'Kilometres'),
                ),
                DropdownField<OwnershipType>(
                  label: 'Ownership',
                  required: needsResaleDetails,
                  value: _ownership,
                  items: [for (final o in OwnershipType.values) DropdownMenuItem(value: o, child: Text(o.label))],
                  onChanged: (v) => setState(() => _ownership = v),
                  validator: (v) => needsResaleDetails && v == null ? 'Required for resale' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormPanel(
            title: 'Registration',
            subtitle: 'Used only for our check. Buyers never see the registration or chassis number.',
            children: [
              FieldPair(
                AuthTextField(
                  controller: _regNumber,
                  label: 'Registration number',
                  required: needsResaleDetails,
                  hint: 'e.g. GJ01AB1234',
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return needsResaleDetails ? 'Required for resale' : null;
                    if (s.length > 30) return 'Too long';
                    return null;
                  },
                ),
                AuthTextField(
                  controller: _regYear,
                  label: 'Year of registration',
                  required: needsResaleDetails,
                  hint: 'e.g. 2021',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return needsResaleDetails ? 'Required for resale' : null;
                    final n = int.tryParse(s);
                    final made = int.tryParse(_year.text.trim());
                    if (n == null || n > year) return 'Enter a valid year';
                    if (made != null && n < made) return 'Cannot be before the year of manufacture';
                    return null;
                  },
                ),
              ),
              AuthTextField(
                controller: _vin,
                label: 'Chassis number (VIN)',
                required: needsResaleDetails,
                hint: 'Printed on the RC',
                textCapitalization: TextCapitalization.characters,
                validator: (v) {
                  final s = (v ?? '').trim();
                  if (s.isEmpty) return needsResaleDetails ? 'Required for resale' : null;
                  if (s.length > 100) return 'Too long';
                  return null;
                },
              ),
              DropdownField<String>(
                label: 'RC status',
                value: _rcStatus,
                items: [
                  for (final s in {'Active', 'Hypothecated', 'Transferred', ?_rcStatus}) DropdownMenuItem(value: s, child: Text(s)),
                ],
                onChanged: (v) => setState(() => _rcStatus = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormPanel(
            title: 'Insurance',
            children: [
              FieldPair(
                AuthTextField(controller: _insurer, label: 'Insurer', hint: 'e.g. ICICI Lombard'),
                DropdownField<String>(
                  label: 'Cover',
                  value: _insuranceType,
                  items: [
                    for (final s in {'Comprehensive', 'Zero depreciation', 'Third party', ?_insuranceType}) DropdownMenuItem(value: s, child: Text(s)),
                  ],
                  onChanged: (v) => setState(() => _insuranceType = v),
                ),
              ),
              DateField(
                label: 'Valid until',
                value: _insuranceExpiry,
                firstDate: DateTime(2000),
                lastDate: DateTime(DateTime.now().year + 6),
                onChanged: (d) => setState(() => _insuranceExpiry = d),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _stepPlace() {
    return Form(
      key: _formKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormPanel(
            title: 'Where is the car?',
            children: [
              FieldPair(
                AuthTextField(
                  controller: _city,
                  label: 'City',
                  required: true,
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => Validators.required(v, message: 'Enter the city'),
                ),
                DropdownField<String>(
                  label: 'State',
                  required: true,
                  value: _state,
                  items: [for (final s in indianStates) DropdownMenuItem(value: s, child: Text(s))],
                  onChanged: (v) => setState(() => _state = v),
                  validator: (v) => v == null ? 'Choose the state' : null,
                ),
              ),
              AuthTextField(controller: _pin, label: 'PIN code', keyboardType: TextInputType.number, validator: (v) => validatePin(v)),
            ],
          ),
          const SizedBox(height: 16),
          FormPanel(
            title: 'More about the car',
            subtitle: 'Filled in from the catalogue where possible. Correct anything that differs.',
            children: [
              FieldPair(
                AuthTextField(controller: _color, label: 'Colour', hint: 'e.g. Pearl White', textCapitalization: TextCapitalization.words),
                AuthTextField(
                  controller: _seats,
                  label: 'Seats',
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return null;
                    final n = int.tryParse(s);
                    return (n == null || n < 1 || n > 20) ? 'Enter a number of seats' : null;
                  },
                ),
              ),
              FieldPair(
                AuthTextField(controller: _engine, label: 'Engine (cc)', keyboardType: TextInputType.number, validator: (v) => Validators.positiveNumber(v, field: 'Engine', required: false)),
                AuthTextField(controller: _power, label: 'Power (hp)', keyboardType: TextInputType.number, validator: (v) => Validators.positiveNumber(v, field: 'Power', required: false)),
              ),
              AuthTextField(
                controller: _description,
                label: 'Description',
                maxLines: 5,
                maxLength: 2000,
                hint: 'Service history, recent work, anything a buyer should know.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormPanel(
            title: 'Your price idea',
            subtitle: 'Optional. You set the asking price when you create the listing.',
            children: [
              AuthTextField(
                controller: _price,
                label: 'Expected price (₹)',
                hint: 'e.g. 650000',
                keyboardType: TextInputType.number,
                helper: _number(_price) == null ? null : formatInr(_number(_price)!),
                onChanged: (_) => setState(() {}),
                validator: (v) => Validators.positiveNumber(v, field: 'Price', required: false),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.priceCheck),
                  icon: const Icon(Icons.query_stats, size: 18),
                  label: const Text('Not sure? Get a price estimate'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int step;
  final int total;
  final bool saving;
  final bool editing;
  final VoidCallback? onBack;
  final VoidCallback onNext;
  final VoidCallback? onSaveNow;

  const _BottomBar({
    required this.step,
    required this.total,
    required this.saving,
    required this.editing,
    required this.onBack,
    required this.onNext,
    this.onSaveNow,
  });

  @override
  Widget build(BuildContext context) {
    final last = step == total - 1;
    return Material(
      color: AppColors.surface,
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: CallbackShortcuts(
                  bindings: {const SingleActivator(LogicalKeyboardKey.enter, control: true): onNext},
                  child: Row(
                    children: [
                      if (onBack != null) OutlinedButton(onPressed: saving ? null : onBack, child: const Text('Back')),
                      const Spacer(),
                      if (onSaveNow != null) ...[
                        TextButton(
                          onPressed: saving ? null : onSaveNow,
                          child: Text(Breakpoints.isCompact(context) ? 'Save' : 'Save changes'),
                        ),
                        const SizedBox(width: 8),
                      ],
                      FilledButton(
                        onPressed: saving ? null : onNext,
                        child: saving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                            : Text(last ? (editing ? 'Save changes' : 'Save car') : 'Continue'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
