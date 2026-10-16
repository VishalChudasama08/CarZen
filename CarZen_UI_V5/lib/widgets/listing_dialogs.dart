import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:flutter/material.dart';

/// Dialogs used on the car details page. Each one owns (and disposes) its
/// own controllers and returns `null` when cancelled.

Future<({String? note})?> showOrderRequestDialog(BuildContext context, {required num amount}) =>
    showDialog<({String? note})>(context: context, builder: (_) => _OrderRequestDialog(amount: amount));

Future<({String? subject, String message})?> showInquiryDialog(BuildContext context, {String? defaultSubject}) =>
    showDialog<({String? subject, String message})>(
      context: context,
      builder: (_) => _InquiryDialog(defaultSubject: defaultSubject),
    );

Future<({ReportReason reason, String? description})?> showReportDialog(BuildContext context) =>
    showDialog<({ReportReason reason, String? description})>(context: context, builder: (_) => const _ReportDialog());

class _OrderRequestDialog extends StatefulWidget {
  final num amount;
  const _OrderRequestDialog({required this.amount});

  @override
  State<_OrderRequestDialog> createState() => _OrderRequestDialogState();
}

class _OrderRequestDialogState extends State<_OrderRequestDialog> {
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Send purchase request?'),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('This creates an order request for ${formatInr(widget.amount)}. No payment is taken now.'),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLength: 5000,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Note to seller (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final text = _note.text.trim();
            Navigator.pop(context, (note: text.isEmpty ? null : text));
          },
          child: const Text('Send request'),
        ),
      ],
    );
  }
}

class _InquiryDialog extends StatefulWidget {
  final String? defaultSubject;
  const _InquiryDialog({this.defaultSubject});

  @override
  State<_InquiryDialog> createState() => _InquiryDialogState();
}

class _InquiryDialogState extends State<_InquiryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _subject = TextEditingController(text: widget.defaultSubject);
  final TextEditingController _message = TextEditingController();

  @override
  void dispose() {
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final subject = _subject.text.trim();
    Navigator.pop(context, (subject: subject.isEmpty ? null : subject, message: _message.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ask the seller'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _subject,
                  maxLength: 255,
                  decoration: const InputDecoration(labelText: 'Subject (optional)'),
                ),
                TextFormField(
                  controller: _message,
                  maxLength: 5000,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Your message'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please write a message.' : null,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(onPressed: _submit, child: const Text('Send message')),
      ],
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final TextEditingController _description = TextEditingController();
  ReportReason _reason = ReportReason.wrongInformation;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Report this listing'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<ReportReason>(
                value: _reason,
                decoration: const InputDecoration(labelText: 'Reason'),
                items: [
                  for (final reason in ReportReason.values)
                    DropdownMenuItem<ReportReason>(value: reason, child: Text(reason.label)),
                ],
                onChanged: (value) => setState(() => _reason = value ?? _reason),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _description,
                maxLength: 5000,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Details (optional)'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final text = _description.text.trim();
            Navigator.pop(context, (reason: _reason, description: text.isEmpty ? null : text));
          },
          child: const Text('Submit report'),
        ),
      ],
    );
  }
}
