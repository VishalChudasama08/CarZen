import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:carzen_flutter/services/api_client.dart';

/// The backend's price model (`/v1/car-price-predict`). Estimates are saved
/// to the signed-in user's history.
class PriceService {
  PriceService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<PriceEstimate> estimate({
    required String name,
    required int year,
    required int kmDriven,
    required String fuel,
    required String sellerType,
    required String transmission,
    required String owner,
    required num mileage,
    required num engine,
    required num maxPower,
    required int seats,
  }) async {
    final json = await _client.post('/car-price-predict', body: {
      'name': name,
      'year': year,
      'km_driven': kmDriven,
      'fuel': fuel,
      'seller_type': sellerType,
      'transmission': transmission,
      'owner': owner,
      'mileage': mileage,
      'engine': engine,
      'max_power': maxPower,
      'seats': seats,
    });
    return PriceEstimate.fromJson(json as Map<String, dynamic>);
  }

  Future<PaginatedList<PriceEstimate>> history({int page = 1, int limit = 10}) async {
    final json = await _client.get('/car-price-predict', query: {'page': page, 'limit': limit});
    return PaginatedList.fromJson(json as Map<String, dynamic>, PriceEstimate.fromJson);
  }
}
