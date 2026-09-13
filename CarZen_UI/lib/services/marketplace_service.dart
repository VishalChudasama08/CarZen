import '../models/enums.dart';
import '../models/listing_models.dart';
import '../models/pagination.dart';
import 'api_client.dart';

/// Talks to `/v1/cars/{id}/listing*`, the public `/v1/listings*`, and
/// `/v1/cars/{id}/favorite` / `/v1/users/me/favorites`.
class MarketplaceService {
  MarketplaceService({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  // ---- Owner listing management ----

  Future<Listing> createListing(
    int carId, {
    required ListingType listingType,
    required String title,
    String? description,
    required num askingPrice,
    bool negotiable = true,
  }) async {
    final json = await _client.post('/cars/$carId/listing', body: {
      'listing_type': listingType.apiValue,
      'title': title,
      if (description != null && description.isNotEmpty) 'description': description,
      'asking_price': askingPrice,
      'negotiable': negotiable,
    });
    return Listing.fromJson(json as Map<String, dynamic>);
  }

  Future<Listing> getOwnedListing(int carId) async {
    final json = await _client.get('/cars/$carId/listing');
    return Listing.fromJson(json as Map<String, dynamic>);
  }

  Future<Listing> updateListing(int carId, Map<String, dynamic> partialFields) async {
    final json = await _client.patch('/cars/$carId/listing', body: partialFields);
    return Listing.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteListing(int carId) => _client.delete('/cars/$carId/listing');

  Future<Listing> publishListing(int carId) async {
    final json = await _client.post('/cars/$carId/listing/publish');
    return Listing.fromJson(json as Map<String, dynamic>);
  }

  Future<Listing> unpublishListing(int carId) async {
    final json = await _client.post('/cars/$carId/listing/unpublish');
    return Listing.fromJson(json as Map<String, dynamic>);
  }

  // ---- Public browsing (no auth required by the backend) ----

  Future<PaginatedList<Listing>> listPublicListings({
    int page = 1,
    int limit = 20,
    int? brandId,
    int? modelId,
    FuelType? fuelType,
    TransmissionType? transmission,
    String? city,
    String? state,
    num? minPrice,
    num? maxPrice,
  }) async {
    final json = await _client.get('/listings', query: {
      'page': page,
      'limit': limit,
      'brand_id': brandId,
      'model_id': modelId,
      'fuel_type': fuelType?.apiValue,
      'transmission': transmission?.apiValue,
      'city': city,
      'state': state,
      'min_price': minPrice,
      'max_price': maxPrice,
    });
    return PaginatedList.fromJson(json as Map<String, dynamic>, Listing.fromJson);
  }

  Future<ListingDetail> getPublicListing(int listingId) async {
    final json = await _client.get('/listings/$listingId');
    return ListingDetail.fromJson(json as Map<String, dynamic>);
  }

  // ---- Favorites ----

  Future<Favorite> addFavorite(int carId) async {
    final json = await _client.post('/cars/$carId/favorite');
    return Favorite.fromJson(json as Map<String, dynamic>);
  }

  Future<void> removeFavorite(int carId) => _client.delete('/cars/$carId/favorite');

  Future<List<Favorite>> listFavorites() async {
    final json = await _client.get('/users/me/favorites');
    return (json as List<dynamic>).map((e) => Favorite.fromJson(e as Map<String, dynamic>)).toList();
  }
}
