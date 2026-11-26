import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/engagement_service.dart';
import 'package:carzen_flutter/services/seller_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Full-page conversation (phones/tablets, deep links).
class InquiryThreadScreen extends StatelessWidget {
  final int inquiryId;
  final bool asSeller;
  const InquiryThreadScreen({super.key, required this.inquiryId, this.asSeller = false});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.messages,
      title: 'Conversation',
      fallbackRoute: AppRoutes.messages,
      // On wide screens the conversation keeps a readable column width.
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 920),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: MediaQuery.sizeOf(context).width > 940
                  ? const Border.symmetric(vertical: BorderSide(color: AppColors.divider))
                  : const Border(),
            ),
            child: InquiryThreadView(inquiryId: inquiryId, asSeller: asSeller),
          ),
        ),
      ),
    );
  }
}

String inquiryStatusLabel(String status) => switch (status) {
      'open' => 'Open',
      'contacted' => 'Replied',
      'closed' => 'Closed',
      _ => humanizeStatus(status),
    };

StatusTone inquiryStatusTone(String status) => switch (status) {
      'open' => StatusTone.info,
      'contacted' => StatusTone.success,
      'closed' => StatusTone.neutral,
      _ => StatusTone.neutral,
    };

/// One conversation about a listing, from the buyer's side
/// (`/buyer/inquiries/{id}`) or the seller's (`/seller/inquiries/{id}`).
class InquiryThreadView extends StatefulWidget {
  final int inquiryId;
  final bool asSeller;

  /// Called after a message is sent or the status changes, so a list
  /// beside the thread can refresh.
  final VoidCallback? onChanged;

  const InquiryThreadView({super.key, required this.inquiryId, this.asSeller = false, this.onChanged});

  @override
  State<InquiryThreadView> createState() => _InquiryThreadViewState();
}

class _InquiryThreadViewState extends State<InquiryThreadView> {
  final _buyer = EngagementService();
  final _seller = SellerService();
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  final _focus = FocusNode();

  InquiryRecord? _record;
  Object? _error;
  bool _loading = true;
  bool _sending = false;
  bool _statusBusy = false;

  /// Starts from the requested side; if this account is on the other side of
  /// the conversation (e.g. opened from a notification), it switches over.
  late bool _asSeller = widget.asSeller;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant InquiryThreadView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inquiryId != widget.inquiryId || oldWidget.asSeller != widget.asSeller) {
      _record = null;
      _asSeller = widget.asSeller;
      _controller.clear();
      _load();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    _focus.dispose();
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
      InquiryRecord record;
      try {
        record = _asSeller ? await _seller.inquiry(widget.inquiryId) : await _buyer.getInquiry(widget.inquiryId);
      } on ApiException catch (e) {
        if (_record != null || !(e.statusCode == 404 || e.statusCode == 403)) rethrow;
        record = _asSeller ? await _buyer.getInquiry(widget.inquiryId) : await _seller.inquiry(widget.inquiryId);
        _asSeller = !_asSeller;
      }
      if (!mounted) return;
      setState(() {
        _record = record;
        _error = null;
        _loading = false;
      });
      _scrollToEnd();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      if (_asSeller) {
        await _seller.reply(widget.inquiryId, text);
      } else {
        await _buyer.sendMessage(widget.inquiryId, text);
      }
      _controller.clear();
      await _load(silent: true);
      widget.onChanged?.call();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _setStatus(String status) async {
    setState(() => _statusBusy = true);
    try {
      final updated = await _seller.setInquiryStatus(widget.inquiryId, status);
      if (!mounted) return;
      setState(() => _record = updated);
      widget.onChanged?.call();
      showAppSnack(context, status == 'closed' ? 'Conversation closed' : 'Marked as ${inquiryStatusLabel(status).toLowerCase()}');
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _statusBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _record == null) return const LoadingView(label: 'Opening conversation...');
    if (_error != null && _record == null) {
      return ApiErrorView(error: _error!, onRetry: _load, fallback: 'This conversation could not be loaded.');
    }
    final record = _record!;
    final mineId = _asSeller ? record.sellerId : record.buyerId;
    final first = record.messages.isNotEmpty ? record.messages.first : null;
    final initialIsRepeated = first != null && first.senderId == record.buyerId && first.message.trim() == record.message.trim();
    final counterpart = record.counterpart?.displayName ?? (_asSeller ? 'Buyer' : 'Seller');

    final bubbles = <Widget>[
      if (!initialIsRepeated)
        _Bubble(
          text: record.message,
          isMine: !_asSeller,
          author: _asSeller ? counterpart : 'You',
          time: record.createdAt,
        ),
      for (final m in record.messages)
        _Bubble(
          text: m.message,
          isMine: m.senderId == mineId,
          author: m.senderId == mineId ? 'You' : m.sender.displayName,
          time: m.createdAt,
        ),
    ];

    return Column(
      children: [
        _Header(
          record: record,
          counterpart: counterpart,
          asSeller: _asSeller,
          statusBusy: _statusBusy,
          onStatus: _setStatus,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _load(silent: true),
            child: ListView(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              children: [
                Center(
                  child: Text(
                    'Conversation started ${formatDate(record.createdAt)}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
                  ),
                ),
                const SizedBox(height: 10),
                ...bubbles,
              ],
            ),
          ),
        ),
        if (record.status == 'closed' && !_asSeller)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.divider))),
            child: const Text(
              'The seller closed this conversation. You can still send a message if you need to.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
            ),
          ),
        _Composer(controller: _controller, focusNode: _focus, sending: _sending, onSend: _send),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final InquiryRecord record;
  final String counterpart;
  final bool asSeller;
  final bool statusBusy;
  final ValueChanged<String> onStatus;

  const _Header({
    required this.record,
    required this.counterpart,
    required this.asSeller,
    required this.statusBusy,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final listing = record.listing;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      decoration: const BoxDecoration(color: AppColors.surface, border: Border(bottom: BorderSide(color: AppColors.divider))),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(counterpart, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  '${listing.title}, ${formatInr(listing.askingPrice)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
                ),
              ],
            ),
          ),
          if (asSeller)
            PopupMenuButton<String>(
              tooltip: 'Conversation status',
              enabled: !statusBusy,
              onSelected: onStatus,
              position: PopupMenuPosition.under,
              itemBuilder: (_) => [
                for (final s in const ['open', 'contacted', 'closed'])
                  PopupMenuItem(
                    value: s,
                    child: Row(children: [
                      SizedBox(width: 24, child: s == record.status ? const Icon(Icons.check, size: 18) : null),
                      const SizedBox(width: 8),
                      Text(s == 'closed' ? 'Close conversation' : 'Mark as ${inquiryStatusLabel(s).toLowerCase()}'),
                    ]),
                  ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  StatusPill(label: inquiryStatusLabel(record.status), tone: inquiryStatusTone(record.status)),
                  const Icon(Icons.expand_more, size: 20),
                ]),
              ),
            )
          else
            StatusPill(label: inquiryStatusLabel(record.status), tone: inquiryStatusTone(record.status)),
          if (!asSeller && listing.listingStatus.name == 'active')
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.carDetails(record.listingId, listing.title)),
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
    return Semantics(
      label: '$author${time == null ? '' : ', ${formatDateTime(time)}'}: $text',
      excludeSemantics: true,
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width < 600 ? MediaQuery.sizeOf(context).width * 0.82 : 520),
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isMine ? AppColors.ink : AppColors.surface,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMine ? 16 : 4),
                    bottomRight: Radius.circular(isMine ? 4 : 16),
                  ),
                  border: isMine ? null : Border.all(color: AppColors.divider),
                ),
                child: SelectableText(text, style: TextStyle(color: isMine ? Colors.white : AppColors.textPrimary, height: 1.45, fontSize: 14.5)),
              ),
              const SizedBox(height: 3),
              Text(
                [if (!isMine) author, formatRelative(time)].where((s) => s.isNotEmpty).join(', '),
                style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool sending;
  final VoidCallback onSend;

  const _Composer({required this.controller, required this.focusNode, required this.sending, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: CallbackShortcuts(
                    // On wide (keyboard) layouts Enter sends and Shift+Enter adds a line;
                    // on phones the on-screen keyboard's return key adds a line.
                    bindings: MediaQuery.sizeOf(context).width >= 600
                        ? {const SingleActivator(LogicalKeyboardKey.enter): onSend}
                        : const <ShortcutActivator, VoidCallback>{},
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      minLines: 1,
                      maxLines: 5,
                      maxLength: 5000,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Write a message',
                        counterText: '',
                        isDense: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(AppRadii.md))),
                        enabledBorder: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(AppRadii.md))),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Send message',
                  style: IconButton.styleFrom(minimumSize: const Size(48, 48), backgroundColor: AppColors.ink),
                  onPressed: sending ? null : onSend,
                  icon: sending
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
