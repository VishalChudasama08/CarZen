import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// One conversation with a seller: `GET /v1/buyer/inquiries/{id}` for the
/// thread and `POST /v1/inquiries/{id}/messages` to reply.
class InquiryThreadScreen extends StatefulWidget {
  final int inquiryId;
  const InquiryThreadScreen({super.key, required this.inquiryId});

  @override
  State<InquiryThreadScreen> createState() => _InquiryThreadScreenState();
}

class _InquiryThreadScreenState extends State<InquiryThreadScreen> {
  final _service = EngagementService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  InquiryRecord? _record;
  Object? _error;
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final record = await _service.getInquiry(widget.inquiryId);
      if (!mounted) return;
      setState(() {
        _record = record;
        _error = null;
        _loading = false;
      });
      _scrollToEnd();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _service.sendMessage(widget.inquiryId, text);
      _controller.clear();
      await _load(silent: true);
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.messages, title: 'Conversation'),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) return const LoadingView(label: 'Loading conversation...');
    final error = _error;
    if (error != null) {
      return ApiErrorView(error: error, onRetry: _load, fallback: 'Could not load this conversation.');
    }
    final record = _record!;
    final first = record.messages.isNotEmpty ? record.messages.first : null;
    final initialIsRepeated = first != null && first.senderId == record.buyerId && first.message.trim() == record.message.trim();

    final bubbles = <Widget>[
      if (!initialIsRepeated)
        _Bubble(text: record.message, isMine: true, author: 'You', time: record.createdAt),
      for (final m in record.messages)
        _Bubble(
          text: m.message,
          isMine: m.senderId == record.buyerId,
          author: m.senderId == record.buyerId ? 'You' : m.sender.displayName,
          time: m.createdAt,
        ),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Column(
          children: [
            _ListingHeader(record: record),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => _load(silent: true),
                child: ListView(
                  controller: _scroll,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  children: bubbles,
                ),
              ),
            ),
            _Composer(controller: _controller, sending: _sending, onSend: _send),
          ],
        ),
      ),
    );
  }
}

class _ListingHeader extends StatelessWidget {
  final InquiryRecord record;
  const _ListingHeader({required this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.listing.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  '${formatInr(record.listing.askingPrice)}  -  Seller: ${record.seller.displayName}',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.carDetails(record.listingId)),
            child: const Text('View car'),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isMine;
  final String author;
  final DateTime? time;

  const _Bubble({required this.text, required this.isMine, required this.author, this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: isMine ? null : Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              author,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: isMine ? AppColors.secondary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(text, style: TextStyle(color: isMine ? Colors.white : AppColors.textPrimary, height: 1.4)),
            if (time != null) ...[
              const SizedBox(height: 4),
              Text(
                formatDateTime(time),
                style: TextStyle(fontSize: 10.5, color: isMine ? Colors.white60 : AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  const _Composer({required this.controller, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              maxLength: 5000,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(hintText: 'Write a reply...', counterText: '', border: InputBorder.none),
            ),
          ),
          IconButton.filled(
            tooltip: 'Send',
            onPressed: sending ? null : onSend,
            icon: sending
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
