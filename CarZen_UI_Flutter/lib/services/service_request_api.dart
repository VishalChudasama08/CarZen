import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'api_client.dart';

/// Talks to `service_requests.py` and `services.py` (history).
///
/// Payment routes (`pay-online`, `verify-online`, `confirm-cash`) exist on the
/// backend but are intentionally NOT wrapped here: payment is out of scope.
class ServiceRequestApi {
  ServiceRequestApi({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  // ---- Slots (public) ----

  /// `GET /v1/service-slots?date=YYYY-MM-DD`
  Future<List<ServiceSlot>> slots(DateTime date) async {
    final json = await _client.get('/service-slots', query: {'date': toApiDate(date)});
    return ServiceSlot.listFromResponse(json);
  }

  // ---- Cars used for service booking ----

  /// `GET /v1/service/my-cars` — a plain list (no pagination), every non-deleted car of the user.
  Future<List<CarRecord>> listMyCars() async {
    final json = await _client.get('/service/my-cars');
    return (json as List<dynamic>).map((e) => CarRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// `POST /v1/service/my-cars` (`ServiceCarCreate`) — auto-approved, service-only.
  Future<CarRecord> addServiceCar({
    required int variantId,
    String? registrationNumber,
    required int manufacturingYear,
    required FuelType fuelType,
    required TransmissionType transmission,
    required num mileageKm,
    String? color,
    required String city,
    required String state,
  }) async {
    final json = await _client.post('/service/my-cars', body: {
      'variant_id': variantId,
      if (registrationNumber != null && registrationNumber.isNotEmpty) 'registration_number': registrationNumber,
      'manufacturing_year': manufacturingYear,
      'fuel_type': fuelType.apiValue,
      'transmission': transmission.apiValue,
      'mileage_km': mileageKm,
      if (color != null && color.isNotEmpty) 'color': color,
      'city': city,
      'state': state,
      'country': 'India',
    });
    return CarRecord.fromJson(json as Map<String, dynamic>);
  }

  // ---- Customer requests ----

  /// `POST /v1/service-requests` (`ServiceRequestCreate`).
  ///
  /// `scheduled_time` is `HH:mm:ss`. The backend reads `address_id` whenever
  /// the request is created and fails if it is missing, so the booking form
  /// always sends one.
  Future<ServiceRequestRecord> create({
    required int carId,
    required List<int> serviceIds,
    required int addressId,
    required DateTime date,
    required String time,
    String? notes,
  }) async {
    final json = await _client.post('/service-requests', body: {
      'car_id': carId,
      'service_ids': serviceIds,
      'address_id': addressId,
      'scheduled_date': toApiDate(date),
      'scheduled_time': time,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    return ServiceRequestRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<PaginatedList<ServiceRequestRecord>> list({int page = 1, int limit = 10, ServiceRequestStatus? status}) async {
    final json = await _client.get('/service-requests', query: {
      'page': page,
      'limit': limit,
      'status': status?.apiValue,
    });
    return PaginatedList.fromJson(json as Map<String, dynamic>, ServiceRequestRecord.fromJson);
  }

  Future<ServiceRequestRecord> get(int id) async {
    final json = await _client.get('/service-requests/$id');
    return ServiceRequestRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<ServiceRequestRecord> cancel(int id, {String? notes}) async {
    final json = await _client.post('/service-requests/$id/cancel', body: {
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    });
    return ServiceRequestRecord.fromJson(json as Map<String, dynamic>);
  }

  // ---- Service history ----

  /// `GET /v1/services/history` — completed work on the user's cars.
  Future<PaginatedList<ServiceRecord>> history({int page = 1, int limit = 10}) async {
    final json = await _client.get('/services/history', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, ServiceRecord.fromJson);
  }

  Future<ServiceRecord> historyRecord(int id) async {
    final json = await _client.get('/services/history/$id');
    return ServiceRecord.fromJson(json as Map<String, dynamic>);
  }

  /// `GET /v1/cars/{id}/service-history`
  Future<PaginatedList<ServiceRecord>> carHistory(int carId, {int page = 1, int limit = 10}) async {
    final json = await _client.get('/cars/$carId/service-history', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, ServiceRecord.fromJson);
  }

  // ---- Admin ----

  Future<PaginatedList<ServiceRequestRecord>> adminList({
    int page = 1,
    int limit = 10,
    ServiceRequestStatus? status,
  }) async {
    final json = await _client.get('/admin/service-requests', query: {
      'page': page,
      'limit': limit,
      'status': status?.apiValue,
    });
    return PaginatedList.fromJson(json as Map<String, dynamic>, ServiceRequestRecord.fromJson);
  }

  Future<ServiceRequestRecord> adminGet(int id) async {
    final json = await _client.get('/admin/service-requests/$id');
    return ServiceRequestRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<ServiceRequestRecord> adminAccept(int id) => _adminAction(id, 'accept');

  Future<ServiceRequestRecord> adminStart(int id) => _adminAction(id, 'start');

  Future<ServiceRequestRecord> adminReject(int id, String adminNote) =>
      _adminAction(id, 'reject', body: {'admin_note': adminNote});

  Future<ServiceRequestRecord> adminSchedule(int id, {required DateTime date, required String time, String? adminNote}) =>
      _adminAction(id, 'schedule', body: {
        'scheduled_date': toApiDate(date),
        'scheduled_time': time,
        if (adminNote != null && adminNote.trim().isNotEmpty) 'admin_note': adminNote.trim(),
      });

  /// `ServiceRequestAdminComplete` — every field is optional; this also creates the car's permanent service record.
  Future<ServiceRequestRecord> adminComplete(
    int id, {
    String? adminNote,
    num? odometerReading,
    num? partsCost,
    num? laborCost,
    DateTime? nextServiceDate,
    num? nextServiceMileage,
  }) =>
      _adminAction(id, 'complete', body: {
        if (adminNote != null && adminNote.trim().isNotEmpty) 'admin_note': adminNote.trim(),
        if (odometerReading != null) 'odometer_reading': odometerReading,
        if (partsCost != null) 'parts_cost': partsCost,
        if (laborCost != null) 'labor_cost': laborCost,
        if (nextServiceDate != null) 'next_service_date': toApiDate(nextServiceDate),
        if (nextServiceMileage != null) 'next_service_mileage': nextServiceMileage,
      });

  Future<ServiceRequestRecord> adminCancel(int id, {String? notes}) => _adminAction(id, 'cancel', body: {
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
      });

  Future<ServiceRequestRecord> _adminAction(int id, String action, {Map<String, dynamic>? body}) async {
    final json = await _client.post('/admin/service-requests/$id/$action', body: body);
    return ServiceRequestRecord.fromJson(json as Map<String, dynamic>);
  }
}
