import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/utils/json_parsing.dart';

/// Order lifecycle (`OrderStatus` in the backend):
/// pending -> confirmed (seller accepts, car reserved) -> processing -> completed
/// with cancelled / rejected as exits.
const orderStatuses = ['pending', 'confirmed', 'processing', 'completed', 'cancelled', 'rejected'];

/// Mirrors `OrderResponse` (buyer, seller and admin order endpoints).
class OrderRecord {
  final int id;
  final int listingId;
  final int carId;
  final int buyerId;
  final int sellerId;
  final num amount;
  final String status;
  final String paymentStatus;
  final String? notes;
  final String listingTitle;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;
  final PersonSummary? buyer;
  final PersonSummary? seller;
  final Listing? listing;
  final ListingCar? car;

  const OrderRecord({
    required this.id,
    required this.listingId,
    this.carId = 0,
    this.buyerId = 0,
    this.sellerId = 0,
    required this.amount,
    required this.status,
    required this.paymentStatus,
    required this.listingTitle,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
    this.buyer,
    this.seller,
    this.listing,
    this.car,
  });

  factory OrderRecord.fromJson(Map<String, dynamic> json) {
    final listingJson = json['listing'] as Map<String, dynamic>?;
    Listing? listing;
    ListingCar? car;
    try {
      listing = listingJson == null ? null : Listing.fromJson(listingJson);
    } catch (_) {
      listing = null;
    }
    try {
      car = json['car'] is Map<String, dynamic> ? ListingCar.fromJson(json['car'] as Map<String, dynamic>) : null;
    } catch (_) {
      car = null;
    }
    PersonSummary? person(Object? j) => j is Map<String, dynamic> ? PersonSummary.fromJson(j) : null;
    return OrderRecord(
      id: json['id'] as int,
      listingId: json['listing_id'] as int,
      carId: json['car_id'] as int? ?? 0,
      buyerId: json['buyer_id'] as int? ?? 0,
      sellerId: json['seller_id'] as int? ?? 0,
      amount: parseNum(json['amount']),
      status: json['status'] as String,
      paymentStatus: json['payment_status'] as String? ?? 'pending',
      notes: json['notes'] as String?,
      listingTitle: listingJson?['title'] as String? ?? 'Car listing',
      createdAt: parseDateTime(json['created_at']),
      updatedAt: parseDateTime(json['updated_at']),
      completedAt: parseDateTime(json['completed_at']),
      buyer: person(json['buyer']),
      seller: person(json['seller']),
      listing: listing,
      car: car,
    );
  }

  bool get isPaid => paymentStatus == 'paid';
  bool get isActive => status == 'pending' || status == 'confirmed' || status == 'processing';

  /// The buyer can pay once the seller has accepted.
  bool get canPay => (status == 'confirmed' || status == 'processing') && !isPaid;
}

/// Mirrors `PaymentResponse` / `PaymentStatusResponse` for car orders.
class CarPaymentRecord {
  final int id;
  final int orderId;
  final num amount;
  final String status;
  final String paymentMethod;
  final String? razorpayOrderId;
  final String? razorpayKeyId;
  final DateTime? paymentDate;

  const CarPaymentRecord({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.status,
    required this.paymentMethod,
    this.razorpayOrderId,
    this.razorpayKeyId,
    this.paymentDate,
  });

  factory CarPaymentRecord.fromJson(Map<String, dynamic> json) => CarPaymentRecord(
        id: json['id'] as int,
        orderId: json['order_id'] as int? ?? 0,
        amount: parseNum(json['amount']),
        status: json['status'] as String? ?? 'pending',
        paymentMethod: json['payment_method'] as String? ?? 'online',
        razorpayOrderId: json['razorpay_order_id'] as String?,
        razorpayKeyId: json['razorpay_key_id'] as String?,
        paymentDate: parseDateTime(json['payment_date']),
      );

  bool get isCash => paymentMethod == 'cash';
  bool get isPending => status == 'pending' || status == 'processing';
  bool get isSuccess => status == 'success';
}
