import 'dart:convert';

import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/pages/login_page.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/price_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/form_widgets.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Values the price model understands (it was trained on these labels).
const _fuels = ['Petrol', 'Diesel', 'CNG', 'LPG'];
const _sellerTypes = ['Individual', 'Dealer', 'Trustmark Dealer'];
const _transmissions = ['Manual', 'Automatic'];
const _owners = ['First Owner', 'Second Owner', 'Third Owner', 'Fourth & Above Owner', 'Test Drive Car'];

/// Price check - `POST /v1/car-price-predict` (estimates are saved to the
/// user's history, `GET /v1/car-price-predict`).
class PriceCheckScreen extends StatefulWidget {
  const PriceCheckScreen({super.key});

  @override
  State<PriceCheckScreen> createState() => _PriceCheckScreenState();
}

class _PriceCheckScreenState extends State<PriceCheckScreen> {
  final _service = PriceService();
  final _session = SessionController.instance;
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _year = TextEditingController();
  final _km = TextEditingController();
  final _mileage = TextEditingController();
  final _engine = TextEditingController();
  final _power = TextEditingController();
  final _seats = TextEditingController(text: '5');
  final _resultKey = GlobalKey();

  String _fuel = 'Petrol';
  String _sellerType = 'Individual';
  String _transmission = 'Manual';
  String _owner = 'First Owner';
  bool _submitting = false;
  String? _error;
  PriceEstimate? _result;
  List<String> _names = const [];
  PagedController<PriceEstimate>? _history;

  @override
  void initState() {
    super.initState();
    _loadNames();
    _session.addListener(_onSession);
    _onSession();
  }

  void _onSession() {
    if (_session.isLoggedIn && _history == null) {
      setState(() => _history = PagedController<PriceEstimate>(limit: 5, fetch: (p, l) => _service.history(page: p, limit: l))..load());
    } else if (!_session.isLoggedIn && _history != null) {
      final old = _history;
      setState(() => _history = null);
      old?.dispose();
    }
  }

  Future<void> _loadNames() async {
    try {
      final raw = await rootBundle.loadString('assets/data/price_model_names.json');
      final list = (jsonDecode(raw) as List).cast<String>();
      if (mounted) setState(() => _names = list);
    } catch (_) {
      // Suggestions are optional; typing any name still works.
    }
  }

  @override
  void dispose() {
    _session.removeListener(_onSession);
    _history?.dispose();
    for (final c in [_name, _year, _km, _mileage, _engine, _power, _seats]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _yearValidator(String? v) {
    final n = int.tryParse((v ?? '').trim());
    final max = DateTime.now().year.clamp(1980, 2026);
    if (n == null) return 'Enter the year';
    if (n < 1980 || n > max) return 'Use a year from 1980 to $max';
    return null;
  }

  String? _seatsValidator(String? v) {
    final n = int.tryParse((v ?? '').trim());
    if (n == null || n < 1 || n > 20) return 'Enter 1 to 20 seats';
    return null;
  }

  String? _kmValidator(String? v) {
    final n = int.tryParse((v ?? '').replaceAll(',', '').trim());
    if (n == null || n < 0) return 'Enter the kilometres driven';
    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    if (!_session.isLoggedIn) {
      final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const LoginPage(returnToPrevious: true)));
      await _session.refresh();
      if (ok != true || !mounted) return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final result = await _service.estimate(
        name: _name.text.trim(),
        year: int.parse(_year.text.trim()),
        kmDriven: int.parse(_km.text.replaceAll(',', '').trim()),
        fuel: _fuel,
        sellerType: _sellerType,
        transmission: _transmission,
        owner: _owner,
        mileage: num.parse(_mileage.text.trim()),
        engine: num.parse(_engine.text.trim()),
        maxPower: num.parse(_power.text.trim()),
        seats: int.parse(_seats.text.trim()),
      );
      if (!mounted) return;
      setState(() => _result = result);
      _history?.refresh();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _resultKey.currentContext;
        if (ctx != null && Breakpoints.widthOf(context) < 1024) {
          Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 300), alignment: 0.05);
        }
      });
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _fillFrom(PriceEstimate e) {
    setState(() {
      _name.text = e.name;
      _year.text = '${e.year}';
      _km.text = '${e.kmDriven}';
      if (_fuels.contains(e.fuel)) _fuel = e.fuel;
      if (_sellerTypes.contains(e.sellerType)) _sellerType = e.sellerType;
      if (_transmissions.contains(e.transmission)) _transmission = e.transmission;
      if (_owners.contains(e.owner)) _owner = e.owner;
      _mileage.text = e.mileage?.toString() ?? '';
      _engine.text = e.engine?.toString() ?? '';
      _power.text = e.maxPower?.toString() ?? '';
      _seats.text = e.seats?.toString() ?? '5';
      _result = e;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final wide = width >= 1024;
    final form = _buildForm();
    final result = KeyedSubtree(key: _resultKey, child: _ResultPanel(result: _result, onSell: () => Navigator.of(context).pushNamed(AppRoutes.sellNew)));

    return AppScaffold(
      section: NavSection.priceCheck,
      title: 'Price check',
      showBottomNav: true,
      body: PageScroll(
        maxWidth: 1180,
        verticalPadding: Breakpoints.isCompact(context) ? 18 : 32,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const PageHeader(
              title: 'What is my car worth?',
              subtitle: 'Get a resale estimate from CarZen\'s price model, trained on used-car sales in India. Use it as a starting point for your asking price.',
            ),
            const SizedBox(height: 24),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: form),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [result, const SizedBox(height: 20), _historySection()],
                    ),
                  ),
                ],
              )
            else ...[
              form,
              const SizedBox(height: 20),
              result,
              const SizedBox(height: 24),
              _historySection(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormPanel(
            title: 'The car',
            children: [
              _NameField(controller: _name, names: _names),
              FieldPair(
                AuthTextField(
                  controller: _year,
                  label: 'Year of manufacture',
                  required: true,
                  hint: 'e.g. 2018',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  validator: _yearValidator,
                ),
                AuthTextField(
                  controller: _km,
                  label: 'Kilometres driven',
                  required: true,
                  hint: 'e.g. 42000',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _kmValidator,
                ),
              ),
              ChoiceField<String>(label: 'Fuel', values: _fuels, selected: _fuel, labelOf: (v) => v, onSelected: (v) => setState(() => _fuel = v)),
              ChoiceField<String>(
                label: 'Transmission',
                values: _transmissions,
                selected: _transmission,
                labelOf: (v) => v,
                onSelected: (v) => setState(() => _transmission = v),
              ),
              FieldPair(
                DropdownField<String>(
                  label: 'Ownership',
                  required: true,
                  value: _owner,
                  items: [for (final o in _owners) DropdownMenuItem(value: o, child: Text(o))],
                  onChanged: (v) => setState(() => _owner = v ?? _owner),
                ),
                DropdownField<String>(
                  label: 'Sold by',
                  required: true,
                  value: _sellerType,
                  items: [for (final o in _sellerTypes) DropdownMenuItem(value: o, child: Text(o))],
                  onChanged: (v) => setState(() => _sellerType = v ?? _sellerType),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FormPanel(
            title: 'Specifications',
            subtitle: 'Find these in the brochure, the RC or the manufacturer\'s website.',
            children: [
              FieldPair(
                AuthTextField(
                  controller: _mileage,
                  label: 'Fuel efficiency (km/l or km/kg)',
                  required: true,
                  hint: 'e.g. 21.4',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.positiveNumber(v, field: 'Fuel efficiency'),
                ),
                AuthTextField(
                  controller: _engine,
                  label: 'Engine (cc)',
                  required: true,
                  hint: 'e.g. 1197',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.positiveNumber(v, field: 'Engine size'),
                ),
              ),
              FieldPair(
                AuthTextField(
                  controller: _power,
                  label: 'Max power (bhp)',
                  required: true,
                  hint: 'e.g. 82',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => Validators.positiveNumber(v, field: 'Max power'),
                ),
                AuthTextField(
                  controller: _seats,
                  label: 'Seats',
                  required: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(2)],
                  validator: _seatsValidator,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_error != null) InlineError(_error!),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _submitting ? null : _submit,
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                  child: _submitting
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                      : Text(_session.isLoggedIn ? 'Get my estimate' : 'Log in and get my estimate'),
                ),
              ),
            ],
          ),
          if (!_session.isLoggedIn)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'Estimates are saved to your account so you can compare them later.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  Widget _historySection() {
    final history = _history;
    if (history == null) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle('Your past estimates'),
        PagedBody<PriceEstimate>(
          controller: history,
          itemLabel: 'estimates',
          skeletonHeight: 64,
          spacing: 8,
          empty: const EmptyStateView(compact: true, icon: Icons.query_stats, title: 'No estimates yet', message: 'Your estimates will be listed here.'),
          itemBuilder: (context, e) => Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.md),
              onTap: () => _fillFrom(e),
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${e.year} ${e.name}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(
                            '${formatKm(e.kmDriven)}  |  ${e.fuel}  |  ${e.owner}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(formatLakh(e.predictedPrice), style: AppText.price(15)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NameField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> names;
  const _NameField({required this.controller, required this.names});

  @override
  State<_NameField> createState() => _NameFieldState();
}

class _NameFieldState extends State<_NameField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final names = widget.names;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const FieldLabel('Make, model and variant', required: true),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) => RawAutocomplete<String>(
              textEditingController: widget.controller,
              focusNode: _focus,
              optionsBuilder: (value) {
                final q = value.text.trim().toLowerCase();
                if (q.length < 2 || names.isEmpty) return const Iterable<String>.empty();
                final words = q.split(RegExp(r'\s+'));
                return names.where((n) {
                  final l = n.toLowerCase();
                  return words.every(l.contains);
                }).take(8);
              },
              fieldViewBuilder: (context, textController, focusNode, onSubmit) => TextFormField(
                controller: textController,
                focusNode: focusNode,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Maruti Swift VXI',
                  helperText: 'Pick a suggestion when one matches - the estimate is more accurate.',
                  helperMaxLines: 2,
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'Enter the car\'s make and model';
                  if (t.length > 100) return 'Keep it under 100 characters';
                  return null;
                },
                onFieldSubmitted: (_) => onSubmit(),
              ),
              optionsViewBuilder: (context, onSelected, options) => Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 300, maxWidth: constraints.maxWidth),
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shrinkWrap: true,
                      children: [
                        for (final o in options)
                          InkWell(
                            onTap: () => onSelected(o),
                            child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), child: Text(o)),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultPanel extends StatelessWidget {
  final PriceEstimate? result;
  final VoidCallback onSell;
  const _ResultPanel({required this.result, required this.onSell});

  @override
  Widget build(BuildContext context) {
    final r = result;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadii.xl)),
        child: r == null
            ? const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.query_stats, color: AppColors.chromeBright, size: 28),
                  SizedBox(height: 14),
                  Text('Your estimate appears here', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text(
                    'Fill in the details about your car. The more exact the specifications, the closer the estimate.',
                    style: TextStyle(color: Color(0xFFB9C6D8), height: 1.5),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${r.year} ${r.name}', style: const TextStyle(color: Color(0xFFB9C6D8), fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    decoration: BoxDecoration(color: AppColors.plate, borderRadius: BorderRadius.circular(AppRadii.sm)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Estimated resale value', style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(formatLakh(r.predictedPrice), style: AppText.price(34, color: AppColors.ink)),
                        Text(formatInr(r.predictedPrice), style: AppText.figures(13.5, color: AppColors.ink)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${formatKm(r.kmDriven)}  |  ${r.fuel}  |  ${r.transmission}  |  ${r.owner}',
                    style: const TextStyle(color: Color(0xFFB9C6D8), fontSize: 13.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'An estimate, not an offer. Condition, service history and your city can move the final price.',
                    style: TextStyle(color: Color(0xFFB9C6D8), fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: onSell,
                    style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.ink),
                    child: const Text('Sell this car on CarZen'),
                  ),
                ],
              ),
      ),
    );
  }
}
