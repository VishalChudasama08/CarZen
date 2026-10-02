import 'package:intl/intl.dart';

final NumberFormat _inr = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
final NumberFormat _grouped = NumberFormat.decimalPattern('en_IN');
final DateFormat _dateTime = DateFormat('d MMM y, h:mm a');
final DateFormat _date = DateFormat('d MMM y');

/// `1680000` -> `₹16,80,000` (Indian digit grouping).
String formatInr(num value) => _inr.format(value);

/// `24100.0` -> `24,100 km`.
String formatKm(num value) => '${_grouped.format(value.round())} km';

/// Whole numbers with Indian grouping, e.g. engine capacity.
String formatCount(num value) => _grouped.format(value.round());

String formatDateTime(DateTime? value) => value == null ? '' : _dateTime.format(value);

String formatDate(DateTime? value) => value == null ? '' : _date.format(value);

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
