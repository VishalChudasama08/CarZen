import 'package:flutter/material.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';

/// Centres page content in a readable column on large screens and adds the
/// right gutter for the current width. Use as the child of a scroll view.
class PageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double verticalPadding;

  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.verticalPadding = AppSpacing.xl,
  });

  /// Horizontal padding that centres sliver content in the same column
  /// [PageContainer] would use (for pages built from slivers).
  static EdgeInsets sidePadding(double width, {double maxWidth = Breakpoints.maxContentWidth}) {
    final gutter = AppSpacing.pageGutter(width);
    final extra = width > maxWidth ? (width - maxWidth) / 2 : 0.0;
    return EdgeInsets.symmetric(horizontal: gutter + extra);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.pageGutter(width),
            verticalPadding,
            AppSpacing.pageGutter(width),
            verticalPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Page title block: heading, supporting sentence and optional actions.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final IconData? icon;

  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const [], this.icon});

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ],
    );
    final leading = icon == null
        ? heading
        : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(color: AppColors.cyanTint, borderRadius: BorderRadius.circular(AppRadii.md)),
                child: Icon(icon, color: AppColors.secondary),
              ),
              Expanded(child: heading),
            ],
          );
    if (actions.isEmpty) return leading;
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(height: AppSpacing.md),
          Wrap(spacing: 10, runSpacing: 10, children: actions),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: leading),
        const SizedBox(width: AppSpacing.lg),
        Wrap(spacing: 10, runSpacing: 10, children: actions),
      ],
    );
  }
}

/// Section heading inside a page ("Popular brands", "Specifications").
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
