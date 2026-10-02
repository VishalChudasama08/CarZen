import 'package:flutter/material.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// Rounded search field with an optional filter button. Stateless and
/// callback-driven; the parent owns the query and decides what a submit does.
class CarSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onFilterTap;
  final String hint;

  const CarSearchBar({
    super.key,
    required this.controller,
    this.onSubmitted,
    this.onFilterTap,
    this.hint = 'Search brand, model or variant',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onSubmitted: onSubmitted,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (_, value, __) => value.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          controller.clear();
                          onSubmitted?.call('');
                        },
                      ),
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 10),
          IconButton.filled(
            tooltip: 'Filters',
            onPressed: onFilterTap,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.cyan,
              minimumSize: const Size(52, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
            ),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ],
    );
  }
}
