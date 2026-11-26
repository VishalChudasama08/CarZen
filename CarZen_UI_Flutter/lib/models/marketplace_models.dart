import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/utils/json_parsing.dart';

PersonSummary? _person(Object? json) => json is Map<String, dynamic> ? PersonSummary.fromJson(json) : null;

/// `TransactionCarSummary` / `ServiceRecordCarSummary`.
class CarSummary {
  final int id;
  final String? registrationNumber;
  final int manufacturingYear;
  final String? color;
  final String? fuelType;
  final String? transmission;

  const CarSummary({
    required this.id,
    this.registrationNumber,
    required this.manufacturingYear,
    this.color,
    this.fuelType,
    this.transmission,
  });

  factory CarSummary.fromJson(Map<String, dynamic> json) => CarSummary(
        id: json['id'] as int,
        registrationNumber: json['registration_number'] as String?,
        manufacturingYear: json['manufacturing_year'] as int? ?? 0,
        color: json['color'] as String?,
        fuelType: json['fuel_type'] as String?,
        transmission: json['transmission'] as String?,
      );
}

/// `ReviewResponse`.
class ReviewRecord {
  final int id;
  final int userId;
  final int? carId;
  final int? listingId;
  final int? transactionId;
  final int rating;
  final String? title;
  final String? reviewText;
  final bool isVisible;
  final DateTime? createdAt;
  final PersonSummary? user;
  final CarSummary? car;

  const ReviewRecord({
    required this.id,
    required this.userId,
    this.carId,
    this.listingId,
    this.transactionId,
    required this.rating,
    this.title,
    this.reviewText,
    required this.isVisible,
    this.createdAt,
    this.user,
    this.car,
  });

  factory ReviewRecord.fromJson(Map<String, dynamic> json) => ReviewRecord(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        carId: json['car_id'] as int?,
        listingId: json['listing_id'] as int?,
        transactionId: json['transaction_id'] as int?,
        rating: json['rating'] as int? ?? 0,
        title: json['title'] as String?,
        reviewText: json['review_text'] as String?,
        isVisible: json['is_visible'] as bool? ?? true,
        createdAt: parseDateTime(json['created_at']),
        user: _person(json['user']),
        car: json['car'] is Map<String, dynamic> ? CarSummary.fromJson(json['car'] as Map<String, dynamic>) : null,
      );
}

/// `TransactionResponse` (completed or in-progress sale).
class TransactionRecord {
  final int id;
  final int listingId;
  final int orderId;
  final int carId;
  final int buyerId;
  final int sellerId;
  final num finalPrice;
  final DateTime? transactionDate;
  final String? paymentMethod;
  final String paymentStatus;
  final String transactionStatus;
  final String? notes;
  final DateTime? createdAt;
  final PersonSummary? buyer;
  final PersonSummary? seller;
  final CarSummary? car;
  final String? listingTitle;

  const TransactionRecord({
    required this.id,
    required this.listingId,
    required this.orderId,
    required this.carId,
    required this.buyerId,
    required this.sellerId,
    required this.finalPrice,
    this.transactionDate,
    this.paymentMethod,
    required this.paymentStatus,
    required this.transactionStatus,
    this.notes,
    this.createdAt,
    this.buyer,
    this.seller,
    this.car,
    this.listingTitle,
  });

  factory TransactionRecord.fromJson(Map<String, dynamic> json) => TransactionRecord(
        id: json['id'] as int,
        listingId: json['listing_id'] as int,
        orderId: json['order_id'] as int? ?? 0,
        carId: json['car_id'] as int,
        buyerId: json['buyer_id'] as int,
        sellerId: json['seller_id'] as int,
        finalPrice: parseNum(json['final_price']),
        transactionDate: parseDateTime(json['transaction_date']),
        paymentMethod: json['payment_method'] as String?,
        paymentStatus: json['payment_status'] as String? ?? 'pending',
        transactionStatus: json['transaction_status'] as String? ?? 'initiated',
        notes: json['notes'] as String?,
        createdAt: parseDateTime(json['created_at']),
        buyer: _person(json['buyer']),
        seller: _person(json['seller']),
        car: json['car'] is Map<String, dynamic> ? CarSummary.fromJson(json['car'] as Map<String, dynamic>) : null,
        listingTitle: (json['listing'] as Map<String, dynamic>?)?['title'] as String?,
      );

  /// A purchase (`BuyerPurchaseResponse`) has the same core fields plus the
  /// full listing and the seller.
  factory TransactionRecord.fromPurchaseJson(Map<String, dynamic> json) {
    final base = TransactionRecord.fromJson(json);
    final listing = json['listing'] as Map<String, dynamic>?;
    return TransactionRecord(
      id: base.id,
      listingId: base.listingId,
      orderId: base.orderId,
      carId: base.carId,
      buyerId: base.buyerId,
      sellerId: base.sellerId,
      finalPrice: base.finalPrice,
      transactionDate: base.transactionDate,
      paymentMethod: base.paymentMethod,
      paymentStatus: base.paymentStatus,
      transactionStatus: base.transactionStatus,
      notes: base.notes,
      createdAt: base.createdAt,
      buyer: base.buyer,
      seller: base.seller,
      car: base.car,
      listingTitle: listing?['title'] as String?,
    );
  }
}

/// `ReportResponse`.
class ReportRecord {
  final int id;
  final int reporterId;
  final int? listingId;
  final int? carId;
  final ReportReason reason;
  final String? description;
  final String status;
  final DateTime? createdAt;
  final DateTime? resolvedAt;
  final String? adminNote;

  const ReportRecord({
    required this.id,
    required this.reporterId,
    this.listingId,
    this.carId,
    required this.reason,
    this.description,
    required this.status,
    this.createdAt,
    this.resolvedAt,
    this.adminNote,
  });

  factory ReportRecord.fromJson(Map<String, dynamic> json) => ReportRecord(
        id: json['id'] as int,
        reporterId: json['reporter_id'] as int,
        listingId: json['listing_id'] as int?,
        carId: json['car_id'] as int?,
        reason: ReportReason.values.firstWhere((r) => r.apiValue == json['reason'], orElse: () => ReportReason.other),
        description: json['description'] as String?,
        status: json['status'] as String? ?? 'pending',
        createdAt: parseDateTime(json['created_at']),
        resolvedAt: parseDateTime(json['resolved_at']),
        adminNote: json['admin_note'] as String?,
      );
}

const reportStatuses = ['pending', 'under_review', 'resolved', 'rejected'];

/// `BuyerDashboardResponse`.
class BuyerDashboard {
  final int favorites;
  final int activeInquiries;
  final int recentlyViewed;
  final int purchases;

  const BuyerDashboard({required this.favorites, required this.activeInquiries, required this.recentlyViewed, required this.purchases});

  factory BuyerDashboard.fromJson(Map<String, dynamic> json) => BuyerDashboard(
        favorites: json['total_favorite_cars'] as int? ?? 0,
        activeInquiries: json['active_inquiries'] as int? ?? 0,
        recentlyViewed: json['recently_viewed_cars'] as int? ?? 0,
        purchases: json['purchase_history'] as int? ?? 0,
      );
}

/// `SellerDashboardResponse`.
class SellerDashboard {
  final int totalListings;
  final int activeListings;
  final int pendingApprovals;
  final int soldCars;
  final int inquiries;

  const SellerDashboard({
    required this.totalListings,
    required this.activeListings,
    required this.pendingApprovals,
    required this.soldCars,
    required this.inquiries,
  });

  factory SellerDashboard.fromJson(Map<String, dynamic> json) => SellerDashboard(
        totalListings: json['total_listings'] as int? ?? 0,
        activeListings: json['active_listings'] as int? ?? 0,
        pendingApprovals: json['pending_approvals'] as int? ?? 0,
        soldCars: json['sold_cars'] as int? ?? 0,
        inquiries: json['inquiries'] as int? ?? 0,
      );
}

/// `RecentlyViewedListingResponse`.
class RecentlyViewed {
  final int id;
  final int listingId;
  final DateTime? viewedAt;
  final ListingDetail listing;

  const RecentlyViewed({required this.id, required this.listingId, this.viewedAt, required this.listing});

  factory RecentlyViewed.fromJson(Map<String, dynamic> json) => RecentlyViewed(
        id: json['id'] as int,
        listingId: json['listing_id'] as int,
        viewedAt: parseDateTime(json['viewed_at']),
        listing: ListingDetail.fromJson(json['listing'] as Map<String, dynamic>),
      );
}

/// `CarPricePredictResponse` - one saved price estimate.
class PriceEstimate {
  final int id;
  final String name;
  final int year;
  final int kmDriven;
  final String fuel;
  final String sellerType;
  final String transmission;
  final String owner;
  final num? mileage;
  final num? engine;
  final num? maxPower;
  final int? seats;
  final num predictedPrice;

  const PriceEstimate({
    required this.id,
    required this.name,
    required this.year,
    required this.kmDriven,
    required this.fuel,
    required this.sellerType,
    required this.transmission,
    required this.owner,
    this.mileage,
    this.engine,
    this.maxPower,
    this.seats,
    required this.predictedPrice,
  });

  factory PriceEstimate.fromJson(Map<String, dynamic> json) => PriceEstimate(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        year: json['year'] as int? ?? 0,
        kmDriven: json['km_driven'] as int? ?? 0,
        fuel: json['fuel'] as String? ?? '',
        sellerType: json['seller_type'] as String? ?? '',
        transmission: json['transmission'] as String? ?? '',
        owner: json['owner'] as String? ?? '',
        mileage: parseNumOrNull(json['mileage']),
        engine: parseNumOrNull(json['engine']),
        maxPower: parseNumOrNull(json['max_power']),
        seats: json['seats'] as int?,
        predictedPrice: parseNum(json['predicted_price']),
      );
}

enum PreferredContactMethod {
  phone('phone', 'Phone call'),
  email('email', 'Email'),
  whatsapp('whatsapp', 'WhatsApp');

  final String apiValue;
  final String label;
  const PreferredContactMethod(this.apiValue, this.label);

  static PreferredContactMethod fromApi(String? v) =>
      values.firstWhere((e) => e.apiValue == v, orElse: () => PreferredContactMethod.phone);
}

enum ContactVisibility {
  public('public', 'Anyone'),
  buyersOnly('buyers_only', 'Only buyers I talk to'),
  private('private', 'Only me');

  final String apiValue;
  final String label;
  const ContactVisibility(this.apiValue, this.label);

  static ContactVisibility fromApi(String? v) =>
      values.firstWhere((e) => e.apiValue == v, orElse: () => ContactVisibility.buyersOnly);
}

/// `SellerContactResponse` - how buyers may reach a seller.
class SellerContact {
  final int id;
  final String email;
  final String? phoneNumber;
  final String? whatsappNumber;
  final PreferredContactMethod preferredMethod;
  final ContactVisibility visibility;
  final bool isVisible;
  final AddressRecord? address;

  const SellerContact({
    required this.id,
    required this.email,
    this.phoneNumber,
    this.whatsappNumber,
    required this.preferredMethod,
    required this.visibility,
    required this.isVisible,
    this.address,
  });

  factory SellerContact.fromJson(Map<String, dynamic> json) => SellerContact(
        id: json['id'] as int,
        email: json['email'] as String? ?? '',
        phoneNumber: json['phone_number'] as String?,
        whatsappNumber: json['whatsapp_number'] as String?,
        preferredMethod: PreferredContactMethod.fromApi(json['preferred_contact_method'] as String?),
        visibility: ContactVisibility.fromApi(json['contact_visibility'] as String?),
        isVisible: json['is_visible'] as bool? ?? true,
        address: json['address'] is Map<String, dynamic> ? AddressRecord.fromJson(json['address'] as Map<String, dynamic>) : null,
      );
}
