import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

enum TransactionScope { all, buy, sell }

/// Completed and in-progress sales (`/v1/transactions`).
class TransactionService {
  TransactionService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<PaginatedList<TransactionRecord>> list({TransactionScope scope = TransactionScope.all, int page = 1, int limit = 10, String? status}) async {
    final path = switch (scope) {
      TransactionScope.all => '/transactions',
      TransactionScope.buy => '/transactions/buy',
      TransactionScope.sell => '/transactions/sell',
    };
    final json = await _client.get(path, query: {'page': page, 'limit': limit, 'status': status});
    return PaginatedList.fromJson(json as Map<String, dynamic>, TransactionRecord.fromJson);
  }

  Future<PaginatedList<TransactionRecord>> adminList({int page = 1, int limit = 10, String? status, int? buyerId, int? sellerId}) async {
    final json = await _client.get('/admin/transactions',
        query: {'page': page, 'limit': limit, 'status': status, 'buyer_id': buyerId, 'seller_id': sellerId});
    return PaginatedList.fromJson(json as Map<String, dynamic>, TransactionRecord.fromJson);
  }
}
