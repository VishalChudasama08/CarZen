import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/pages/account_pages.dart' show reportStatusLabel, reportTone, transactionTone;
import 'package:carzen_flutter/pages/car_details_screen.dart' show StarRating;
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/admin_listing_service.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/report_service.dart';
import 'package:carzen_flutter/services/review_service.dart';
import 'package:carzen_flutter/services/transaction_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/admin_widgets.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';

StatusTone listingTone(ListingStatus s) => switch (s) {
      ListingStatus.active || ListingStatus.approved => StatusTone.success,
      ListingStatus.pendingReview => StatusTone.warning,
      ListingStatus.reserved || ListingStatus.sold => StatusTone.info,
      ListingStatus.rejected || ListingStatus.suspended || ListingStatus.removed => StatusTone.danger,
      _ => StatusTone.neutral,
    };

// ---------------------------------------------------------------------------
// Listings
// ---------------------------------------------------------------------------

class AdminListingsScreen extends StatefulWidget {
  const AdminListingsScreen({super.key});

  @override
  State<AdminListingsScreen> createState() => _AdminListingsScreenState();
}

class _AdminListingsScreenState extends State<AdminListingsScreen> {
  final _service = AdminListingService();
  ListingStatus? _status;
  final Set<int> _busy = {};

  /// Listings only carry the seller's id; names come from the user list.
  Map<int, String> _sellerNames = const {};

  @override
  void initState() {
    super.initState();
    ProfileService().adminListUsers().then((users) {
      if (mounted) setState(() => _sellerNames = {for (final u in users) u.id: u.fullName.isEmpty ? '@${u.username}' : u.fullName});
    }).catchError((Object _) {});
  }
  late final _paged = PagedController<Listing>(
    limit: 12,
    fetch: (p, l) => _service.list(page: p, limit: l, status: _status?.apiValue),
  )..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  Future<void> _act(Listing l, {required String title, required String message, required String confirm, required Future<void> Function() run, required String done, bool destructive = false}) async {
    final ok = await confirmAction(context, title: title, message: message, confirmLabel: confirm, destructive: destructive);
    if (!ok) return;
    setState(() => _busy.add(l.id));
    try {
      await run();
      if (!mounted) return;
      showAppSnack(context, done);
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(l.id));
    }
  }

  List<Widget> _actions(Listing l) {
    if (_busy.contains(l.id)) return const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))];
    final s = l.listingStatus;
    final canApprove = s == ListingStatus.pendingReview || s == ListingStatus.rejected || s == ListingStatus.suspended;
    final canReject = s == ListingStatus.pendingReview;
    final canSuspend = s == ListingStatus.active || s == ListingStatus.approved || s == ListingStatus.reserved;
    return [
      if (canApprove)
        RowAction('Approve', primary: true, onPressed: () => _act(l,
            title: 'Approve "${l.title}"?',
            message: 'The listing is marked as approved.',
            confirm: 'Approve',
            run: () => _service.approve(l.id),
            done: 'Listing approved')),
      if (canReject)
        RowAction('Reject', destructive: true, onPressed: () => _act(l,
            title: 'Reject "${l.title}"?',
            message: 'The listing will not be shown to buyers.',
            confirm: 'Reject',
            destructive: true,
            run: () => _service.reject(l.id),
            done: 'Listing rejected')),
      if (canSuspend)
        RowAction('Suspend', destructive: true, onPressed: () => _act(l,
            title: 'Suspend "${l.title}"?',
            message: 'Buyers will no longer see it. You can approve it again later.',
            confirm: 'Suspend',
            destructive: true,
            run: () => _service.suspend(l.id),
            done: 'Listing suspended')),
      PopupMenuButton<String>(
        tooltip: 'More',
        onSelected: (v) {
          if (v == 'car') Navigator.of(context).pushNamed(AppRoutes.adminCar(l.carId));
          if (v == 'public') Navigator.of(context).pushNamed(AppRoutes.carDetails(l.id, l.title));
          if (v == 'seller') Navigator.of(context).pushNamed(AppRoutes.adminUser(l.sellerId));
          if (v == 'remove') {
            _act(l,
                title: 'Remove "${l.title}"?',
                message: 'The listing is taken off CarZen. This cannot be undone from here.',
                confirm: 'Remove listing',
                destructive: true,
                run: () => _service.delete(l.id),
                done: 'Listing removed');
          }
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'car', child: Text('Open car record')),
          if (l.listingStatus == ListingStatus.active) const PopupMenuItem(value: 'public', child: Text('View public page')),
          const PopupMenuItem(value: 'seller', child: Text('View seller')),
          if (l.listingStatus != ListingStatus.removed)
            const PopupMenuItem(value: 'remove', child: Text('Remove listing', style: TextStyle(color: AppColors.danger))),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      section: NavSection.adminListings,
      title: 'Listings',
      subtitle: 'Every car offered for sale. Suspend listings that break the rules.',
      onRefresh: _paged.refresh,
      filters: SegmentFilter<ListingStatus?>(
        options: const [
          (null, 'All'),
          (ListingStatus.active, 'Live'),
          (ListingStatus.pendingReview, 'In review'),
          (ListingStatus.draft, 'Not published'),
          (ListingStatus.reserved, 'Reserved'),
          (ListingStatus.sold, 'Sold'),
          (ListingStatus.suspended, 'Suspended'),
          (ListingStatus.rejected, 'Rejected'),
        ],
        selected: _status,
        onChanged: (v) {
          setState(() => _status = v);
          _paged.reset();
        },
      ),
      child: AdminPagedTable<Listing>(
        controller: _paged,
        itemLabel: 'listings',
        empty: const EmptyStateView(compact: true, icon: Icons.storefront_outlined, title: 'No listings', message: 'Nothing matches this filter.'),
        builder: (context, items) => AdminTable<Listing>(
          items: items,
          actionsWidth: 230,
          cardTitle: (l) => Text(l.title),
          cardBadge: (l) => StatusPill(label: l.listingStatus.label, tone: listingTone(l.listingStatus)),
          columns: [
            AdminColumn('Listing', (l) => StackedCell(l.title, 'Listing #${l.id}  |  Car #${l.carId}'), flex: 5, showInCard: false),
            AdminColumn('Price', (l) => Text(formatLakh(l.askingPrice), style: AppText.figures(14)), flex: 2),
            AdminColumn('Seller', (l) => TextCell(_sellerNames[l.sellerId] ?? 'User #${l.sellerId}'), flex: 2),
            AdminColumn('Views', (l) => Text(formatCount(l.viewsCount ?? 0), style: AppText.figures(14)), flex: 1),
            AdminColumn('Status', (l) => StatusPill(label: l.listingStatus.label, tone: listingTone(l.listingStatus)), flex: 2, showInCard: false),
          ],
          actions: _actions,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Transactions
// ---------------------------------------------------------------------------

class AdminTransactionsScreen extends StatefulWidget {
  const AdminTransactionsScreen({super.key});

  @override
  State<AdminTransactionsScreen> createState() => _AdminTransactionsScreenState();
}

class _AdminTransactionsScreenState extends State<AdminTransactionsScreen> {
  final _service = TransactionService();
  String? _status;
  late final _paged = PagedController<TransactionRecord>(
    limit: 15,
    fetch: (p, l) => _service.adminList(page: p, limit: l, status: _status),
  )..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      section: NavSection.adminTransactions,
      title: 'Transactions',
      subtitle: 'Completed car sales and their payments. Records are created when an order is paid.',
      onRefresh: _paged.refresh,
      filters: SegmentFilter<String?>(
        options: const [(null, 'All'), ('completed', 'Completed'), ('initiated', 'Initiated'), ('cancelled', 'Cancelled'), ('failed', 'Failed')],
        selected: _status,
        onChanged: (v) {
          setState(() => _status = v);
          _paged.reset();
        },
      ),
      child: AdminPagedTable<TransactionRecord>(
        controller: _paged,
        itemLabel: 'transactions',
        empty: const EmptyStateView(compact: true, icon: Icons.account_balance_wallet_outlined, title: 'No transactions', message: 'Sales appear here once an order is paid.'),
        builder: (context, items) => AdminTable<TransactionRecord>(
          items: items,
          cardTitle: (t) => Text(t.listingTitle ?? 'Car #${t.carId}'),
          cardBadge: (t) => Text(formatLakh(t.finalPrice), style: AppText.price(15)),
          columns: [
            AdminColumn('Sale', (t) => StackedCell(t.listingTitle ?? 'Car #${t.carId}', 'Transaction #${t.id}  |  Order #${t.orderId}'), flex: 5, showInCard: false),
            AdminColumn('Buyer', (t) => TextCell(t.buyer?.displayName ?? 'User #${t.buyerId}'), flex: 2),
            AdminColumn('Seller', (t) => TextCell(t.seller?.displayName ?? 'User #${t.sellerId}'), flex: 2),
            AdminColumn('Amount', (t) => Text(formatInr(t.finalPrice), style: AppText.figures(14)), flex: 2, alignEnd: true, showInCard: false),
            AdminColumn('Paid by', (t) => TextCell(t.paymentMethod == null ? 'Not recorded' : humanizeStatus(t.paymentMethod!)), flex: 2),
            AdminColumn('Date', (t) => TextCell(formatDate(t.transactionDate ?? t.createdAt)), flex: 2),
            AdminColumn(
              'Status',
              (t) => Wrap(spacing: 6, runSpacing: 4, children: [
                StatusPill(label: humanizeStatus(t.transactionStatus), tone: transactionTone(t.transactionStatus)),
                StatusPill(label: humanizeStatus(t.paymentStatus), tone: t.paymentStatus == 'paid' ? StatusTone.success : StatusTone.warning),
              ]),
              flex: 3,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reviews
// ---------------------------------------------------------------------------

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  final _service = ReviewService();
  bool? _visible;
  final Set<int> _busy = {};
  late final _paged = PagedController<ReviewRecord>(
    limit: 12,
    fetch: (p, l) => _service.adminList(page: p, limit: l, visible: _visible),
  )..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  Future<void> _run(ReviewRecord r, Future<void> Function() action, String done) async {
    setState(() => _busy.add(r.id));
    try {
      await action();
      if (!mounted) return;
      showAppSnack(context, done);
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(r.id));
    }
  }

  String _carName(ReviewRecord r) {
    final c = r.car;
    if (c == null) return r.carId == null ? 'Unknown car' : 'Car #${r.carId}';
    return '${c.manufacturingYear} car #${c.id}${c.registrationNumber == null ? '' : '  |  ${c.registrationNumber}'}';
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      section: NavSection.adminReviews,
      title: 'Reviews',
      subtitle: 'Buyer reviews shown on car pages. Hide anything abusive or off-topic.',
      onRefresh: _paged.refresh,
      filters: SegmentFilter<bool?>(
        options: const [(null, 'All'), (true, 'Shown'), (false, 'Hidden')],
        selected: _visible,
        onChanged: (v) {
          setState(() => _visible = v);
          _paged.reset();
        },
      ),
      child: AdminPagedTable<ReviewRecord>(
        controller: _paged,
        itemLabel: 'reviews',
        empty: const EmptyStateView(compact: true, icon: Icons.reviews_outlined, title: 'No reviews', message: 'Nothing matches this filter.'),
        builder: (context, items) => AdminTable<ReviewRecord>(
          items: items,
          actionsWidth: 170,
          cardTitle: (r) => StarRating(rating: r.rating),
          cardBadge: (r) => StatusPill(label: r.isVisible ? 'Shown' : 'Hidden', tone: r.isVisible ? StatusTone.success : StatusTone.neutral),
          columns: [
            AdminColumn('Rating', (r) => StarRating(rating: r.rating, size: 15), flex: 2, showInCard: false),
            AdminColumn(
              'Review',
              (r) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if ((r.title ?? '').isNotEmpty) Text(r.title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    (r.reviewText ?? '').isEmpty ? 'No written review' : r.reviewText!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                  ),
                ],
              ),
              flex: 6,
            ),
            AdminColumn('By', (r) => TextCell(r.user?.displayName ?? 'User #${r.userId}'), flex: 2),
            AdminColumn('Car', (r) => TextCell(_carName(r)), flex: 3),
            AdminColumn('Date', (r) => TextCell(formatDate(r.createdAt)), flex: 2),
            AdminColumn('Status', (r) => StatusPill(label: r.isVisible ? 'Shown' : 'Hidden', tone: r.isVisible ? StatusTone.success : StatusTone.neutral), flex: 2, showInCard: false),
          ],
          actions: (r) => _busy.contains(r.id)
              ? const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))]
              : [
                  RowAction(r.isVisible ? 'Hide' : 'Show', onPressed: () => _run(r, () => _service.adminSetVisible(r.id, !r.isVisible), r.isVisible ? 'Review hidden' : 'Review shown again')),
                  RowAction('Delete', destructive: true, onPressed: () async {
                    final ok = await confirmAction(context,
                        title: 'Delete this review?', message: 'It is removed for good. Hiding keeps it on record instead.', confirmLabel: 'Delete', destructive: true);
                    if (ok) await _run(r, () => _service.adminDelete(r.id), 'Review deleted');
                  }),
                ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reports
// ---------------------------------------------------------------------------

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final _service = ReportService();
  String? _status = 'pending';
  final Set<int> _busy = {};
  late final _paged = PagedController<ReportRecord>(
    limit: 12,
    fetch: (p, l) => _service.adminList(page: p, limit: l, status: _status),
  )..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  Future<void> _update(ReportRecord r) async {
    final result = await showDialog<(String, String?)>(context: context, builder: (_) => _ReportStatusDialog(report: r));
    if (result == null) return;
    setState(() => _busy.add(r.id));
    try {
      await _service.adminSetStatus(r.id, result.$1, note: result.$2);
      if (!mounted) return;
      showAppSnack(context, 'Report #${r.id}: ${reportStatusLabel(result.$1).toLowerCase()}. The reporter has been notified.');
      await _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy.remove(r.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminPage(
      section: NavSection.adminReports,
      title: 'Reports',
      subtitle: 'Listings that buyers flagged. Review each one and record what you did.',
      onRefresh: _paged.refresh,
      filters: SegmentFilter<String?>(
        options: const [('pending', 'New'), ('under_review', 'Being reviewed'), ('resolved', 'Action taken'), ('rejected', 'No action'), (null, 'All')],
        selected: _status,
        onChanged: (v) {
          setState(() => _status = v);
          _paged.reset();
        },
      ),
      child: AdminPagedTable<ReportRecord>(
        controller: _paged,
        itemLabel: 'reports',
        empty: EmptyStateView(
          compact: true,
          icon: Icons.flag_outlined,
          title: _status == 'pending' ? 'No new reports' : 'No reports',
          message: _status == 'pending' ? 'Buyers have not flagged anything new.' : 'Nothing matches this filter.',
        ),
        builder: (context, items) => AdminTable<ReportRecord>(
          items: items,
          actionsWidth: 190,
          cardTitle: (r) => Text(r.reason.label),
          cardBadge: (r) => StatusPill(label: reportStatusLabel(r.status), tone: reportTone(r.status)),
          columns: [
            AdminColumn('Reason', (r) => StackedCell(r.reason.label, 'Report #${r.id}'), flex: 3, showInCard: false),
            AdminColumn('Details', (r) => TextCell((r.description ?? '').isEmpty ? 'No details given' : r.description!), flex: 5),
            AdminColumn('Listing', (r) => TextCell(r.listingId == null ? (r.carId == null ? 'Not linked' : 'Car #${r.carId}') : 'Listing #${r.listingId}'), flex: 2),
            AdminColumn('Reported', (r) => TextCell(formatDate(r.createdAt)), flex: 2),
            AdminColumn('Status', (r) => StatusPill(label: reportStatusLabel(r.status), tone: reportTone(r.status)), flex: 2, showInCard: false),
          ],
          actions: (r) => _busy.contains(r.id)
              ? const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))]
              : [
                  RowAction('Update', primary: r.status == 'pending', onPressed: () => _update(r)),
                  if (r.listingId != null)
                    RowAction('Open', onPressed: () => Navigator.of(context).pushNamed(AppRoutes.carDetails(r.listingId!))),
                  if (r.listingId == null && r.carId != null)
                    RowAction('Open', onPressed: () => Navigator.of(context).pushNamed(AppRoutes.adminCar(r.carId!))),
                ],
        ),
      ),
    );
  }
}

class _ReportStatusDialog extends StatefulWidget {
  final ReportRecord report;
  const _ReportStatusDialog({required this.report});

  @override
  State<_ReportStatusDialog> createState() => _ReportStatusDialogState();
}

class _ReportStatusDialogState extends State<_ReportStatusDialog> {
  late String _status = widget.report.status == 'pending' ? 'under_review' : widget.report.status;
  late final _note = TextEditingController(text: widget.report.adminNote);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Update report #${widget.report.id}'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 320, maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${widget.report.reason.label}${(widget.report.description ?? '').isEmpty ? '' : ': ${widget.report.description}'}',
                  style: const TextStyle(color: AppColors.textSecondary, height: 1.45)),
              const SizedBox(height: 12),
              RadioGroup<String>(
                groupValue: _status,
                onChanged: (v) => setState(() => _status = v ?? _status),
                child: Column(
                  children: [
                    for (final s in const ['under_review', 'resolved', 'rejected', 'pending'])
                      RadioListTile<String>(contentPadding: EdgeInsets.zero, dense: true, value: s, title: Text(reportStatusLabel(s))),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _note,
                maxLines: 3,
                maxLength: 5000,
                decoration: const InputDecoration(labelText: 'Note for the reporter (optional)', alignLabelWithHint: true),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop((_status, _note.text.trim().isEmpty ? null : _note.text.trim())),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
