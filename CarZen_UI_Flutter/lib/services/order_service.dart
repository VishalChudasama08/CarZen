import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

class OrderService {
  OrderService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<OrderRecord> createOrder({required int listingId, required num amount, String? notes}) async {
    final json = await _client.post('/orders/listings/$listingId', body: {
      'amount': amount,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<PaginatedList<OrderRecord>> listMyOrders({int page = 1, int limit = 20}) async {
    final json = await _client.get('/buyer/orders', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, OrderRecord.fromJson);
  }

  Future<OrderRecord> cancelOrder(int orderId) async {
    final json = await _client.patch('/buyer/orders/$orderId/cancel');
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<PaginatedList<OrderRecord>> listAdminOrders({int page = 1, int limit = 50, String? status}) async {
    final json = await _client.get('/admin/orders', query: {'page': page, 'limit': limit, 'status': status});
    return PaginatedList.fromJson(json as Map<String, dynamic>, OrderRecord.fromJson);
  }

  Future<OrderRecord> updateAdminOrderStatus(int orderId, String status) async {
    final json = await _client.patch('/admin/orders/$orderId/status', body: {'status': status});
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }
}
