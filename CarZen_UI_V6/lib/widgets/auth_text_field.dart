import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Labelled form field used across the app: the label sits above the input
/// (always visible, read by screen readers), required fields are marked, and
/// password fields get a show/hide toggle.
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool isPassword;
  final bool required;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? helper;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final Widget? suffix;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.isPassword = false,
    this.required = false,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.autofillHints,
    this.onSubmitted,
    this.onChanged,
    this.helper,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.suffix,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.focusNode,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    // Accept legacy "Label *" strings as well as the [required] flag.
    final rawLabel = widget.label;
    final required = widget.required || rawLabel.endsWith(' *');
    final label = rawLabel.replaceAll(' *', '');

    final effectiveKeyboardType = widget.keyboardType ??
        (widget.isPassword
            ? TextInputType.visiblePassword
            : (widget.maxLines > 1 ? TextInputType.multiline : TextInputType.text));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label, required: required),
          const SizedBox(height: 6),
          TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: widget.isPassword && _obscure,
            enableSuggestions: !widget.isPassword,
            autocorrect: !widget.isPassword,
            keyboardType: effectiveKeyboardType,
            textInputAction: widget.maxLines > 1 ? TextInputAction.newline : widget.textInputAction,
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            autofillHints: widget.autofillHints,
            inputFormatters: widget.inputFormatters,
            onFieldSubmitted: widget.onSubmitted,
            onChanged: widget.onChanged,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.maxLines > 1 ? 3 : null,
            maxLength: widget.maxLength,
            enabled: widget.enabled,
            textCapitalization: widget.textCapitalization,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: widget.hint,
              helperText: widget.helper,
              helperMaxLines: 3,
              errorMaxLines: 3,
              prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 20),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                      onPressed: () {
                        final sel = widget.controller.selection;
                        setState(() => _obscure = !_obscure);
                        if (sel.isValid) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) widget.controller.selection = sel;
                          });
                        }
                      },
                    )
                  : widget.suffix,
            ),
          ),
        ],
      ),
    );
  }
}

/// Field label with an optional "required" marker that is spelled out for
/// screen readers.
class FieldLabel extends StatelessWidget {
  final String text;
  final bool required;
  const FieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: required ? '$text, required' : text,
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          children: [
            if (required) const TextSpan(text: ' *', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
