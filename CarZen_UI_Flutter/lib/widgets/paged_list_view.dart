import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// A complete scrolling page for one server-paginated list: header, optional
/// filters, skeletons while loading, error / empty states, the items, and
/// the [PaginationBar]. Used by every list screen so loading, empty, error,
/// retry and paging behave the same everywhere.
class PagedListView<T> extends StatelessWidget {
  final PagedController<T> controller;
  final Widget header;
  final Widget? filters;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final String itemLabel;
  final double maxWidth;
  final double skeletonHeight;

  /// Shown when the list is legitimately empty. Build it with [EmptyStateView].
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
    this.maxWidth = 900,
    this.skeletonHeight = 110,
    this.errorFallback = 'Could not load this list.',
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: PageContainer(
            maxWidth: maxWidth,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                if (filters != null) ...[const SizedBox(height: AppSpacing.lg), filters!],
                const SizedBox(height: AppSpacing.lg),
                if (controller.loading && controller.hasData)
                  const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator(minHeight: 3)),
                _body(context),
                const SizedBox(height: AppSpacing.xl),
                PaginationBar(
                  meta: controller.meta,
                  busy: controller.loading,
                  itemLabel: itemLabel,
                  onPageChanged: controller.goTo,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (controller.isFirstLoad) {
      return Column(children: [
        for (var i = 0; i < 3; i++)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: SkeletonBox(height: skeletonHeight, radius: AppRadii.lg)),
      ]);
    }
    if (controller.error != null && !controller.hasData) {
      return SizedBox(
        height: 360,
        child: ApiErrorView(error: controller.error!, onRetry: controller.refresh, fallback: errorFallback),
      );
    }
    if (!controller.hasData) return SizedBox(height: 360, child: empty);
    return Column(
      children: [
        if (controller.error != null) InlineError('Could not refresh this page. Pull down to try again.'),
        for (final item in controller.items)
          Padding(padding: const EdgeInsets.only(bottom: 12), child: itemBuilder(context, item)),
      ],
    );
  }
}
