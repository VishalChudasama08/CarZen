import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/services/seller_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/pages/inquiry_thread_screen.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum MessagesTab { buying, selling }

/// Every conversation in one inbox: "Buying" (questions you asked sellers,
/// `/buyer/inquiries`) and "Selling" (buyers asking about your cars,
/// `/seller/inquiries`). Desktop shows the list and the open conversation
/// side by side.
class MessagesScreen extends StatefulWidget {
  final MessagesTab initialTab;
  const MessagesScreen({super.key, this.initialTab = MessagesTab.buying});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _buyer = EngagementService();
  final _seller = SellerService();
  late MessagesTab _tab = widget.initialTab;
  int? _selectedId;
  late PagedController<InquiryRecord> _paged = _controllerFor(_tab);

  PagedController<InquiryRecord> _controllerFor(MessagesTab tab) => PagedController<InquiryRecord>(
        limit: 12,
        fetch: (page, limit) =>
            tab == MessagesTab.buying ? _buyer.listMyInquiries(page: page, limit: limit) : _seller.inquiries(page: page, limit: limit),
      )..load();

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  void _switch(MessagesTab tab) {
    if (tab == _tab) return;
    final old = _paged;
    setState(() {
      _tab = tab;
      _selectedId = null;
      _paged = _controllerFor(tab);
    });
    old.dispose();
    SystemNavigator.routeInformationUpdated(
      uri: Uri(path: AppRoutes.messages, queryParameters: tab == MessagesTab.selling ? {'tab': 'selling'} : null),
      replace: true,
    );
  }

  void _open(InquiryRecord r, bool twoPane) {
    if (twoPane) {
      setState(() => _selectedId = r.id);
      return;
    }
    Navigator.of(context)
        .pushNamed(AppRoutes.inquiry(r.id, asSeller: _tab == MessagesTab.selling))
        .then((_) => _paged.refresh());
  }

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final twoPane = width >= Breakpoints.expanded;
    final list = _list(twoPane);
    return AppScaffold(
      section: NavSection.messages,
      title: 'Messages',
      showBottomNav: true,
      body: twoPane
          ? Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth + 80),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(AppSpacing.pageGutter(width), 24, AppSpacing.pageGutter(width), 24),
                  child: Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(width: 380, child: list),
                        const VerticalDivider(width: 1),
                        Expanded(
                          child: ColoredBox(
                            color: AppColors.background,
                            child: _selectedId == null
                                ? const EmptyStateView(
                                    icon: Icons.forum_outlined,
                                    title: 'Choose a conversation',
                                    message: 'Pick a conversation on the left to read and reply.',
                                  )
                                : InquiryThreadView(
                                    key: ValueKey('$_tab-$_selectedId'),
                                    inquiryId: _selectedId!,
                                    asSeller: _tab == MessagesTab.selling,
                                    onChanged: _paged.refresh,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : list,
    );
  }

  Widget _list(bool twoPane) {
    final compact = Breakpoints.isCompact(context);
    final header = Padding(
      padding: EdgeInsets.fromLTRB(twoPane ? 20 : 0, twoPane ? 20 : 0, twoPane ? 20 : 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Messages', style: AppText.heading(twoPane ? 22 : (compact ? 23 : 28))),
          const SizedBox(height: 14),
          SegmentedButton<MessagesTab>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: MessagesTab.buying, label: Text('Buying'), icon: Icon(Icons.shopping_bag_outlined, size: 18)),
              ButtonSegment(value: MessagesTab.selling, label: Text('Selling'), icon: Icon(Icons.sell_outlined, size: 18)),
            ],
            selected: {_tab},
            onSelectionChanged: (s) => _switch(s.first),
          ),
        ],
      ),
    );
    final body = PagedBody<InquiryRecord>(
      controller: _paged,
      itemLabel: 'conversations',
      skeletonHeight: 76,
      spacing: twoPane ? 0 : 10,
      empty: EmptyStateView(
        compact: true,
        icon: Icons.forum_outlined,
        title: _tab == MessagesTab.buying ? 'No conversations yet' : 'No buyer questions yet',
        message: _tab == MessagesTab.buying
            ? 'Message a seller from any car page to ask about it. Replies show up here.'
            : 'When buyers ask about your cars, their questions appear here.',
        action: _tab == MessagesTab.buying
            ? FilledButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.browse), child: const Text('Browse cars'))
            : null,
      ),
      itemBuilder: (context, r) => _ConversationTile(
        record: r,
        asSeller: _tab == MessagesTab.selling,
        selected: twoPane && r.id == _selectedId,
        flat: twoPane,
        onTap: () => _open(r, twoPane),
      ),
    );
    if (twoPane) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const Divider(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _paged.refresh,
              child: ListView(padding: const EdgeInsets.only(bottom: 16), children: [body]),
            ),
          ),
        ],
      );
    }
    return RefreshIndicator(
      onRefresh: _paged.refresh,
      child: ListView(
        padding: EdgeInsets.fromLTRB(AppSpacing.pageGutter(Breakpoints.widthOf(context)), compact ? 16 : 28,
            AppSpacing.pageGutter(Breakpoints.widthOf(context)), 32),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [header, const SizedBox(height: 4), body]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final InquiryRecord record;
  final bool asSeller;
  final bool selected;
  final bool flat;
  final VoidCallback onTap;

  const _ConversationTile({required this.record, required this.asSeller, required this.selected, required this.flat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = record.counterpart?.displayName ?? (asSeller ? 'Buyer' : 'Seller');
    final initials = name.trim().isEmpty
        ? '?'
        : name.trim().split(RegExp(r'\s+')).take(2).map((p) => p[0].toUpperCase()).join();
    final when = record.updatedAt ?? record.createdAt;
    final tile = InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.chromeTint : null,
          border: flat ? const Border(bottom: BorderSide(color: AppColors.divider)) : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserAvatar(initials: initials, size: 40, background: AppColors.surfaceMuted, foreground: AppColors.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                      Text(formatRelative(when), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(record.listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          record.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusPill(label: inquiryStatusLabel(record.status), tone: inquiryStatusTone(record.status)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    final labelled = Semantics(
      button: true,
      selected: selected,
      label: 'Conversation with $name about ${record.listing.title}, ${inquiryStatusLabel(record.status)}',
      excludeSemantics: true,
      child: tile,
    );
    if (flat) return Material(color: Colors.transparent, child: labelled);
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md), side: const BorderSide(color: AppColors.divider)),
      clipBehavior: Clip.antiAlias,
      child: labelled,
    );
  }
}
