import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// The signed-in buyer's conversations with sellers — `GET /v1/buyer/inquiries`.
class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  final _service = EngagementService();
  late Future<List<InquiryRecord>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _service.listMyInquiries(limit: 50).then((page) => page.data);
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _future;
    } catch (_) {
      // The FutureBuilder below renders the error state.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.messages, title: 'Messages'),
      body: SafeArea(
        child: FutureBuilder<List<InquiryRecord>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading your messages...');
            }
            if (snapshot.hasError) {
              return ApiErrorView(
                error: snapshot.error!,
                onRetry: _refresh,
                fallback: 'Could not load your messages.',
              );
            }
            final inquiries = snapshot.data!;
            if (inquiries.isEmpty) {
              return EmptyStateView(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No conversations yet',
                message: 'Use "Ask the seller" on any car to start a conversation.',
                action: FilledButton(
                  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.browse, (r) => false),
                  child: const Text('Browse cars'),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: _refresh,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 820),
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 16, 16, Breakpoints.isCompact(context) ? 24 : 40),
                    itemCount: inquiries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _InquiryTile(
                      inquiry: inquiries[index],
                      onTap: () async {
                        await Navigator.of(context).pushNamed(AppRoutes.inquiry(inquiries[index].id));
                        if (mounted) _refresh();
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InquiryTile extends StatelessWidget {
  final InquiryRecord inquiry;
  final VoidCallback onTap;
  const _InquiryTile({required this.inquiry, required this.onTap});

  Color get _statusColor {
    switch (inquiry.status) {
      case 'contacted':
        return AppColors.success;
      case 'closed':
        return AppColors.textSecondary;
      default:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = inquiry.status.isEmpty ? '' : inquiry.status[0].toUpperCase() + inquiry.status.substring(1);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    inquiry.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(status, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${inquiry.listing.title} - ${formatInr(inquiry.listing.askingPrice)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 8),
            Text(
              inquiry.message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textPrimary, height: 1.35),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Seller: ${inquiry.seller.displayName}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ),
                Text(
                  formatDate(inquiry.updatedAt ?? inquiry.createdAt),
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
