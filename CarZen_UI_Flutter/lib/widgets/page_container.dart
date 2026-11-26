import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:flutter/material.dart';

/// Centres page content in a readable column on large screens and adds the
/// right gutter for the current width. Use as the child of a scroll view.
class PageContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double verticalPadding;
  final double? bottomPadding;

  const PageContainer({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.verticalPadding = AppSpacing.xl,
    this.bottomPadding,
  });

  /// Horizontal padding that centres sliver content in the same column
  /// [PageContainer] would use (for pages built from slivers).
  static EdgeInsets sidePadding(double width, {double maxWidth = Breakpoints.maxContentWidth}) {
    final gutter = AppSpacing.pageGutter(width);
    final extra = width > maxWidth + gutter * 2 ? (width - maxWidth - gutter * 2) / 2 : 0.0;
    return EdgeInsets.symmetric(horizontal: gutter + extra);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : MediaQuery.sizeOf(context).width;
        final gutter = AppSpacing.pageGutter(width);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
            child: Padding(
              padding: EdgeInsets.fromLTRB(gutter, verticalPadding, gutter, bottomPadding ?? verticalPadding + 24),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// A scrollable page body: [PageContainer] inside a scroll view with an
/// optional pull-to-refresh.
class PageScroll extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Future<void> Function()? onRefresh;
  final double verticalPadding;
  final ScrollController? controller;

  const PageScroll({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.maxContentWidth,
    this.onRefresh,
    this.verticalPadding = AppSpacing.xl,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final scroll = SingleChildScrollView(
      controller: controller,
      physics: const AlwaysScrollableScrollPhysics(),
      child: PageContainer(maxWidth: maxWidth, verticalPadding: verticalPadding, child: child),
    );
    if (onRefresh == null) return scroll;
    return RefreshIndicator(onRefresh: onRefresh!, child: scroll);
  }
}

/// Page title block: heading, one supporting sentence and optional actions.
/// Actions wrap under the title on phones.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final IconData? icon;
  final Widget? leading;

  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const [], this.icon, this.leading});

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: compact ? AppText.heading(23) : Theme.of(context).textTheme.headlineLarge),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(subtitle!, style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary)),
          ),
        ],
      ],
    );
    Widget lead = heading;
    if (leading != null || icon != null) {
      lead = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading ??
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(color: AppColors.chromeTint, borderRadius: BorderRadius.circular(AppRadii.md)),
                child: Icon(icon, color: AppColors.chrome),
              ),
          Expanded(child: heading),
        ],
      );
    }
    if (actions.isEmpty) return lead;
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [lead, const SizedBox(height: AppSpacing.lg), Wrap(spacing: 10, runSpacing: 10, children: actions)],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: lead),
        const SizedBox(width: AppSpacing.lg),
        Wrap(spacing: 10, runSpacing: 10, children: actions),
      ],
    );
  }
}

/// Section heading inside a page ("Specifications", "Recent orders").
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final double bottom;

  const SectionTitle(this.title, {super.key, this.subtitle, this.trailing, this.bottom = AppSpacing.md});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(header: true, child: Text(title, style: AppText.heading(18))),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45)),
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

/// Lays children out in an even grid whose column count follows the space
/// available ([minTileWidth]); every tile in a row shares the same width.
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double minTileWidth;
  final int maxColumns;
  final double spacing;
  final double runSpacing;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minTileWidth = 260,
    this.maxColumns = 4,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = ((constraints.maxWidth + spacing) / (minTileWidth + spacing)).floor().clamp(1, maxColumns);
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final rows = <Widget>[];
        for (var i = 0; i < children.length; i += columns) {
          final rowChildren = <Widget>[];
          for (var j = 0; j < columns; j++) {
            if (j > 0) rowChildren.add(SizedBox(width: spacing));
            final index = i + j;
            rowChildren.add(SizedBox(width: width, child: index < children.length ? children[index] : null));
          }
          if (rows.isNotEmpty) rows.add(SizedBox(height: runSpacing));
          rows.add(IntrinsicHeight(
            child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: rowChildren),
          ));
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }
}
