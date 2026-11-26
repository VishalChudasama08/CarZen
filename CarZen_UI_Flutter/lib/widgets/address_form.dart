import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/services/address_service.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/india.dart';
import 'package:carzen_flutter/utils/validators.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/form_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Opens the add/edit address form (a bottom sheet on phones, a dialog on
/// larger screens). Returns the saved address, or null when cancelled.
Future<AddressRecord?> showAddressForm(BuildContext context, {AddressRecord? existing, bool makeDefault = false}) {
  final form = _AddressForm(existing: existing, makeDefault: makeDefault);
  if (Breakpoints.isCompact(context)) {
    return showModalBottomSheet<AddressRecord>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.9,
          maxChildSize: 0.95,
          builder: (_, controller) => SingleChildScrollView(controller: controller, padding: const EdgeInsets.fromLTRB(20, 0, 20, 24), child: form),
        ),
      ),
    );
  }
  return showDialog<AddressRecord>(
    context: context,
    builder: (ctx) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: form),
      ),
    ),
  );
}

class _AddressForm extends StatefulWidget {
  final AddressRecord? existing;
  final bool makeDefault;
  const _AddressForm({this.existing, this.makeDefault = false});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  final _service = AddressService();
  late final _line1 = TextEditingController(text: widget.existing?.addressLine1);
  late final _line2 = TextEditingController(text: widget.existing?.addressLine2);
  late final _landmark = TextEditingController(text: widget.existing?.landmark);
  late final _city = TextEditingController(text: widget.existing?.city);
  late final _pin = TextEditingController(text: widget.existing?.postalCode);
  late String? _state = indianStates.contains(widget.existing?.state) ? widget.existing?.state : null;
  late bool _default = widget.existing?.isDefault ?? widget.makeDefault;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_line1, _line2, _landmark, _city, _pin]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final AddressRecord saved;
      if (widget.existing == null) {
        saved = await _service.create(
          addressLine1: _line1.text.trim(),
          addressLine2: _line2.text.trim(),
          landmark: _landmark.text.trim(),
          city: _city.text.trim(),
          state: _state!,
          postalCode: _pin.text.trim(),
          isDefault: _default,
        );
      } else {
        saved = await _service.update(
          widget.existing!.id,
          addressLine1: _line1.text.trim(),
          addressLine2: _line2.text.trim(),
          landmark: _landmark.text.trim(),
          city: _city.text.trim(),
          state: _state!,
          postalCode: _pin.text.trim(),
          isDefault: _default,
        );
      }
      if (mounted) Navigator.of(context).pop(saved);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.existing == null ? 'Add an address' : 'Edit address', style: AppText.heading(19)),
          const SizedBox(height: 18),
          if (_error != null) InlineError(_error!),
          AuthTextField(
            controller: _line1,
            label: 'House, building and street',
            required: true,
            autofillHints: const [AutofillHints.streetAddressLine1],
            validator: (v) => Validators.required(v, message: 'Enter the address'),
          ),
          AuthTextField(controller: _line2, label: 'Area or locality', autofillHints: const [AutofillHints.streetAddressLine2]),
          AuthTextField(controller: _landmark, label: 'Landmark', hint: 'e.g. Near City Mall'),
          FieldPair(
            AuthTextField(
              controller: _city,
              label: 'City',
              required: true,
              autofillHints: const [AutofillHints.addressCity],
              validator: (v) => Validators.required(v, message: 'Enter the city'),
            ),
            AuthTextField(
              controller: _pin,
              label: 'PIN code',
              required: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.postalCode],
              validator: (v) => validatePin(v, required: true),
            ),
          ),
          DropdownField<String>(
            label: 'State',
            required: true,
            value: _state,
            items: [for (final s in indianStates) DropdownMenuItem(value: s, child: Text(s))],
            onChanged: (v) => setState(() => _state = v),
            validator: (v) => v == null ? 'Choose the state' : null,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            value: _default,
            onChanged: (v) => setState(() => _default = v ?? false),
            title: const Text('Use as my default address'),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : const Text('Save address'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
