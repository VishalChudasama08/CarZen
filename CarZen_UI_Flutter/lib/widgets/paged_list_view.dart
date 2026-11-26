import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// A complete scrolling page for one server-paginated list: header, optional
/// filters, skeletons while loading, error / empty states, the items, and
/// the [PaginationBar].
class PagedListView<T> extends StatelessWidget {
  final PagedController<T> controller;
  final Widget header;
  final Widget? filters;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String itemLabel;
  final double maxWidth;
  final double skeletonHeight;
  final Widget empty;
  final String errorFallback;

  const PagedListView({
    super.key,
    required this.controller,
    required this.header,
    required this.itemBuilder,
    required this.empty,
    this.filters,
    this.itemLabel = 'results',
    this.maxWidth = 960,
    this.skeletonHeight = 110,
    this.errorFallback = 'This list could not be loaded.',
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: PageContainer(
          maxWidth: maxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              if (filters != null) ...[const SizedBox(height: AppSpacing.lg), filters!],
              const SizedBox(height: AppSpacing.lg),
              PagedBody<T>(
                controller: controller,
                itemBuilder: itemBuilder,
                empty: empty,
                itemLabel: itemLabel,
                skeletonHeight: skeletonHeight,
                errorFallback: errorFallback,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The list part of a paged list (states + items + pagination), for pages
/// that build their own surrounding layout.
class PagedBody<T> extends StatelessWidget {
  final PagedController<T> controller;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Widget empty;
  final String itemLabel;
  final double skeletonHeight;
  final String errorFallback;
  final double spacing;

  /// Lay items out in a grid of at least this tile width (null = a list).
  final double? gridMinTileWidth;

  const PagedBody({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.empty,
    this.itemLabel = 'results',
    this.skeletonHeight = 110,
    this.errorFallback = 'This list could not be loaded.',
    this.spacing = 12,
    this.gridMinTileWidth,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isFirstLoad || (!controller.initialized && !controller.hasData)) {
          return Column(children: [
            for (var i = 0; i < 3; i++)
              Padding(padding: EdgeInsets.only(bottom: spacing), child: SkeletonBox(height: skeletonHeight, radius: AppRadii.lg)),
          ]);
        }
        if (controller.error != null && !controller.hasData) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.divider),
            ),
            child: ApiErrorView(error: controller.error!, onRetry: controller.refresh, fallback: errorFallback, compact: true),
          );
        }
        if (!controller.hasData) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(color: AppColors.divider),
            ),
            child: empty,
          );
        }
        final items = [for (final item in controller.items) itemBuilder(context, item)];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.loading) const Padding(padding: EdgeInsets.only(bottom: 10), child: LinearProgressIndicator(minHeight: 2)),
            if (controller.error != null) const InlineError('This page could not be refreshed. Pull down or try again.'),
            if (gridMinTileWidth != null)
              ResponsiveGrid(minTileWidth: gridMinTileWidth!, spacing: spacing, runSpacing: spacing, maxColumns: 3, children: items)
            else
              for (final w in items) Padding(padding: EdgeInsets.only(bottom: spacing), child: w),
            const SizedBox(height: 16),
            PaginationBar(meta: controller.meta, busy: controller.loading, itemLabel: itemLabel, onPageChanged: controller.goTo),
          ],
        );
      },
    );
  }
}

/// Segmented filter used above lists ("All / Open / Closed").
class SegmentFilter<T> extends StatelessWidget {
  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const SegmentFilter({super.key, required this.options, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final o in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(o.$2),
                selected: o.$1 == selected,
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: o.$1 == selected ? Colors.white : AppColors.textPrimary,
                ),
                onSelected: (_) => onChanged(o.$1),
              ),
            ),
        ],
      ),
    );
  }
}
