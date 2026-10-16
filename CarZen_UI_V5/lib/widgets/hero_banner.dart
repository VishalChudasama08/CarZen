import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:flutter/material.dart';

/// The Home hero: a premium car photo under a navy gradient, a clear headline,
/// the main search field and the three things people come to do (buy, sell,
/// book a service). The photo is decorative; if it can't load, the navy
/// gradient stands in so the text always stays readable.
class HeroBanner extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearch;
  final VoidCallback onExplore;
  final VoidCallback? onSell;
  final VoidCallback? onServices;
  final VoidCallback? onFilterTap;

  const HeroBanner({
    super.key,
    required this.searchController,
    required this.onSearch,
    required this.onExplore,
    this.onSell,
    this.onServices,
    this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    final narrow = Breakpoints.isNarrow(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? AppRadii.lg : AppRadii.xl),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDeep, AppColors.primary],
                ),
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1600',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.primaryDeep.withValues(alpha: 0.94),
                    AppColors.primaryDeep.withValues(alpha: compact ? 0.82 : 0.55),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: narrow ? 14 : (compact ? 20 : 44),
              vertical: narrow ? 20 : (compact ? 28 : 56),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadii.pill),
                    ),
                    child: const Text(
                      'BUY · SELL · SERVICE',
                      style: TextStyle(color: AppColors.cyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Find your perfect car.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: narrow ? 26 : (compact ? 32 : 48),
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Verified listings from real owners, and a workshop team that keeps your car in top shape.',
                    style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: narrow ? 13 : (compact ? 14.5 : 16.5), height: 1.45),
                  ),
                  SizedBox(height: compact ? 20 : 28),
                  _SearchField(controller: searchController, onSubmitted: onSearch, onFilterTap: onFilterTap),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      ElevatedButton.icon(
                        onPressed: onExplore,
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text('Explore cars'),
                      ),
                      if (onSell != null)
                        _GhostButton(icon: Icons.sell_outlined, label: 'Sell your car', onPressed: onSell!),
                      if (onServices != null)
                        _GhostButton(icon: Icons.home_repair_service_outlined, label: 'Book a service', onPressed: onServices!),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _GhostButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 50),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.45)),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onFilterTap;
  const _SearchField({required this.controller, required this.onSubmitted, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    final narrow = Breakpoints.isNarrow(context);
    return Container(
      padding: EdgeInsets.fromLTRB(narrow ? 10 : 16, 4, 4, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        boxShadow: AppShadows.raised,
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
          SizedBox(width: narrow ? 6 : 10),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: narrow ? 13.5 : 15, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: narrow ? 'Search cars...' : 'Search brand, model or variant',
                hintStyle: TextStyle(fontSize: narrow ? 13 : 14.5),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          FilledButton(
            onPressed: () => onSubmitted(controller.text),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 42),
              padding: EdgeInsets.symmetric(horizontal: narrow ? 12 : 20),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
