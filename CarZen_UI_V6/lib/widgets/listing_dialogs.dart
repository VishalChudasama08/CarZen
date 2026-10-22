import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
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
      title: const Text('Send a purchase request'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(children: [
                const TextSpan(text: 'You\'re asking to buy this car at '),
                TextSpan(text: formatInr(widget.amount), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F1C2E))),
                const TextSpan(text: '. The seller can accept or decline. Nothing is charged now - you pay only after they accept.'),
              ])),
              const SizedBox(height: 16),
              TextField(
                controller: _note,
                maxLength: 5000,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Note to the seller (optional)', hintText: 'e.g. When could I see the car?'),
              ),
            ],
          ),
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
      title: const Text('Message the seller'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _subject,
                  maxLength: 255,
                  decoration: const InputDecoration(labelText: 'Subject'),
                ),
                TextFormField(
                  controller: _message,
                  maxLength: 5000,
                  minLines: 3,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Your message', hintText: 'Ask about service history, a test drive, or the price'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Write a message to send.' : null,
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
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tell us what is wrong. Our team reviews every report; the seller is not told who reported.'),
              const SizedBox(height: 16),
              DropdownButtonFormField<ReportReason>(
                style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontFamily: AppText.body),
                initialValue: _reason,
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
          child: const Text('Send report'),
        ),
      ],
    );
  }
}

/// Star rating + optional title and text. Returns null when cancelled.
Future<({int rating, String? title, String? text})?> showReviewDialog(
  BuildContext context, {
  required String carName,
  int initialRating = 0,
  String? initialTitle,
  String? initialText,
}) =>
    showDialog<({int rating, String? title, String? text})>(
      context: context,
      builder: (_) => _ReviewDialog(carName: carName, initialRating: initialRating, initialTitle: initialTitle, initialText: initialText),
    );

class _ReviewDialog extends StatefulWidget {
  final String carName;
  final int initialRating;
  final String? initialTitle;
  final String? initialText;
  const _ReviewDialog({required this.carName, required this.initialRating, this.initialTitle, this.initialText});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  late int _rating = widget.initialRating;
  late final TextEditingController _title = TextEditingController(text: widget.initialTitle);
  late final TextEditingController _text = TextEditingController(text: widget.initialText);
  bool _tried = false;

  static const _labels = ['Poor', 'Fair', 'Good', 'Very good', 'Excellent'];

  @override
  void dispose() {
    _title.dispose();
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Review your purchase'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('How was buying the ${widget.carName}?'),
              const SizedBox(height: 14),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 2,
                runSpacing: 4,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      tooltip: '$i - ${_labels[i - 1]}',
                      onPressed: () => setState(() => _rating = i),
                      icon: Icon(i <= _rating ? Icons.star : Icons.star_border, size: 28, color: i <= _rating ? const Color(0xFFE0A100) : const Color(0xFFC6CFDA)),
                    ),
                  if (_rating > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(_labels[_rating - 1], style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              if (_tried && _rating == 0)
                const Padding(
                  padding: EdgeInsets.only(left: 8, bottom: 6),
                  child: Text('Choose a rating', style: TextStyle(color: Color(0xFFC62F3B), fontSize: 12.5)),
                ),
              const SizedBox(height: 8),
              TextField(controller: _title, maxLength: 200, decoration: const InputDecoration(labelText: 'Headline (optional)')),
              TextField(
                controller: _text,
                maxLength: 2000,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Your review (optional)', hintText: 'What should other buyers know?'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (_rating == 0) {
              setState(() => _tried = true);
              return;
            }
            final title = _title.text.trim();
            final text = _text.text.trim();
            Navigator.pop(context, (rating: _rating, title: title.isEmpty ? null : title, text: text.isEmpty ? null : text));
          },
          child: const Text('Post review'),
        ),
      ],
    );
  }
}
