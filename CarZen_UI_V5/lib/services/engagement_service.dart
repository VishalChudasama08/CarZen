import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

/// Buyer inquiries + message threads, notifications and listing reports —
/// all backed by real endpoints (`buyer.py`, `notifications.py`, `reports.py`).
class EngagementService {
  EngagementService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  // ---- Inquiries ----

  Future<InquiryRecord> createInquiry({required int listingId, String? subject, required String message}) async {
    final json = await _client.post('/buyer/listings/$listingId/inquiries', body: {
      if (subject != null && subject.trim().isNotEmpty) 'subject': subject.trim(),
      'message': message.trim(),
    });
    return InquiryRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<PaginatedList<InquiryRecord>> listMyInquiries({int page = 1, int limit = 20}) async {
    final json = await _client.get('/buyer/inquiries', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, InquiryRecord.fromJson);
  }

  Future<InquiryRecord> getInquiry(int inquiryId) async {
    final json = await _client.get('/buyer/inquiries/$inquiryId');
    return InquiryRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<List<InquiryMessage>> listMessages(int inquiryId) async {
    final json = await _client.get('/inquiries/$inquiryId/messages');
    return (json as List<dynamic>).map((e) => InquiryMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<InquiryMessage> sendMessage(int inquiryId, String message) async {
    final json = await _client.post('/inquiries/$inquiryId/messages', body: {'message': message.trim()});
    return InquiryMessage.fromJson(json as Map<String, dynamic>);
  }

  // ---- Notifications ----

  Future<PaginatedList<NotificationRecord>> listNotifications({int page = 1, int limit = 30}) async {
    final json = await _client.get('/notifications', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, NotificationRecord.fromJson);
  }

  Future<NotificationRecord> markRead(int notificationId) async {
    final json = await _client.patch('/notifications/$notificationId/read');
    return NotificationRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<void> markAllRead() => _client.patch('/notifications/read-all');

  Future<void> deleteNotification(int notificationId) => _client.delete('/notifications/$notificationId');

  // ---- Reports ----

  Future<void> reportListing({required int listingId, required ReportReason reason, String? description}) async {
    await _client.post('/reports', body: {
      'listing_id': listingId,
      'reason': reason.apiValue,
      if (description != null && description.trim().isNotEmpty) 'description': description.trim(),
    });
  }
}
