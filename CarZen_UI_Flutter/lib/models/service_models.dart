import 'package:carzen_flutter/utils/json_parsing.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';

DateTime? _date(Object? value) => value is String ? DateTime.tryParse(value) : null;

/// Mirrors `ServiceResponse` (`service_catalog_schema.py`) — one entry of the
/// admin-managed service catalog (`/v1/services`, `/v1/admin/services`).
class ServiceOffering {
  final int id;
  final String name;
  final String? description;
  final num price;
  final int? durationMinutes;
  final String? imageUrl;

  /// Backend value: `active` or `inactive`.
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ServiceOffering({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.durationMinutes,
    this.imageUrl,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status == 'active';

  factory ServiceOffering.fromJson(Map<String, dynamic> json) => ServiceOffering(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String?,
        price: parseNum(json['price']),
        durationMinutes: json['duration_minutes'] as int?,
        imageUrl: json['image_url'] as String?,
        status: json['status'] as String? ?? 'active',
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
      );
}

/// One entry of `GET /v1/service-slots?date=` → `{"date": ..., "slots": [{"time": "09:00:00", "available": true}]}`.
class ServiceSlot {
  /// `HH:mm:ss`, exactly as the backend expects it back in `scheduled_time`.
  final String time;
  final bool available;

  const ServiceSlot({required this.time, required this.available});

  factory ServiceSlot.fromJson(Map<String, dynamic> json) =>
      ServiceSlot(time: json['time'] as String, available: json['available'] as bool? ?? false);

  static List<ServiceSlot> listFromResponse(Object? json) {
    final raw = json is Map<String, dynamic> ? (json['slots'] as List<dynamic>? ?? const []) : const [];
    final slots = raw.map((e) => ServiceSlot.fromJson(e as Map<String, dynamic>)).toList();
    // The backend lists 15:30 / 16:30 / 17:30 after 17:00; show them in clock order.
    slots.sort((a, b) => a.time.compareTo(b.time));
    return slots;
  }
}

/// Mirrors `ServiceRequestStatus` (`ServiceEnums.py`).
enum ServiceRequestStatus { requested, accepted, scheduled, inProgress, completed, cancelled, rejected }

extension ServiceRequestStatusX on ServiceRequestStatus {
  String get apiValue => switch (this) {
        ServiceRequestStatus.requested => 'requested',
        ServiceRequestStatus.accepted => 'accepted',
        ServiceRequestStatus.scheduled => 'scheduled',
        ServiceRequestStatus.inProgress => 'in_progress',
        ServiceRequestStatus.completed => 'completed',
        ServiceRequestStatus.cancelled => 'cancelled',
        ServiceRequestStatus.rejected => 'rejected',
      };

  String get label => switch (this) {
        ServiceRequestStatus.requested => 'Requested',
        ServiceRequestStatus.accepted => 'Accepted',
        ServiceRequestStatus.scheduled => 'Scheduled',
        ServiceRequestStatus.inProgress => 'In progress',
        ServiceRequestStatus.completed => 'Completed',
        ServiceRequestStatus.cancelled => 'Cancelled',
        ServiceRequestStatus.rejected => 'Rejected',
      };

  StatusTone get tone => switch (this) {
        ServiceRequestStatus.requested => StatusTone.warning,
        ServiceRequestStatus.accepted => StatusTone.info,
        ServiceRequestStatus.scheduled => StatusTone.info,
        ServiceRequestStatus.inProgress => StatusTone.info,
        ServiceRequestStatus.completed => StatusTone.success,
        ServiceRequestStatus.cancelled => StatusTone.neutral,
        ServiceRequestStatus.rejected => StatusTone.danger,
      };

  /// `cancel_user_request` only allows requested / accepted / scheduled.
  bool get userCanCancel =>
      this == ServiceRequestStatus.requested ||
      this == ServiceRequestStatus.accepted ||
      this == ServiceRequestStatus.scheduled;

  static ServiceRequestStatus fromApi(String value) => ServiceRequestStatus.values.firstWhere(
        (e) => e.apiValue == value,
        orElse: () => ServiceRequestStatus.requested,
      );
}

/// Mirrors `ServiceRequestItemResponse`.
class ServiceRequestItem {
  final int id;
  final int? serviceId;
  final String serviceName;
  final num unitPrice;
  final int? durationMinutes;

  const ServiceRequestItem({
    required this.id,
    this.serviceId,
    required this.serviceName,
    required this.unitPrice,
    this.durationMinutes,
  });

  factory ServiceRequestItem.fromJson(Map<String, dynamic> json) => ServiceRequestItem(
        id: json['id'] as int,
        serviceId: json['service_id'] as int?,
        serviceName: json['service_name'] as String,
        unitPrice: parseNum(json['unit_price']),
        durationMinutes: json['duration_minutes'] as int?,
      );
}

/// Mirrors `ServiceRequestUserSummary` (present on admin responses and the user's own).
class ServiceRequestUser {
  final int id;
  final String firstName;
  final String? lastName;
  final String email;
  final String? phoneNumber;

  const ServiceRequestUser({
    required this.id,
    required this.firstName,
    this.lastName,
    required this.email,
    this.phoneNumber,
  });

  String get displayName => (lastName == null || lastName!.isEmpty) ? firstName : '$firstName $lastName';

  factory ServiceRequestUser.fromJson(Map<String, dynamic> json) => ServiceRequestUser(
        id: json['id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String?,
        email: json['email'] as String,
        phoneNumber: json['phone_number'] as String?,
      );
}

/// Mirrors `ServiceRequestCarSummary` / `ServiceRecordCarSummary`.
class ServiceCarSummary {
  final int id;
  final String? registrationNumber;
  final int manufacturingYear;
  final String? color;
  final String? fuelType;

  const ServiceCarSummary({
    required this.id,
    this.registrationNumber,
    required this.manufacturingYear,
    this.color,
    this.fuelType,
  });

  /// `2022 · MH12KT6390 · Black`
  String get label => [
        '$manufacturingYear',
        if (registrationNumber != null && registrationNumber!.isNotEmpty) registrationNumber!,
        if (color != null && color!.isNotEmpty) color!,
      ].join(' · ');

  factory ServiceCarSummary.fromJson(Map<String, dynamic> json) => ServiceCarSummary(
        id: json['id'] as int,
        registrationNumber: json['registration_number'] as String?,
        manufacturingYear: json['manufacturing_year'] as int,
        color: json['color'] as String?,
        fuelType: json['fuel_type'] as String?,
      );
}

/// Mirrors `ServiceRequestResponse`.
///
/// `payment_status` / `payment_method` are informational only: this app has no
/// payment flow, so they are displayed but never turned into an action.
class ServiceRequestRecord {
  final int id;
  final int userId;
  final int carId;
  final int? serviceId;
  final int? addressId;
  final DateTime scheduledDate;

  /// `HH:mm:ss`.
  final String scheduledTime;
  final String? notes;
  final num amount;
  final String paymentStatus;
  final String? paymentMethod;
  final ServiceRequestStatus status;
  final String? adminNote;
  final int? serviceRecordId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ServiceRequestUser? user;
  final ServiceCarSummary? car;
  final ServiceOffering? service;
  final List<ServiceRequestItem> items;

  const ServiceRequestRecord({
    required this.id,
    required this.userId,
    required this.carId,
    this.serviceId,
    this.addressId,
    required this.scheduledDate,
    required this.scheduledTime,
    this.notes,
    required this.amount,
    required this.paymentStatus,
    this.paymentMethod,
    required this.status,
    this.adminNote,
    this.serviceRecordId,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.car,
    this.service,
    this.items = const [],
  });

  /// "Full Servicing, Oil Change" — mirrors the backend's own naming.
  String get title {
    if (items.isNotEmpty) return items.map((e) => e.serviceName).join(', ');
    return service?.name ?? 'Service request';
  }

  factory ServiceRequestRecord.fromJson(Map<String, dynamic> json) => ServiceRequestRecord(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        carId: json['car_id'] as int,
        serviceId: json['service_id'] as int?,
        addressId: json['address_id'] as int?,
        scheduledDate: DateTime.parse(json['scheduled_date'] as String),
        scheduledTime: json['scheduled_time'] as String,
        notes: json['notes'] as String?,
        amount: parseNum(json['amount']),
        paymentStatus: json['payment_status'] as String? ?? '',
        paymentMethod: json['payment_method'] as String?,
        status: ServiceRequestStatusX.fromApi(json['status'] as String),
        adminNote: json['admin_note'] as String?,
        serviceRecordId: json['service_record_id'] as int?,
        createdAt: _date(json['created_at']),
        updatedAt: _date(json['updated_at']),
        user: json['user'] == null ? null : ServiceRequestUser.fromJson(json['user'] as Map<String, dynamic>),
        car: json['car'] == null ? null : ServiceCarSummary.fromJson(json['car'] as Map<String, dynamic>),
        service: json['service'] == null ? null : ServiceOffering.fromJson(json['service'] as Map<String, dynamic>),
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((e) => ServiceRequestItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Mirrors `ServiceItemResponse` (one line on a completed service record).
class ServiceRecordItem {
  final int id;
  final String itemName;
  final int? quantity;
  final num? unitPrice;
  final num? totalPrice;

  const ServiceRecordItem({required this.id, required this.itemName, this.quantity, this.unitPrice, this.totalPrice});

  factory ServiceRecordItem.fromJson(Map<String, dynamic> json) => ServiceRecordItem(
        id: json['id'] as int,
        itemName: json['item_name'] as String,
        quantity: json['quantity'] as int?,
        unitPrice: parseNumOrNull(json['unit_price']),
        totalPrice: parseNumOrNull(json['total_price']),
      );
}

/// Mirrors `ServiceRecordResponse` — the permanent service history of a car
/// (`/v1/services/history`, `/v1/cars/{id}/service-history`).
class ServiceRecord {
  final int id;
  final int carId;
  final String serviceType;
  final DateTime serviceDate;
  final num? odometerReading;
  final num? serviceCost;
  final num? partsCost;
  final num? laborCost;
  final String? description;
  final DateTime? nextServiceDate;
  final num? nextServiceMileage;

  /// `scheduled`, `completed` or `cancelled`.
  final String? status;
  final ServiceCarSummary? car;
  final List<ServiceRecordItem> items;

  const ServiceRecord({
    required this.id,
    required this.carId,
    required this.serviceType,
    required this.serviceDate,
    this.odometerReading,
    this.serviceCost,
    this.partsCost,
    this.laborCost,
    this.description,
    this.nextServiceDate,
    this.nextServiceMileage,
    this.status,
    this.car,
    this.items = const [],
  });

  factory ServiceRecord.fromJson(Map<String, dynamic> json) => ServiceRecord(
        id: json['id'] as int,
        carId: json['car_id'] as int,
        serviceType: json['service_type'] as String,
        serviceDate: DateTime.parse(json['service_date'] as String),
        odometerReading: parseNumOrNull(json['odometer_reading']),
        serviceCost: parseNumOrNull(json['service_cost']),
        partsCost: parseNumOrNull(json['parts_cost']),
        laborCost: parseNumOrNull(json['labor_cost']),
        description: json['description'] as String?,
        nextServiceDate: _date(json['next_service_date']),
        nextServiceMileage: parseNumOrNull(json['next_service_mileage']),
        status: json['status'] as String?,
        car: json['car'] == null ? null : ServiceCarSummary.fromJson(json['car'] as Map<String, dynamic>),
        items: (json['items'] as List<dynamic>? ?? const [])
            .map((e) => ServiceRecordItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Mirrors `AddressResponse` (`/v1/address`, `/v1/address-add`).
class AddressRecord {
  final int id;
  final String addressLine1;
  final String? addressLine2;
  final String? landmark;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;

  const AddressRecord({
    required this.id,
    required this.addressLine1,
    this.addressLine2,
    this.landmark,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.isDefault,
  });

  String get oneLine => [
        addressLine1,
        if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2!,
        if (landmark != null && landmark!.isNotEmpty) landmark!,
        city,
        state,
        postalCode,
      ].join(', ');

  factory AddressRecord.fromJson(Map<String, dynamic> json) => AddressRecord(
        id: json['id'] as int,
        addressLine1: json['address_line_1'] as String,
        addressLine2: json['address_line_2'] as String?,
        landmark: json['landmark'] as String?,
        city: json['city'] as String,
        state: json['state'] as String,
        country: json['country'] as String? ?? 'India',
        postalCode: json['postal_code'] as String,
        isDefault: json['is_default'] as bool? ?? false,
      );
}
