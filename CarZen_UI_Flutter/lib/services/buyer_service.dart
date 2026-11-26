import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

/// Buyer-side endpoints: `/v1/buyer/*`.
class BuyerService {
  BuyerService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<BuyerDashboard> dashboard() async {
    final json = await _client.get('/buyer/dashboard');
    return BuyerDashboard.fromJson(json as Map<String, dynamic>);
  }

  /// Opens a listing as a signed-in buyer, which also records it in
  /// "Recently viewed".
  Future<ListingDetail> viewListing(int listingId) async {
    final json = await _client.get('/buyer/listings/$listingId');
    return ListingDetail.fromJson(json as Map<String, dynamic>);
  }

  Future<List<RecentlyViewed>> recentlyViewed({int limit = 20}) async {
    final json = await _client.get('/buyer/recently-viewed', query: {'limit': limit});
    return (json as List<dynamic>).map((e) => RecentlyViewed.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PaginatedList<TransactionRecord>> purchases({int page = 1, int limit = 10, String? status}) async {
    final json = await _client.get('/buyer/purchases', query: {'page': page, 'limit': limit, 'transaction_status': status});
    return PaginatedList.fromJson(json as Map<String, dynamic>, TransactionRecord.fromPurchaseJson);
  }
}
