import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/paged_list_view.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// The signed-in buyer's conversations with sellers — `GET /v1/buyer/inquiries`.
class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  final _service = EngagementService();
  late final PagedController<InquiryRecord> _paged;

  @override
  void initState() {
    super.initState();
    _paged = PagedController<InquiryRecord>(
      limit: 10,
      fetch: (page, limit) => _service.listMyInquiries(page: page, limit: limit),
    )..load();
  }

  @override
  void dispose() {
    _paged.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.messages, title: 'Messages'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.messages),
      body: SafeArea(
        bottom: false,
        child: PagedListView<InquiryRecord>(
          controller: _paged,
          maxWidth: 860,
          itemLabel: 'conversations',
          header: const PageHeader(
            title: 'Messages',
            subtitle: 'Your conversations with sellers.',
            icon: Icons.chat_bubble_rounded,
          ),
          empty: EmptyStateView(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No conversations yet',
            message: 'Use "Ask the seller" on any car to start a conversation.',
            action: FilledButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.browse, (r) => false),
              child: const Text('Browse cars'),
            ),
          ),
          errorFallback: 'Could not load your messages.',
          itemBuilder: (context, inquiry) => _InquiryTile(
            inquiry: inquiry,
            onTap: () async {
              await Navigator.of(context).pushNamed(AppRoutes.inquiry(inquiry.id));
              if (mounted) _paged.refresh();
            },
          ),
        ),
      ),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  final InquiryRecord inquiry;
  final VoidCallback onTap;
  const _InquiryTile({required this.inquiry, required this.onTap});

  StatusTone get _tone => switch (inquiry.status) {
        'contacted' => StatusTone.success,
        'closed' => StatusTone.neutral,
        _ => StatusTone.info,
      };

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(inquiry.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(width: 8),
              StatusPill(label: humanizeStatus(inquiry.status), tone: _tone),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${inquiry.listing.title} · ${formatInr(inquiry.listing.askingPrice)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          Text(inquiry.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textPrimary, height: 1.4)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(child: Text('Seller: ${inquiry.seller.displayName}', style: Theme.of(context).textTheme.bodySmall)),
              Text(formatDate(inquiry.updatedAt ?? inquiry.createdAt), style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
