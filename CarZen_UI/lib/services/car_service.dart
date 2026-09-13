import '../models/car_models.dart';
import '../models/enums.dart';
import '../models/pagination.dart';
import 'api_client.dart';

/// Talks to `/v1/cars` (owner-scoped CRUD, media, features) and the
/// `/v1/admin/cars` moderation endpoints. All of it requires a valid
/// bearer token — [ApiClient] attaches it automatically.
class CarService {
  CarService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  /// Fields accepted by `CarCreate`/`CarUpdate`. Only the ones the UI
  /// actually collects are required here — everything else is optional on
  /// the backend and simply omitted (never invented).
  Map<String, dynamic> _carPayload({
    required int variantId,
    required int manufacturingYear,
    required FuelType fuelType,
    required TransmissionType transmission,
    required num mileageKm,
    required CarCondition condition,
    required String city,
    required String state,
    String? registrationNumber,
    String? color,
    int? seatingCapacity,
    String? description,
    num? expectedMarketPrice,
    String country = 'India',
  }) {
    return {
      'variant_id': variantId,
      'manufacturing_year': manufacturingYear,
      'fuel_type': fuelType.apiValue,
      'transmission': transmission.apiValue,
      'mileage_km': mileageKm,
      'condition': condition.apiValue,
      'city': city,
      'state': state,
      'country': country,
      if (registrationNumber != null && registrationNumber.isNotEmpty) 'registration_number': registrationNumber,
      if (color != null && color.isNotEmpty) 'color': color,
      if (seatingCapacity != null) 'seating_capacity': seatingCapacity,
      if (description != null && description.isNotEmpty) 'description': description,
      if (expectedMarketPrice != null) 'expected_market_price': expectedMarketPrice,
    };
  }

  Future<CarRecord> createCar({
    required int variantId,
    required int manufacturingYear,
    required FuelType fuelType,
    required TransmissionType transmission,
    required num mileageKm,
    required CarCondition condition,
    required String city,
    required String state,
    String? registrationNumber,
    String? color,
    int? seatingCapacity,
    String? description,
    num? expectedMarketPrice,
  }) async {
    final json = await _client.post(
      '/cars',
      body: _carPayload(
        variantId: variantId,
        manufacturingYear: manufacturingYear,
        fuelType: fuelType,
        transmission: transmission,
        mileageKm: mileageKm,
        condition: condition,
        city: city,
        state: state,
        registrationNumber: registrationNumber,
        color: color,
        seatingCapacity: seatingCapacity,
        description: description,
        expectedMarketPrice: expectedMarketPrice,
      ),
    );
    return CarRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<CarRecord> updateCar(int carId, Map<String, dynamic> partialFields) async {
    final json = await _client.patch('/cars/$carId', body: partialFields);
    return CarRecord.fromJson(json as Map<String, dynamic>);
  }

  /// `GET /v1/cars` — the current user's own cars (owner-scoped by the
  /// backend automatically).
  Future<PaginatedList<CarRecord>> listMyCars({int page = 1, int limit = 20, CarApprovalStatus? status}) async {
    final json = await _client.get('/cars', query: {'page': page, 'limit': limit, 'status': status?.apiValue});
    return PaginatedList.fromJson(json as Map<String, dynamic>, CarRecord.fromJson);
  }

  Future<CarRecordDetail> getCar(int carId) async {
    final json = await _client.get('/cars/$carId');
    return CarRecordDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteCar(int carId) => _client.delete('/cars/$carId');

  // ---- Media ----

  Future<List<CarMedia>> listMedia(int carId) async {
    final json = await _client.get('/cars/$carId/media');
    return (json as List<dynamic>).map((e) => CarMedia.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CarMedia> uploadMedia(
    int carId, {
    required List<int> fileBytes,
    required String fileName,
    required MediaType mediaType,
    int sortOrder = 0,
    bool isPrimary = false,
  }) async {
    final json = await _client.postMultipart(
      '/cars/$carId/media',
      fileBytes: fileBytes,
      fileName: fileName,
      fields: {
        'media_type': mediaType.apiValue,
        'sort_order': sortOrder.toString(),
        'is_primary': isPrimary.toString(),
      },
    );
    return CarMedia.fromJson(json as Map<String, dynamic>);
  }

  Future<CarMedia> setPrimaryMedia(int carId, int mediaId) async {
    final json = await _client.patch('/cars/$carId/media/$mediaId/primary');
    return CarMedia.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteMedia(int carId, int mediaId) => _client.delete('/cars/$carId/media/$mediaId');

  Future<List<CarMedia>> reorderMedia(int carId, List<MapEntry<int, int>> idToSortOrder) async {
    final json = await _client.patch('/cars/$carId/media/reorder', body: {
      'media': idToSortOrder.map((e) => {'id': e.key, 'sort_order': e.value}).toList(),
    });
    return (json as List<dynamic>).map((e) => CarMedia.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---- Features ----

  Future<List<CarFeature>> listFeatures(int carId) async {
    final json = await _client.get('/cars/$carId/features');
    return (json as List<dynamic>).map((e) => CarFeature.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CarFeature> addFeature(int carId, String name, String? value) async {
    final json = await _client.post('/cars/$carId/features', body: {
      'feature_name': name,
      if (value != null && value.isNotEmpty) 'feature_value': value,
    });
    return CarFeature.fromJson(json as Map<String, dynamic>);
  }

  Future<CarFeature> updateFeature(int carId, int featureId, {String? name, String? value}) async {
    final json = await _client.patch('/cars/$carId/features/$featureId', body: {
      if (name != null) 'feature_name': name,
      if (value != null) 'feature_value': value,
    });
    return CarFeature.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteFeature(int carId, int featureId) => _client.delete('/cars/$carId/features/$featureId');

  // ---- Admin moderation ----

  Future<PaginatedList<CarRecord>> listAdminCars({int page = 1, int limit = 20, CarApprovalStatus? status}) async {
    final json = await _client.get('/admin/cars', query: {'page': page, 'limit': limit, 'status': status?.apiValue});
    return PaginatedList.fromJson(json as Map<String, dynamic>, CarRecord.fromJson);
  }

  Future<CarRecordDetail> getAdminCar(int carId) async {
    final json = await _client.get('/admin/cars/$carId');
    return CarRecordDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<CarRecordDetail> approveCar(int carId) async {
    final json = await _client.post('/admin/cars/$carId/approve');
    return CarRecordDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<CarRecordDetail> rejectCar(int carId, String reason) async {
    final json = await _client.post('/admin/cars/$carId/reject', body: {'reason': reason});
    return CarRecordDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<CarRecordDetail> verifyCar(int carId) async {
    final json = await _client.post('/admin/cars/$carId/verify');
    return CarRecordDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<CarRecordDetail> unverifyCar(int carId) async {
    final json = await _client.post('/admin/cars/$carId/unverify');
    return CarRecordDetail.fromJson(json as Map<String, dynamic>);
  }
}
