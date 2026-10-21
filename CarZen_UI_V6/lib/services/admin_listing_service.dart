import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

/// Admin moderation of marketplace listings (`/v1/admin/listings*`).
class AdminListingService {
  AdminListingService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<PaginatedList<Listing>> list({int page = 1, int limit = 10, String? status, int? sellerId, int? carId}) async {
    final json = await _client.get('/admin/listings',
        query: {'page': page, 'limit': limit, 'status': status, 'seller_id': sellerId, 'car_id': carId});
    return PaginatedList.fromJson(json as Map<String, dynamic>, Listing.fromJson);
  }

  Future<Listing> approve(int id, {String? reason}) => _action(id, 'approve', reason);
  Future<Listing> reject(int id, {String? reason}) => _action(id, 'reject', reason);
  Future<Listing> suspend(int id, {String? reason}) => _action(id, 'suspend', reason);

  Future<void> delete(int id) => _client.delete('/admin/listings/$id');

  Future<Listing> _action(int id, String action, String? reason) async {
    final json = await _client.patch('/admin/listings/$id/$action', body: {
      if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
    });
    return Listing.fromJson(json as Map<String, dynamic>);
  }
}
