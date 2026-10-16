// SECURITY (Ayush): rotate the exposed Razorpay key secret
// TODO(Ayush): gap F — ₹50,000 online limit vs real car prices (car purchases above limit need cash/bank transfer flow)
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

  // ---- Car Order Payments ----

  /// `POST /v1/payments`
  Future<CarPaymentRecord> createCarPayment({
    required int orderId,
    required String paymentMethod,
  }) async {
    final json = await _client.post('/payments', body: {
      'order_id': orderId,
      'payment_method': paymentMethod,
    });
    return CarPaymentRecord.fromJson(json as Map<String, dynamic>);
  }

  /// `POST /v1/payments/{payment_id}/verify`
  Future<CarPaymentRecord> verifyCarPayment(
    int paymentId, {
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
  }) async {
    final json = await _client.post('/payments/$paymentId/verify', body: {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    });
    return CarPaymentRecord.fromJson(json as Map<String, dynamic>);
  }

  /// `GET /v1/payments/order/{order_id}`
  Future<CarPaymentRecord?> getOrderPayment(int orderId) async {
    try {
      final json = await _client.get('/payments/order/$orderId');
      return CarPaymentRecord.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// `POST /v1/payments/{payment_id}/confirm-cash` (admin / seller)
  Future<CarPaymentRecord> adminConfirmCash(int paymentId, {String? notes}) async {
    final json = await _client.post('/payments/$paymentId/confirm-cash', body: {
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    return CarPaymentRecord.fromJson(json as Map<String, dynamic>);
  }

  // ---- Admin Orders ----

  Future<PaginatedList<OrderRecord>> listAdminOrders({int page = 1, int limit = 50, String? status}) async {
    final json = await _client.get('/admin/orders', query: {'page': page, 'limit': limit, 'status': status});
    return PaginatedList.fromJson(json as Map<String, dynamic>, OrderRecord.fromJson);
  }

  Future<OrderRecord> updateAdminOrderStatus(int orderId, String status) async {
    final json = await _client.patch('/admin/orders/$orderId/status', body: {'status': status});
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }
}
