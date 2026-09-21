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
