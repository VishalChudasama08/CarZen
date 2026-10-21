import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

/// Seller-side endpoints: dashboard, enquiries received and orders received.
class SellerService {
  SellerService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<SellerDashboard> dashboard() async {
    final json = await _client.get('/seller/dashboard');
    return SellerDashboard.fromJson(json as Map<String, dynamic>);
  }

  // ---- Enquiries received ----

  Future<PaginatedList<InquiryRecord>> inquiries({int page = 1, int limit = 20, String? status}) async {
    final json = await _client.get('/seller/inquiries', query: {'page': page, 'limit': limit, 'status': status});
    return PaginatedList.fromJson(json as Map<String, dynamic>, InquiryRecord.fromJson);
  }

  Future<InquiryRecord> inquiry(int id) async {
    final json = await _client.get('/seller/inquiries/$id');
    return InquiryRecord.fromJson(json as Map<String, dynamic>);
  }

  /// `open`, `contacted` or `closed`.
  Future<InquiryRecord> setInquiryStatus(int id, String status) async {
    final json = await _client.patch('/seller/inquiries/$id/status', body: {'status': status});
    return InquiryRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<InquiryMessage> reply(int id, String message) async {
    final json = await _client.post('/seller/inquiries/$id/messages', body: {'message': message.trim()});
    return InquiryMessage.fromJson(json as Map<String, dynamic>);
  }

  // ---- Orders received ----

  Future<PaginatedList<OrderRecord>> orders({int page = 1, int limit = 10, String? status}) async {
    final json = await _client.get('/seller/orders', query: {'page': page, 'limit': limit, 'status': status});
    return PaginatedList.fromJson(json as Map<String, dynamic>, OrderRecord.fromJson);
  }

  Future<OrderRecord> acceptOrder(int id) async {
    final json = await _client.patch('/seller/orders/$id/accept');
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<OrderRecord> rejectOrder(int id) async {
    final json = await _client.patch('/seller/orders/$id/reject');
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }

  /// `processing`, `completed` or `cancelled`.
  Future<OrderRecord> setOrderStatus(int id, String status) async {
    final json = await _client.patch('/seller/orders/$id/status', body: {'status': status});
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }
}
