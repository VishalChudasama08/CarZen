import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';

/// Page controls driven by the backend's real `page / limit / total /
/// total_pages` metadata.
///
/// * wide screens: "Showing 13–24 of 56" plus Previous, numbered pages, Next
/// * phones: big Previous / Next buttons around a "Page 2 of 5" button that
///   opens a page picker
///
/// Renders nothing when everything fits on one page.
class PaginationBar extends StatelessWidget {
  final PaginationMeta? meta;
  final ValueChanged<int> onPageChanged;
  final bool busy;
  final String itemLabel;

  const PaginationBar({
    super.key,
    required this.meta,
    required this.onPageChanged,
    this.busy = false,
    this.itemLabel = 'results',
  });

  @override
  Widget build(BuildContext context) {
    final m = meta;
    if (m == null || m.totalPages <= 1) return const SizedBox.shrink();
    return Breakpoints.isCompact(context) ? _compact(context, m) : _wide(context, m);
  }

  Widget _compact(BuildContext context, PaginationMeta m) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: busy || m.page <= 1 ? null : () => onPageChanged(m.page - 1),
            icon: const Icon(Icons.chevron_left_rounded),
            label: const Text('Prev'),
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: busy ? null : () => _pickPage(context, m),
          child: Text('Page ${m.page} of ${m.totalPages}'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: busy || m.page >= m.totalPages ? null : () => onPageChanged(m.page + 1),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [Text('Next'), Icon(Icons.chevron_right_rounded)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _wide(BuildContext context, PaginationMeta m) {
    final first = (m.page - 1) * m.limit + 1;
    final last = (m.page * m.limit) > m.total ? m.total : m.page * m.limit;
    final pages = _visiblePages(m.page, m.totalPages);
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 10,
      spacing: 16,
      children: [
        Text(
          'Showing ${formatCount(first)}–${formatCount(last)} of ${formatCount(m.total)} $itemLabel',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton.outlined(
              tooltip: 'Previous page',
              onPressed: busy || m.page <= 1 ? null : () => onPageChanged(m.page - 1),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            const SizedBox(width: 6),
            for (final p in pages)
              if (p == null)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  child: Text('…', style: TextStyle(color: AppColors.textSecondary)),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _PageButton(
                    page: p,
                    selected: p == m.page,
                    onTap: busy || p == m.page ? null : () => onPageChanged(p),
                  ),
                ),
            const SizedBox(width: 6),
            IconButton.outlined(
              tooltip: 'Next page',
              onPressed: busy || m.page >= m.totalPages ? null : () => onPageChanged(m.page + 1),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
      ],
    );
  }

  /// 1 … 4 5 6 … 20 — `null` stands for an ellipsis.
  static List<int?> _visiblePages(int current, int total) {
    if (total <= 7) return [for (var i = 1; i <= total; i++) i];
    final pages = <int?>[1];
    final start = (current - 1).clamp(2, total - 1);
    final end = (current + 1).clamp(2, total - 1);
    if (start > 2) pages.add(null);
    for (var i = start; i <= end; i++) {
      pages.add(i);
    }
    if (end < total - 1) pages.add(null);
    pages.add(total);
    return pages;
  }

  void _pickPage(BuildContext context, PaginationMeta m) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Go to page', style: Theme.of(sheetContext).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text('${formatCount(m.total)} $itemLabel in ${m.totalPages} pages',
                  style: Theme.of(sheetContext).textTheme.bodySmall),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.45),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var p = 1; p <= m.totalPages; p++)
                        ChoiceChip(
                          label: Text('$p'),
                          selected: p == m.page,
                          showCheckmark: false,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: p == m.page ? Colors.white : AppColors.textPrimary,
                          ),
                          onSelected: (_) {
                            Navigator.of(sheetContext).pop();
                            if (p != m.page) onPageChanged(p);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final int page;
  final bool selected;
  final VoidCallback? onTap;

  const _PageButton({required this.page, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.sm),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.sm),
            border: Border.all(color: selected ? AppColors.primary : AppColors.divider),
          ),
          child: Text(
            '$page',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: selected ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
