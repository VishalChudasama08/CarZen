import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Group name shown in the admin top bar ("Marketplace", "Workshop"...).
String adminGroupOf(NavSection section) {
  for (final g in adminNavGroups) {
    if (g.items.any((d) => d.section == section)) return g.title;
  }
  return 'Admin';
}

/// Standard admin page: console chrome, a page title with actions, an
/// optional filter row and the content.
class AdminPage extends StatelessWidget {
  final NavSection section;
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? filters;
  final Widget child;
  final Future<void> Function()? onRefresh;
  final String? fallbackRoute;
  final double maxWidth;
  final Widget? floatingActionButton;

  const AdminPage({
    super.key,
    required this.section,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions = const [],
    this.filters,
    this.onRefresh,
    this.fallbackRoute,
    this.maxWidth = 1240,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    return AppScaffold(
      section: section,
      title: fallbackRoute != null ? title : adminGroupOf(section),
      fallbackRoute: fallbackRoute,
      showBackButton: fallbackRoute != null,
      floatingActionButton: floatingActionButton,
      body: PageScroll(
        maxWidth: maxWidth,
        verticalPadding: compact ? 16 : 28,
        onRefresh: onRefresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHeader(title: title, subtitle: subtitle, actions: actions),
            if (filters != null) ...[const SizedBox(height: 18), filters!],
            SizedBox(height: compact ? 16 : 20),
            child,
          ],
        ),
      ),
    );
  }
}

/// One column of an [AdminTable].
class AdminColumn<T> {
  final String label;
  final int flex;
  final Widget Function(T item) cell;
  final bool alignEnd;

  /// Hide from the stacked card layout (e.g. when already in the title).
  final bool showInCard;

  const AdminColumn(this.label, this.cell, {this.flex = 2, this.alignEnd = false, this.showInCard = true});
}

/// Data table for wide screens that turns into stacked cards on narrow
/// ones. Every row can open a detail view and carry its own actions.
class AdminTable<T> extends StatelessWidget {
  final List<T> items;
  final List<AdminColumn<T>> columns;
  final Widget Function(T item) cardTitle;
  final Widget Function(T item)? cardBadge;
  final List<Widget> Function(T item)? actions;
  final void Function(T item)? onTap;
  final double actionsWidth;
  final double tableBreakpoint;

  const AdminTable({
    super.key,
    required this.items,
    required this.columns,
    required this.cardTitle,
    this.cardBadge,
    this.actions,
    this.onTap,
    this.actionsWidth = 150,
    this.tableBreakpoint = 860,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tableBreakpoint) return _table(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items) Padding(padding: const EdgeInsets.only(bottom: 10), child: _card(context, item)),
          ],
        );
      },
    );
  }

  Widget _table(BuildContext context) {
    const headerStyle = TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondary);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.surfaceMuted,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              children: [
                for (final c in columns)
                  Expanded(
                    flex: c.flex,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(c.label, style: headerStyle, textAlign: c.alignEnd ? TextAlign.end : TextAlign.start),
                    ),
                  ),
                if (actions != null) SizedBox(width: actionsWidth, child: const Text('Actions', style: headerStyle, textAlign: TextAlign.end)),
              ],
            ),
          ),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            InkWell(
              onTap: onTap == null ? null : () => onTap!(items[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    for (final c in columns)
                      Expanded(
                        flex: c.flex,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Align(alignment: c.alignEnd ? Alignment.centerRight : Alignment.centerLeft, child: c.cell(items[i])),
                        ),
                      ),
                    if (actions != null)
                      SizedBox(
                        width: actionsWidth,
                        child: Wrap(alignment: WrapAlignment.end, spacing: 4, runSpacing: 4, children: actions!(items[i])),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _card(BuildContext context, T item) {
    final cardColumns = columns.where((c) => c.showInCard).toList();
    final itemActions = actions?.call(item) ?? const <Widget>[];
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.md),
        onTap: onTap == null ? null : () => onTap!(item),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: DefaultTextStyle.merge(style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15), child: cardTitle(item))),
                  if (cardBadge != null) ...[const SizedBox(width: 8), cardBadge!(item)],
                ],
              ),
              const SizedBox(height: 8),
              for (final c in cardColumns)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 110, child: Text(c.label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
                      Expanded(child: Align(alignment: Alignment.centerLeft, child: c.cell(item))),
                    ],
                  ),
                ),
              if (itemActions.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: itemActions),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Loading / error / empty / data states around a paged [AdminTable].
class AdminPagedTable<T> extends StatelessWidget {
  final PagedController<T> controller;
  final Widget Function(BuildContext context, List<T> items) builder;
  final Widget empty;
  final String itemLabel;

  const AdminPagedTable({super.key, required this.controller, required this.builder, required this.empty, this.itemLabel = 'results'});

  @override
  Widget build(BuildContext context) {
    final frame = BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      border: Border.all(color: AppColors.divider),
    );
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        if (controller.isFirstLoad || (!controller.initialized && !controller.hasData)) {
          return Container(
            decoration: frame,
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                SkeletonLine(),
                SizedBox(height: 14),
                SkeletonLine(),
                SizedBox(height: 14),
                SkeletonLine(),
                SizedBox(height: 14),
                SkeletonLine(),
              ],
            ),
          );
        }
        if (controller.error != null && !controller.hasData) {
          return Container(decoration: frame, child: ApiErrorView(error: controller.error!, onRetry: controller.refresh, compact: true));
        }
        if (!controller.hasData) return Container(decoration: frame, child: empty);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (controller.loading) const Padding(padding: EdgeInsets.only(bottom: 8), child: LinearProgressIndicator(minHeight: 2)),
            if (controller.error != null) const InlineError('This page could not be refreshed. Try again.'),
            builder(context, controller.items),
            const SizedBox(height: 16),
            PaginationBar(meta: controller.meta, busy: controller.loading, itemLabel: itemLabel, onPageChanged: controller.goTo),
          ],
        );
      },
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({super.key});

  @override
  Widget build(BuildContext context) => Container(
        height: 18,
        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(AppRadii.xs)),
      );
}

/// Two-line cell: a strong first line and a quiet second line.
class StackedCell extends StatelessWidget {
  final String primary;
  final String? secondary;
  const StackedCell(this.primary, [this.secondary, Key? key]) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(primary, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        if (secondary != null && secondary!.isNotEmpty)
          Text(secondary!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
      ],
    );
  }
}

/// Text cell with ellipsis.
class TextCell extends StatelessWidget {
  final String text;
  final TextStyle? style;
  const TextCell(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) =>
      Text(text, maxLines: 2, overflow: TextOverflow.ellipsis, style: style ?? const TextStyle(fontSize: 14));
}

/// Compact action button for table rows.
class RowAction extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool destructive;

  const RowAction(this.label, {super.key, required this.onPressed, this.primary = false, this.destructive = false});

  @override
  Widget build(BuildContext context) {
    const size = Size(0, 34);
    const pad = EdgeInsets.symmetric(horizontal: 12);
    if (primary) {
      return FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(minimumSize: size, padding: pad, textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: size,
        padding: pad,
        foregroundColor: destructive ? AppColors.danger : AppColors.ink,
        side: BorderSide(color: destructive ? AppColors.danger.withValues(alpha: 0.5) : AppColors.lineStrong),
        textStyle: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
      ),
      child: Text(label),
    );
  }
}

/// Filter row: segmented status chips plus optional search and extras.
class AdminFilterBar extends StatelessWidget {
  final List<Widget> children;
  const AdminFilterBar({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Wrap(spacing: 12, runSpacing: 12, crossAxisAlignment: WrapCrossAlignment.center, children: children);
}

/// Search box for admin lists; submits on Enter or the search button.
class AdminSearchField extends StatefulWidget {
  final String hint;
  final String initial;
  final ValueChanged<String> onSubmitted;
  final double width;

  const AdminSearchField({super.key, required this.hint, required this.onSubmitted, this.initial = '', this.width = 300});

  @override
  State<AdminSearchField> createState() => _AdminSearchFieldState();
}

class _AdminSearchFieldState extends State<AdminSearchField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.isCompact(context) ? double.infinity : widget.width;
    return SizedBox(
      width: width,
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (v) => widget.onSubmitted(v.trim()),
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hint,
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Clear search',
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () {
                      _controller.clear();
                      widget.onSubmitted('');
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

/// Asks for a short text (a reason or a note). Returns null when cancelled.
Future<String?> showReasonDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String confirmLabel,
  String? message,
  String? hint,
  bool required = true,
  int minLength = 3,
  int maxLength = 500,
  bool destructive = false,
}) async {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 460),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (message != null) ...[Text(message, style: const TextStyle(height: 1.45)), const SizedBox(height: 14)],
              TextFormField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                maxLength: maxLength,
                decoration: InputDecoration(labelText: required ? label : '$label (optional)', hintText: hint, alignLabelWithHint: true),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (!required && t.isEmpty) return null;
                  if (t.length < minLength) return 'Write at least $minLength characters';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: AppColors.danger) : null,
          onPressed: () {
            if (formKey.currentState!.validate()) Navigator.of(ctx).pop(controller.text.trim());
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

/// Big-number tile for the dashboard.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? detail;
  final IconData icon;
  final VoidCallback? onTap;
  final bool attention;

  const StatTile({super.key, required this.label, required this.value, required this.icon, this.detail, this.onTap, this.attention = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: attention ? AppColors.plate : AppColors.divider, width: attention ? 2 : 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 19, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 13.5))),
                  if (onTap != null) const Icon(Icons.chevron_right, size: 20, color: AppColors.textTertiary),
                ],
              ),
              const SizedBox(height: 12),
              Text(value, style: AppText.price(30)),
              if (detail != null) ...[
                const SizedBox(height: 2),
                Text(detail!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
