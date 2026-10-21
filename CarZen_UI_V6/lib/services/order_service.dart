import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

class OrderService {
  OrderService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// Sends a purchase request. The amount is always the listing's asking
  /// price, set by the server - the client never supplies it.
  Future<OrderRecord> createOrder({required int listingId, num? amount, String? notes}) async {
    final json = await _client.post('/orders/listings/$listingId', body: {
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<PaginatedList<OrderRecord>> listMyOrders({int page = 1, int limit = 20, String? status}) async {
    final json = await _client.get('/buyer/orders', query: {'page': page, 'limit': limit, 'status': status});
    return PaginatedList.fromJson(json as Map<String, dynamic>, OrderRecord.fromJson);
  }

  Future<OrderRecord> getOrder(int orderId) async {
    final json = await _client.get('/orders/$orderId');
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<OrderRecord> cancelOrder(int orderId) async {
    final json = await _client.patch('/buyer/orders/$orderId/cancel');
    return OrderRecord.fromJson(json as Map<String, dynamic>);
  }

  // ---- Car Order Payments ----

  /// `POST /v1/payments`
  /// Starts a payment for an accepted order. [cash] arranges payment at
  /// handover (the seller confirms receipt); otherwise a Razorpay order is
  /// created for online checkout. The amount always comes from the order on
  /// the server.
  Future<CarPaymentRecord> createCarPayment({required int orderId, bool cash = false}) async {
    final json = await _client.post('/payments', body: {
      'order_id': orderId,
      // `PaymentMethod` has no "online" value; Razorpay checkout is recorded
      // as the backend default (card) and the buyer may still pay by UPI etc.
      if (cash) 'payment_method': 'cash',
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
  /// Records that cash was received. Allowed for the order's seller or an admin.
  Future<CarPaymentRecord> confirmCash(int paymentId, {String? notes}) => adminConfirmCash(paymentId, notes: notes);

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
