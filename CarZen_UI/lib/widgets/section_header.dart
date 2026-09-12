import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Standard "Title ... See all" row used above every horizontal section
/// (Featured Cars, Popular Brands, Categories) to keep spacing consistent.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel = 'See all',
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          if (onActionTap != null)
            InkWell(
              onTap: onActionTap,
              child: Text(
                actionLabel ?? '',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
