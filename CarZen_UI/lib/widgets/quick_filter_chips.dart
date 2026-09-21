import 'package:flutter/material.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

// These are filter labels, not vehicle data. Their values map directly to
// the backend's listing query parameters in HomePage.
const quickFilterPrices = ['Any Price', 'Under 5L', '5L - 10L', '10L - 20L', '20L+'];
const quickFilterFuel = ['Any Fuel', 'Petrol', 'Diesel', 'Electric', 'CNG', 'Hybrid'];
const quickFilterTransmission = ['Any', 'Manual', 'Automatic', 'AMT', 'CVT', 'DCT'];

/// One quick-filter definition: a label, the list of choices, the current
/// value and a callback fired when the user picks a new one.
class QuickFilter {
  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const QuickFilter({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });
}

/// Horizontally scrollable row of quick-filter chips (Brand, Price, Fuel,
/// Transmission). Each chip opens a modal picker; the parent screen holds
/// the actual filter state so it can be forwarded to the listing/API layer.
class QuickFilterChips extends StatelessWidget {
  final List<QuickFilter> filters;

  const QuickFilterChips({super.key, required this.filters});

  void _showPicker(BuildContext context, QuickFilter filter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(filter.label, style: Theme.of(context).textTheme.titleMedium),
              ),
              ...filter.options.map(
                (option) => ListTile(
                  title: Text(option),
                  trailing: option == filter.value
                      ? const Icon(Icons.check_circle, color: AppColors.secondary)
                      : null,
                  onTap: () {
                    filter.onChanged(option);
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isDefault = filter.value == filter.options.first;
          return InkWell(
            onTap: () => _showPicker(context, filter),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDefault ? AppColors.surface : AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDefault ? AppColors.divider : AppColors.primary),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter.icon, size: 16, color: isDefault ? AppColors.textSecondary : AppColors.secondary),
                  const SizedBox(width: 6),
                  Text(
                    filter.value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDefault ? AppColors.textPrimary : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16, color: isDefault ? AppColors.textSecondary : Colors.white),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
