import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/pages/car_details_screen.dart' show ReviewTile;
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/address_service.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/buyer_service.dart';
import 'package:carzen_flutter/services/contact_service.dart';
import 'package:carzen_flutter/services/report_service.dart';
import 'package:carzen_flutter/services/review_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/services/transaction_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/address_form.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/auth_text_field.dart';
import 'package:carzen_flutter/widgets/form_widgets.dart';
import 'package:carzen_flutter/widgets/listing_card.dart';
import 'package:carzen_flutter/widgets/listing_dialogs.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';

/// Common frame for the smaller account pages.
class _AccountPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final List<Widget> actions;
  final Future<void> Function()? onRefresh;
  final double maxWidth;

  const _AccountPage({required this.title, this.subtitle, required this.child, this.actions = const [], this.onRefresh, this.maxWidth = 860});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.account,
      title: title,
      fallbackRoute: AppRoutes.account,
      showBackButton: true,
      body: PageScroll(
        maxWidth: maxWidth,
        verticalPadding: Breakpoints.isCompact(context) ? 18 : 32,
        onRefresh: onRefresh,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [PageHeader(title: title, subtitle: subtitle, actions: actions), const SizedBox(height: 22), child],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Saved addresses
// ---------------------------------------------------------------------------

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _service = AddressService();
  late Future<List<AddressRecord>> _future = _service.list();

  Future<void> _refresh() async {
    setState(() => _future = _service.list());
    await _future;
  }

  Future<void> _add({bool first = false}) async {
    final saved = await showAddressForm(context, makeDefault: first);
    if (saved != null && mounted) {
      showAppSnack(context, 'Address saved');
      _refresh();
    }
  }

  Future<void> _edit(AddressRecord a) async {
    final saved = await showAddressForm(context, existing: a);
    if (saved != null && mounted) {
      showAppSnack(context, 'Address updated');
      _refresh();
    }
  }

  Future<void> _makeDefault(AddressRecord a) async {
    try {
      await _service.update(a.id,
          addressLine1: a.addressLine1,
          addressLine2: a.addressLine2,
          landmark: a.landmark,
          city: a.city,
          state: a.state,
          postalCode: a.postalCode,
          country: a.country,
          isDefault: true);
      if (mounted) showAppSnack(context, 'Default address updated');
      _refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  Future<void> _delete(AddressRecord a) async {
    final ok = await confirmAction(context, title: 'Delete this address?', message: a.oneLine, confirmLabel: 'Delete', destructive: true);
    if (!ok) return;
    try {
      await _service.delete(a.id);
      if (mounted) showAppSnack(context, 'Address deleted');
      _refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AccountPage(
      title: 'Saved addresses',
      subtitle: 'Used for workshop pickups and for your seller contact details.',
      onRefresh: _refresh,
      actions: [FilledButton.icon(onPressed: _add, icon: const Icon(Icons.add, size: 19), label: const Text('Add address'))],
      child: FutureBuilder<List<AddressRecord>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const SkeletonBox(height: 120, radius: AppRadii.lg);
          if (snap.hasError) return ApiErrorView(error: snap.error!, onRetry: _refresh, compact: true);
          final items = snap.data!;
          if (items.isEmpty) {
            return _Frame(
              child: EmptyStateView(
                compact: true,
                icon: Icons.home_outlined,
                title: 'No saved addresses',
                message: 'Add your home or office so booking a service takes seconds.',
                action: FilledButton(onPressed: () => _add(first: true), child: const Text('Add an address')),
              ),
            );
          }
          return ResponsiveGrid(
            minTileWidth: 320,
            maxColumns: 2,
            children: [
              for (final a in items)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(color: a.isDefault ? AppColors.ink : AppColors.divider, width: a.isDefault ? 1.5 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.place_outlined, size: 20, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Expanded(child: Text(a.city, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5))),
                        if (a.isDefault) const StatusPill(label: 'Default', tone: StatusTone.highlight),
                      ]),
                      const SizedBox(height: 8),
                      Text(a.oneLine, style: const TextStyle(height: 1.5)),
                      const SizedBox(height: 12),
                      Wrap(spacing: 4, children: [
                        TextButton(onPressed: () => _edit(a), child: const Text('Edit')),
                        if (!a.isDefault) TextButton(onPressed: () => _makeDefault(a), child: const Text('Make default')),
                        TextButton(onPressed: () => _delete(a), style: TextButton.styleFrom(foregroundColor: AppColors.danger), child: const Text('Delete')),
                      ]),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  final Widget child;
  const _Frame({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: child,
      );
}

// ---------------------------------------------------------------------------
// Seller contact preferences
// ---------------------------------------------------------------------------

class ContactPreferencesScreen extends StatefulWidget {
  const ContactPreferencesScreen({super.key});

  @override
  State<ContactPreferencesScreen> createState() => _ContactPreferencesScreenState();
}

class _ContactPreferencesScreenState extends State<ContactPreferencesScreen> {
  final _contacts = ContactService();
  final _addresses = AddressService();
  final _whatsapp = TextEditingController();

  late Future<(List<SellerContact>, List<AddressRecord>)> _future = _load();
  int? _addressId;
  PreferredContactMethod _method = PreferredContactMethod.phone;
  ContactVisibility _visibility = ContactVisibility.buyersOnly;
  bool _visible = true;
  bool _saving = false;
  bool _filled = false;

  Future<(List<SellerContact>, List<AddressRecord>)> _load() async {
    final results = await Future.wait([_contacts.list(), _addresses.list()]);
    return (results[0] as List<SellerContact>, results[1] as List<AddressRecord>);
  }

  @override
  void dispose() {
    _whatsapp.dispose();
    super.dispose();
  }

  void _fillFrom(SellerContact? c, List<AddressRecord> addresses) {
    if (_filled) return;
    _filled = true;
    if (c != null) {
      _addressId = c.address?.id;
      _method = c.preferredMethod;
      _visibility = c.visibility;
      _visible = c.isVisible;
      _whatsapp.text = c.whatsappNumber ?? '';
    } else {
      _addressId = addresses.where((a) => a.isDefault).map((a) => a.id).firstOrNull ?? addresses.firstOrNull?.id;
    }
  }

  Future<void> _save(SellerContact? existing) async {
    if (_addressId == null) {
      showAppSnack(context, 'Choose an address first', error: true);
      return;
    }
    if (_method == PreferredContactMethod.whatsapp && _whatsapp.text.trim().isEmpty) {
      showAppSnack(context, 'Add a WhatsApp number to use WhatsApp', error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      if (existing == null) {
        await _contacts.create(addressId: _addressId!, whatsapp: _whatsapp.text, method: _method, visibility: _visibility, isVisible: _visible);
      } else {
        await _contacts.update(existing.id, {
          'address_id': _addressId,
          'whatsapp_number': _whatsapp.text.trim().isEmpty ? null : _whatsapp.text.trim(),
          'preferred_contact_method': _method.apiValue,
          'contact_visibility': _visibility.apiValue,
          'is_visible': _visible,
        });
      }
      if (!mounted) return;
      showAppSnack(context, 'Contact preferences saved');
      _filled = false;
      setState(() => _future = _load());
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionController.instance.user;
    return _AccountPage(
      title: 'Contact preferences',
      subtitle: 'Decide how buyers can reach you about your cars. Messages in CarZen always work.',
      maxWidth: 680,
      child: FutureBuilder<(List<SellerContact>, List<AddressRecord>)>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const SkeletonBox(height: 280, radius: AppRadii.lg);
          if (snap.hasError) return ApiErrorView(error: snap.error!, onRetry: () => setState(() => _future = _load()), compact: true);
          final (contacts, addresses) = snap.data!;
          final existing = contacts.firstOrNull;
          _fillFrom(existing, addresses);
          if (addresses.isEmpty) {
            return _Frame(
              child: EmptyStateView(
                compact: true,
                icon: Icons.home_outlined,
                title: 'Add an address first',
                message: 'Your contact details are linked to an address (only the city is ever shown).',
                action: FilledButton(
                  onPressed: () async {
                    final saved = await showAddressForm(context, makeDefault: true);
                    if (saved != null) {
                      _filled = false;
                      setState(() => _future = _load());
                    }
                  },
                  child: const Text('Add an address'),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormPanel(
                title: 'How to reach you',
                subtitle: [
                  if (user?.email != null) 'Email: ${user!.email}',
                  if (user?.phoneNumber != null) 'Phone: ${user!.phoneNumber}',
                ].join('   '),
                children: [
                  ChoiceField<PreferredContactMethod>(
                    label: 'Preferred way to be contacted',
                    values: PreferredContactMethod.values,
                    selected: _method,
                    labelOf: (v) => v.label,
                    onSelected: (v) => setState(() => _method = v),
                  ),
                  AuthTextField(controller: _whatsapp, label: 'WhatsApp number', keyboardType: TextInputType.phone, hint: '10-digit mobile number'),
                  DropdownField<int>(
                    label: 'Address',
                    required: true,
                    value: _addressId,
                    items: [for (final a in addresses) DropdownMenuItem(value: a.id, child: Text(a.oneLine, overflow: TextOverflow.ellipsis))],
                    onChanged: (v) => setState(() => _addressId = v),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormPanel(
                title: 'Who can see your details',
                children: [
                  RadioGroup<ContactVisibility>(
                    groupValue: _visibility,
                    onChanged: (v) => setState(() => _visibility = v ?? _visibility),
                    child: Column(
                      children: [
                        for (final v in ContactVisibility.values)
                          RadioListTile<ContactVisibility>(
                            contentPadding: EdgeInsets.zero,
                            value: v,
                            title: Text(v.label),
                          ),
                      ],
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _visible,
                    onChanged: (v) => setState(() => _visible = v),
                    title: const Text('Share my contact details'),
                    subtitle: const Text('Turn off to receive messages through CarZen only'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  FilledButton(
                    onPressed: _saving ? null : () => _save(existing),
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                        : const Text('Save preferences'),
                  ),
                  if (existing != null) ...[
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: _saving
                          ? null
                          : () async {
                              final ok = await confirmAction(context,
                                  title: 'Remove your contact details?',
                                  message: 'Buyers will only be able to reach you through CarZen messages.',
                                  confirmLabel: 'Remove',
                                  destructive: true);
                              if (!ok) return;
                              try {
                                await _contacts.delete(existing.id);
                                _filled = false;
                                setState(() => _future = _load());
                              } on ApiException catch (e) {
                                if (context.mounted) showAppSnack(context, e.message, error: true);
                              }
                            },
                      style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      child: const Text('Remove'),
                    ),
                  ],
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// My reviews
// ---------------------------------------------------------------------------

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  final _service = ReviewService();
  late final _paged = PagedController<ReviewRecord>(limit: 10, fetch: (p, l) => _service.mine(page: p, limit: l))..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  Future<void> _edit(ReviewRecord r) async {
    final res = await showReviewDialog(context, carName: 'car', initialRating: r.rating, initialTitle: r.title, initialText: r.reviewText);
    if (res == null) return;
    try {
      await _service.update(r.id, rating: res.rating, title: res.title ?? '', text: res.text ?? '');
      if (mounted) showAppSnack(context, 'Review updated');
      _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  Future<void> _delete(ReviewRecord r) async {
    final ok = await confirmAction(context, title: 'Delete this review?', message: 'It will be removed from the car\'s page.', confirmLabel: 'Delete', destructive: true);
    if (!ok) return;
    try {
      await _service.delete(r.id);
      if (mounted) showAppSnack(context, 'Review deleted');
      _paged.refresh();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AccountPage(
      title: 'My reviews',
      subtitle: 'Reviews you wrote after buying a car.',
      onRefresh: _paged.refresh,
      child: PagedBody<ReviewRecord>(
        controller: _paged,
        itemLabel: 'reviews',
        empty: const EmptyStateView(
          compact: true,
          icon: Icons.star_outline,
          title: 'No reviews yet',
          message: 'After you complete a purchase, you can review it from Orders.',
        ),
        itemBuilder: (context, r) => ReviewTile(
          review: r,
          trailing: PopupMenuButton<String>(
            tooltip: 'Review actions',
            onSelected: (v) => v == 'edit' ? _edit(r) : _delete(r),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: AppColors.danger))),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// My reports
// ---------------------------------------------------------------------------

StatusTone reportTone(String status) => switch (status) {
      'resolved' => StatusTone.success,
      'under_review' => StatusTone.info,
      'rejected' => StatusTone.neutral,
      _ => StatusTone.warning,
    };

String reportStatusLabel(String status) => switch (status) {
      'pending' => 'Received',
      'under_review' => 'Being reviewed',
      'resolved' => 'Action taken',
      'rejected' => 'No action needed',
      _ => humanizeStatus(status),
    };

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _service = ReportService();
  late final _paged = PagedController<ReportRecord>(limit: 10, fetch: (p, l) => _service.mine(page: p, limit: l))..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AccountPage(
      title: 'Listings I reported',
      subtitle: 'Our team reviews every report. Here is where each one stands.',
      onRefresh: _paged.refresh,
      child: PagedBody<ReportRecord>(
        controller: _paged,
        itemLabel: 'reports',
        empty: const EmptyStateView(compact: true, icon: Icons.flag_outlined, title: 'No reports', message: 'If a listing looks wrong, report it from the car\'s page.'),
        itemBuilder: (context, r) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(child: Text(r.reason.label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                StatusPill(label: reportStatusLabel(r.status), tone: reportTone(r.status)),
              ]),
              const SizedBox(height: 4),
              Text(
                ['Report #${r.id}', formatDate(r.createdAt), if (r.listingId != null) 'Listing #${r.listingId}'].join('  |  '),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              if ((r.description ?? '').isNotEmpty) ...[const SizedBox(height: 8), Text(r.description!)],
              if ((r.adminNote ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Callout(title: 'Note from CarZen', message: r.adminNote!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Recently viewed
// ---------------------------------------------------------------------------

class RecentlyViewedScreen extends StatefulWidget {
  const RecentlyViewedScreen({super.key});

  @override
  State<RecentlyViewedScreen> createState() => _RecentlyViewedScreenState();
}

class _RecentlyViewedScreenState extends State<RecentlyViewedScreen> {
  final _buyer = BuyerService();
  late Future<List<RecentlyViewed>> _future = _buyer.recentlyViewed(limit: 40);

  @override
  Widget build(BuildContext context) {
    return _AccountPage(
      title: 'Recently viewed',
      subtitle: 'Cars you opened while signed in, newest first.',
      maxWidth: 1080,
      onRefresh: () async {
        setState(() => _future = _buyer.recentlyViewed(limit: 40));
        await _future;
      },
      child: FutureBuilder<List<RecentlyViewed>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const ListingCollectionSkeleton(count: 3, maxColumns: 3);
          if (snap.hasError) {
            return ApiErrorView(error: snap.error!, onRetry: () => setState(() => _future = _buyer.recentlyViewed(limit: 40)), compact: true);
          }
          final items = snap.data!.where((r) => r.listing.listingStatus.name == 'active' || r.listing.listingStatus.name == 'reserved').toList();
          if (items.isEmpty) {
            return _Frame(
              child: EmptyStateView(
                compact: true,
                icon: Icons.history,
                title: 'Nothing here yet',
                message: 'Cars you look at will appear here so you can find them again.',
                action: FilledButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.browse), child: const Text('Browse cars')),
              ),
            );
          }
          return ListingCollection(
            listings: [for (final r in items) r.listing],
            maxColumns: 3,
            onOpen: (ListingDetail l) => Navigator.of(context).pushNamed(AppRoutes.carDetails(l.id, l.title)),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Purchase and sale history (transactions)
// ---------------------------------------------------------------------------

StatusTone transactionTone(String status) => switch (status) {
      'completed' => StatusTone.success,
      'initiated' => StatusTone.info,
      'failed' => StatusTone.danger,
      _ => StatusTone.neutral,
    };

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  final _service = TransactionService();
  TransactionScope _scope = TransactionScope.buy;
  late PagedController<TransactionRecord> _paged = _controller();

  PagedController<TransactionRecord> _controller() =>
      PagedController<TransactionRecord>(limit: 10, fetch: (p, l) => _service.list(scope: _scope, page: p, limit: l))..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AccountPage(
      title: 'Purchase history',
      subtitle: 'Paid and completed sales, with the final price and how it was paid.',
      onRefresh: () => _paged.refresh(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<TransactionScope>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: TransactionScope.buy, label: Text('Cars I bought')),
              ButtonSegment(value: TransactionScope.sell, label: Text('Cars I sold')),
            ],
            selected: {_scope},
            onSelectionChanged: (s) {
              final old = _paged;
              setState(() {
                _scope = s.first;
                _paged = _controller();
              });
              old.dispose();
            },
          ),
          const SizedBox(height: 16),
          PagedBody<TransactionRecord>(
            controller: _paged,
            itemLabel: 'transactions',
            empty: EmptyStateView(
              compact: true,
              icon: Icons.workspace_premium_outlined,
              title: _scope == TransactionScope.buy ? 'No purchases yet' : 'No sales yet',
              message: 'A sale appears here once payment is made for an accepted order.',
            ),
            itemBuilder: (context, t) => TransactionTile(record: t, showBuyer: _scope == TransactionScope.sell, showSeller: _scope == TransactionScope.buy),
          ),
        ],
      ),
    );
  }
}

/// One transaction row (also used by the admin console).
class TransactionTile extends StatelessWidget {
  final TransactionRecord record;
  final bool showBuyer;
  final bool showSeller;
  const TransactionTile({super.key, required this.record, this.showBuyer = true, this.showSeller = true});

  @override
  Widget build(BuildContext context) {
    final t = record;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(t.listingTitle ?? 'Car #${t.carId}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
              ),
              Text(formatInr(t.finalPrice), style: AppText.price(16)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            [
              'Transaction #${t.id}',
              'Order #${t.orderId}',
              if (t.transactionDate != null) formatDate(t.transactionDate) else formatDate(t.createdAt),
              if (t.paymentMethod != null) humanizeStatus(t.paymentMethod!),
            ].join('  |  '),
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          if ((showBuyer && t.buyer != null) || (showSeller && t.seller != null)) ...[
            const SizedBox(height: 4),
            Text(
              [if (showBuyer && t.buyer != null) 'Buyer: ${t.buyer!.displayName}', if (showSeller && t.seller != null) 'Seller: ${t.seller!.displayName}'].join('  |  '),
              style: const TextStyle(fontSize: 13),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 6, children: [
            StatusPill(label: humanizeStatus(t.transactionStatus), tone: transactionTone(t.transactionStatus)),
            StatusPill(label: 'Payment ${t.paymentStatus}', tone: t.paymentStatus == 'paid' ? StatusTone.success : StatusTone.warning),
          ]),
        ],
      ),
    );
  }
}
