import 'package:carzen_flutter/models/catalog_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'api_client.dart';

/// Talks to `/v1/car-brands`, `/v1/car-models`, `/v1/car-variants`.
///
/// Every `GET` here is public; every write is admin-only (`catalog.py`).
class CatalogService {
  CatalogService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  // ---- Brands ----

  Future<PaginatedList<CatalogBrand>> listBrands({int page = 1, int limit = 50, String? search, bool? isActive}) async {
    final json = await _client.get('/car-brands', query: {
      'page': page,
      'limit': limit,
      'search': search,
      'is_active': isActive,
    });
    return PaginatedList.fromJson(json as Map<String, dynamic>, CatalogBrand.fromJson);
  }

  Future<CatalogBrand> getBrand(int id) async {
    final json = await _client.get('/car-brands/$id');
    return CatalogBrand.fromJson(json as Map<String, dynamic>);
  }

  Future<CatalogBrand> createBrand({
    required String name,
    required String slug,
    String? country,
    String? logoUrl,
    String? description,
  }) async {
    final json = await _client.post('/car-brands', body: {
      'name': name,
      'slug': slug,
      'country': country,
      'logo_url': logoUrl,
      'description': description,
      'is_active': true,
    });
    return CatalogBrand.fromJson(json as Map<String, dynamic>);
  }

  Future<CatalogBrand> setBrandStatus(int id, bool isActive) async {
    final json = await _client.patch('/car-brands/$id/status', body: {'is_active': isActive});
    return CatalogBrand.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteBrand(int id) => _client.delete('/car-brands/$id');

  // ---- Models ----

  Future<PaginatedList<CatalogCarModel>> listModelsForBrand(int brandId, {int page = 1, int limit = 100}) async {
    final json = await _client.get('/car-brands/$brandId/models', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, CatalogCarModel.fromJson);
  }

  Future<PaginatedList<CatalogCarModel>> listModels({int page = 1, int limit = 50, String? search, int? brandId}) async {
    final json = await _client.get('/car-models', query: {'page': page, 'limit': limit, 'search': search, 'brand_id': brandId});
    return PaginatedList.fromJson(json as Map<String, dynamic>, CatalogCarModel.fromJson);
  }

  // ---- Variants ----

  Future<PaginatedList<CatalogVariant>> listVariantsForModel(int modelId, {int page = 1, int limit = 100}) async {
    final json = await _client.get('/car-models/$modelId/variants', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, CatalogVariant.fromJson);
  }

  Future<CatalogVariant> getVariant(int id) async {
    final json = await _client.get('/car-variants/$id');
    return CatalogVariant.fromJson(json as Map<String, dynamic>);
  }

  // ---- Admin catalogue management ----

  Future<CatalogBrand> updateBrand(int id, Map<String, dynamic> fields) async {
    final json = await _client.patch('/car-brands/$id', body: fields);
    return CatalogBrand.fromJson(json as Map<String, dynamic>);
  }

  Future<CatalogCarModel> createModel({
    required int brandId,
    required String name,
    required String slug,
    BodyType? bodyType,
    int? seatingCapacity,
    String? description,
  }) async {
    final json = await _client.post('/car-models', body: {
      'brand_id': brandId,
      'name': name,
      'slug': slug,
      'body_type': bodyType?.apiValue,
      'seating_capacity': seatingCapacity,
      'description': description,
      'is_active': true,
    });
    return CatalogCarModel.fromJson(json as Map<String, dynamic>);
  }

  Future<CatalogCarModel> updateModel(int id, Map<String, dynamic> fields) async {
    final json = await _client.patch('/car-models/$id', body: fields);
    return CatalogCarModel.fromJson(json as Map<String, dynamic>);
  }

  Future<CatalogCarModel> setModelStatus(int id, bool isActive) async {
    final json = await _client.patch('/car-models/$id/status', body: {'is_active': isActive});
    return CatalogCarModel.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteModel(int id) => _client.delete('/car-models/$id');

  Future<CatalogVariant> createVariant({
    required int modelId,
    required String name,
    required FuelType fuelType,
    required TransmissionType transmission,
    num? engineCc,
    num? horsepower,
    int? seatingCapacity,
    num? exShowroomPrice,
  }) async {
    final json = await _client.post('/car-variants', body: {
      'model_id': modelId,
      'variant_name': name,
      'fuel_type': fuelType.apiValue,
      'transmission': transmission.apiValue,
      'engine_cc': engineCc,
      'horsepower': horsepower,
      'seating_capacity': seatingCapacity,
      'ex_showroom_price': exShowroomPrice,
    });
    return CatalogVariant.fromJson(json as Map<String, dynamic>);
  }

  Future<CatalogVariant> updateVariant(int id, Map<String, dynamic> fields) async {
    final json = await _client.patch('/car-variants/$id', body: fields);
    return CatalogVariant.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteVariant(int id) => _client.delete('/car-variants/$id');
}
