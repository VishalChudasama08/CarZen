import '../models/catalog_models.dart';
import '../models/pagination.dart';
import 'api_client.dart';

/// Talks to `/v1/car-brands`, `/v1/car-models`, `/v1/car-variants`.
///
/// Per the backend (`catalog.py`): every `GET` here is public (no token
/// needed), every write (`POST`/`PATCH`/`DELETE`) just needs any logged-in
/// user — there's no admin-only restriction on catalog data despite it
/// looking like reference data.
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
}
