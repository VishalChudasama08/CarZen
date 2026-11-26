import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:flutter/material.dart';

/// A titled group of form fields inside a white panel.
class FormPanel extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  const FormPanel({super.key, required this.title, this.subtitle, required this.children, this.trailing, this.padding = const EdgeInsets.all(20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(header: true, child: Text(title, style: AppText.heading(17))),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45)),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
      ),
    );
  }
}

/// Two fields side by side when there is room, stacked otherwise.
class FieldPair extends StatelessWidget {
  final Widget first;
  final Widget second;
  final double breakpoint;
  const FieldPair(this.first, this.second, {super.key, this.breakpoint = 460});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= breakpoint
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: first), const SizedBox(width: 14), Expanded(child: second)])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [first, second]),
    );
  }
}

/// Labelled single-choice chips.
class ChoiceField<T> extends StatelessWidget {
  final String label;
  final bool required;
  final List<T> values;
  final T? selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onSelected;
  final String? errorText;

  const ChoiceField({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
    this.required = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(label, required: required),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final v in values)
                ChoiceChip(
                  label: Text(labelOf(v)),
                  selected: v == selected,
                  showCheckmark: false,
                  labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: v == selected ? Colors.white : AppColors.textPrimary),
                  onSelected: (_) => onSelected(v),
                ),
            ],
          ),
          if (errorText != null) ...[
            const SizedBox(height: 6),
            Text(errorText!, style: const TextStyle(color: AppColors.danger, fontSize: 12.5)),
          ],
        ],
      ),
    );
  }
}

/// Labelled dropdown matching [AuthTextField]'s look.
class DropdownField<T> extends StatelessWidget {
  final String label;
  final bool required;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? hint;
  final String? Function(T?)? validator;
  final bool loading;
  final String? helper;

  const DropdownField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = false,
    this.hint,
    this.validator,
    this.loading = false,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(label, required: required),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            key: ValueKey('$label-$value-${items.length}'),
            initialValue: value,
            isExpanded: true,
            items: items,
            onChanged: loading ? null : onChanged,
            validator: validator,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontFamily: AppText.body),
            hint: Text(loading ? 'Loading...' : (hint ?? 'Select')),
            decoration: InputDecoration(
              helperText: helper,
              helperMaxLines: 3,
              suffixIcon: loading
                  ? const Padding(padding: EdgeInsets.all(14), child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)))
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Date field that opens the platform date picker.
class DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  final DateTime firstDate;
  final DateTime lastDate;
  final bool required;
  final String? helper;

  const DateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.firstDate,
    required this.lastDate,
    this.required = false,
    this.helper,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(label, required: required),
          const SizedBox(height: 6),
          InkWell(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value ?? (DateTime.now().isAfter(lastDate) ? lastDate : DateTime.now()),
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked != null) onChanged(picked);
            },
            child: InputDecorator(
              decoration: InputDecoration(
                helperText: helper,
              helperMaxLines: 3,
                prefixIcon: const Icon(Icons.event_outlined, size: 20),
                suffixIcon: value == null
                    ? null
                    : IconButton(tooltip: 'Clear date', icon: const Icon(Icons.close, size: 18), onPressed: () => onChanged(null)),
              ),
              child: Text(
                value == null ? 'Choose a date' : formatDate(value),
                style: TextStyle(fontSize: 15, color: value == null ? AppColors.textTertiary : AppColors.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal step indicator for multi-step forms. Steps before [current]
/// are done; tapping a done step jumps back to it.
class StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int current;
  final ValueChanged<int>? onTap;

  const StepIndicator({super.key, required this.steps, required this.current, this.onTap});

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 520;
    return Row(
      children: [
        for (var i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 8), color: i <= current ? AppColors.ink : AppColors.divider),
            ),
          Semantics(
            label: 'Step ${i + 1} of ${steps.length}: ${steps[i]}${i == current ? ', current' : (i < current ? ', done' : '')}',
            button: onTap != null && i < current,
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadii.sm),
              onTap: onTap != null && i < current ? () => onTap!(i) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: i < current ? AppColors.ink : (i == current ? AppColors.plate : AppColors.surface),
                        borderRadius: BorderRadius.circular(AppRadii.xs),
                        border: Border.all(color: i <= current ? Colors.transparent : AppColors.lineStrong),
                      ),
                      child: i < current
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : Text('${i + 1}', style: AppText.figures(13, weight: FontWeight.w700, color: AppColors.ink)),
                    ),
                    if (!compact || i == current) ...[
                      const SizedBox(width: 8),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontWeight: i == current ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                          color: i <= current ? AppColors.ink : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
