import 'package:carzen_flutter/utils/json_parsing.dart';

/// Deliberately mirrors only fields returned by `OrderResponse` that the UI
/// displays. Payment remains a separate backend workflow.
class OrderRecord {
  final int id;
  final int listingId;
  final num amount;
  final String status;
  final String paymentStatus;
  final String? notes;
  final String listingTitle;
  final DateTime? createdAt;

  const OrderRecord({
    required this.id,
    required this.listingId,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.listingTitle,
    this.notes,
    this.createdAt,
  });

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    final listing = json['listing'] as Map<String, dynamic>? ?? const {};
    return OrderRecord(
      id: json['id'] as int,
      listingId: json['listing_id'] as int,
      amount: parseNum(json['amount']),
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String,
      notes: json['notes'] as String?,
      listingTitle: listing['title'] as String? ?? 'Car listing',
      createdAt: json['created_at'] == null ? null : DateTime.tryParse(json['created_at'] as String),
    );
  }
}
