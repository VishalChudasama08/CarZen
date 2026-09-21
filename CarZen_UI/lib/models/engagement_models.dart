import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/utils/formatters.dart';

/// Mirrors `BuyerUserSummary` (`buyer_schema.py`).
class PersonSummary {
  final int id;
  final String firstName;
  final String? lastName;
  final String username;

  const PersonSummary({required this.id, required this.firstName, this.lastName, required this.username});

  factory PersonSummary.fromJson(Map<String, dynamic> json) => PersonSummary(
        id: json['id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String?,
        username: json['username'] as String,
      );

  String get displayName =>
      (lastName == null || lastName!.isEmpty) ? firstName : '$firstName $lastName';
}

/// Mirrors `InquiryMessageResponse`.
class InquiryMessage {
  final int id;
  final int inquiryId;
  final int senderId;
  final String message;
  final DateTime? createdAt;
  final PersonSummary sender;

  const InquiryMessage({
    required this.id,
    required this.inquiryId,
    required this.senderId,
    required this.message,
    this.createdAt,
    required this.sender,
  });

  factory InquiryMessage.fromJson(Map<String, dynamic> json) => InquiryMessage(
        id: json['id'] as int,
        inquiryId: json['inquiry_id'] as int,
        senderId: json['sender_id'] as int,
        message: json['message'] as String,
        createdAt: parseDateTime(json['created_at']),
        sender: PersonSummary.fromJson(json['sender'] as Map<String, dynamic>),
      );
}

/// Mirrors `BuyerInquiryResponse` / `BuyerInquiryDetailResponse`.
/// [status] is the backend value: `open`, `contacted` or `closed`.
class InquiryRecord {
  final int id;
  final int listingId;
  final int buyerId;
  final int sellerId;
  final String? subject;
  final String message;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Listing listing;
  final PersonSummary seller;
  final List<InquiryMessage> messages;

  const InquiryRecord({
    required this.id,
    required this.listingId,
    required this.buyerId,
    required this.sellerId,
    this.subject,
    required this.message,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.listing,
    required this.seller,
    this.messages = const [],
  });

  factory InquiryRecord.fromJson(Map<String, dynamic> json) => InquiryRecord(
        id: json['id'] as int,
        listingId: json['listing_id'] as int,
        buyerId: json['buyer_id'] as int,
        sellerId: json['seller_id'] as int,
        subject: json['subject'] as String?,
        message: json['message'] as String,
        status: json['status'] as String,
        createdAt: parseDateTime(json['created_at']),
        updatedAt: parseDateTime(json['updated_at']),
        listing: Listing.fromJson(json['listing'] as Map<String, dynamic>),
        seller: PersonSummary.fromJson(json['seller'] as Map<String, dynamic>),
        messages: (json['messages'] as List<dynamic>? ?? [])
            .map((e) => InquiryMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  String get title => (subject != null && subject!.trim().isNotEmpty) ? subject! : listing.title;
}

/// Mirrors `NotificationResponse`. [type] is one of `order`, `payment`,
/// `listing`, `inquiry`, `favorite`, `system`, `admin` (or null).
class NotificationRecord {
  final int id;
  final String title;
  final String message;
  final String? type;
  final int? referenceId;
  final String? referenceType;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationRecord({
    required this.id,
    required this.title,
    required this.message,
    this.type,
    this.referenceId,
    this.referenceType,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationRecord.fromJson(Map<String, dynamic> json) => NotificationRecord(
        id: json['id'] as int,
        title: json['title'] as String,
        message: json['message'] as String,
        type: json['notification_type'] as String?,
        referenceId: json['reference_id'] as int?,
        referenceType: json['reference_type'] as String?,
        isRead: json['is_read'] as bool? ?? false,
        createdAt: parseDateTime(json['created_at']),
      );
}

/// Reasons accepted by `POST /v1/reports` (`ReportReason`).
enum ReportReason {
  fakeListing('fake_listing', 'Fake listing'),
  wrongInformation('wrong_information', 'Wrong information'),
  fraud('fraud', 'Fraud'),
  duplicateListing('duplicate_listing', 'Duplicate listing'),
  suspiciousSeller('suspicious_seller', 'Suspicious seller'),
  inappropriateContent('inappropriate_content', 'Inappropriate content'),
  other('other', 'Other');

  final String apiValue;
  final String label;
  const ReportReason(this.apiValue, this.label);
}
