import 'package:intl/intl.dart';

final NumberFormat _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final NumberFormat _grouped = NumberFormat.decimalPattern('en_IN');
final DateFormat _dateTime = DateFormat('d MMM y, h:mm a');
final DateFormat _date = DateFormat('d MMM y');

/// `1680000` -> `₹16,80,000` (Indian digit grouping).
String formatInr(num value) => _inr.format(value);

/// Short Indian price: `416000` -> `₹4.16 lakh`, `12500000` -> `₹1.25 crore`.
/// Values under one lakh are shown in full.
String formatLakh(num value) {
  if (value >= 10000000) return '₹${_trim2(value / 10000000)} crore';
  if (value >= 100000) return '₹${_trim2(value / 100000)} lakh';
  return formatInr(value);
}

String _trim2(num v) {
  final s = v.toStringAsFixed(2);
  return s.endsWith('.00') ? s.substring(0, s.length - 3) : (s.endsWith('0') ? s.substring(0, s.length - 1) : s);
}

/// `24100.0` -> `24,100 km`.
String formatKm(num value) => '${_grouped.format(value.round())} km';

/// Whole numbers with Indian grouping, e.g. engine capacity.
String formatCount(num value) => _grouped.format(value.round());

String formatDateTime(DateTime? value) => value == null ? '' : _dateTime.format(value.toLocal());

String formatDate(DateTime? value) => value == null ? '' : _date.format(value.toLocal());

/// "Just now", "5 min ago", "3 h ago", "Yesterday", "4 days ago", or the date.
String formatRelative(DateTime? value) {
  if (value == null) return '';
  final now = DateTime.now();
  final local = value.toLocal();
  final diff = now.difference(local);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return formatDate(local);
}

/// Backend timestamps look like `2026-09-17T17:15:00`.
DateTime? parseDateTime(Object? value) => value is String ? DateTime.tryParse(value) : null;

/// `2026-10-04` for the backend's `YYYY-MM-DD` date parameters and bodies.
String toApiDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

/// `9:00:00` / `09:00` -> `9:00 AM`. Falls back to the raw value if it is not a clock time.
String formatClock(String? value) {
  if (value == null || value.isEmpty) return '';
  final parts = value.split(':');
  if (parts.length < 2) return value;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return value;
  final period = hour >= 12 ? 'PM' : 'AM';
  final h12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$h12:${minute.toString().padLeft(2, '0')} $period';
}

/// `95` -> `1 hr 35 min`, `45` -> `45 min`.
String formatDuration(int minutes) {
  if (minutes < 60) return '$minutes min';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '$h hr' : '$h hr $m min';
}
