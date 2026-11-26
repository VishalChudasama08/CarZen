import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

/// Car reviews. Anyone can read a car's reviews; only buyers who completed
/// a purchase of that car can write one (enforced by the backend).
class ReviewService {
  ReviewService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<PaginatedList<ReviewRecord>> forCar(int carId, {int page = 1, int limit = 5}) async {
    final json = await _client.get('/cars/$carId/reviews', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, ReviewRecord.fromJson);
  }

  Future<PaginatedList<ReviewRecord>> mine({int page = 1, int limit = 10}) async {
    final json = await _client.get('/reviews/my', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, ReviewRecord.fromJson);
  }

  Future<ReviewRecord> create({required int carId, int? transactionId, required int rating, String? title, String? text}) async {
    final json = await _client.post('/reviews', body: {
      'car_id': carId,
      'transaction_id': ?transactionId,
      'rating': rating,
      if (title != null && title.trim().isNotEmpty) 'title': title.trim(),
      if (text != null && text.trim().isNotEmpty) 'review_text': text.trim(),
    });
    return ReviewRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<ReviewRecord> update(int id, {int? rating, String? title, String? text}) async {
    final json = await _client.patch('/reviews/$id', body: {
      'rating': ?rating,
      'title': ?title,
      'review_text': ?text,
    });
    return ReviewRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _client.delete('/reviews/$id');

  // ---- Admin ----

  Future<PaginatedList<ReviewRecord>> adminList({int page = 1, int limit = 10, bool? visible, int? carId}) async {
    final json = await _client.get('/admin/reviews', query: {'page': page, 'limit': limit, 'is_visible': visible, 'car_id': carId});
    return PaginatedList.fromJson(json as Map<String, dynamic>, ReviewRecord.fromJson);
  }

  Future<ReviewRecord> adminSetVisible(int id, bool visible) async {
    final json = await _client.patch('/admin/reviews/$id/visibility', body: {'is_visible': visible});
    return ReviewRecord.fromJson(json as Map<String, dynamic>);
  }

  Future<void> adminDelete(int id) => _client.delete('/admin/reviews/$id');
}
