import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/models/service_models.dart';
import 'api_client.dart';

/// Talks to the service catalog routes in `service_catalog.py`:
/// the public `GET /v1/services*` and the admin `/v1/admin/services*`.
class ServiceCatalogApi {
  ServiceCatalogApi({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  // ---- Public / customer ----

  /// `GET /v1/services` — active services only, cheapest first, optional name search.
  Future<PaginatedList<ServiceOffering>> list({int page = 1, int limit = 12, String? search}) async {
    final json = await _client.get('/services', query: {
      'page': page,
      'limit': limit,
      'search': (search == null || search.trim().isEmpty) ? null : search.trim(),
    });
    return PaginatedList.fromJson(json as Map<String, dynamic>, ServiceOffering.fromJson);
  }

  /// `GET /v1/services/{id}` — 404 when the service is inactive or deleted.
  Future<ServiceOffering> get(int id) async {
    final json = await _client.get('/services/$id');
    return ServiceOffering.fromJson(json as Map<String, dynamic>);
  }

  // ---- Admin ----

  /// `GET /v1/admin/services` — [status] is `active` or `inactive`.
  Future<PaginatedList<ServiceOffering>> adminList({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    final json = await _client.get('/admin/services', query: {
      'page': page,
      'limit': limit,
      'status': status,
      'search': (search == null || search.trim().isEmpty) ? null : search.trim(),
    });
    return PaginatedList.fromJson(json as Map<String, dynamic>, ServiceOffering.fromJson);
  }

  Future<ServiceOffering> adminGet(int id) async {
    final json = await _client.get('/admin/services/$id');
    return ServiceOffering.fromJson(json as Map<String, dynamic>);
  }

  /// `POST /v1/admin/services` (`ServiceCreate`). New services start `active`.
  Future<ServiceOffering> adminCreate({
    required String name,
    String? description,
    required num price,
    int? durationMinutes,
    String? imageUrl,
  }) async {
    final json = await _client.post('/admin/services', body: {
      'name': name,
      if (description != null && description.isNotEmpty) 'description': description,
      'price': price,
      if (durationMinutes != null) 'duration_minutes': durationMinutes,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    });
    return ServiceOffering.fromJson(json as Map<String, dynamic>);
  }

  /// `PATCH /v1/admin/services/{id}` (`ServiceUpdate`). Only the keys passed are changed.
  Future<ServiceOffering> adminUpdate(int id, Map<String, dynamic> fields) async {
    final json = await _client.patch('/admin/services/$id', body: fields);
    return ServiceOffering.fromJson(json as Map<String, dynamic>);
  }

  Future<ServiceOffering> adminActivate(int id) async {
    final json = await _client.post('/admin/services/$id/activate');
    return ServiceOffering.fromJson(json as Map<String, dynamic>);
  }

  Future<ServiceOffering> adminDeactivate(int id) async {
    final json = await _client.post('/admin/services/$id/deactivate');
    return ServiceOffering.fromJson(json as Map<String, dynamic>);
  }

  /// `DELETE /v1/admin/services/{id}` — a soft delete (204).
  Future<void> adminDelete(int id) => _client.delete('/admin/services/$id');
}
