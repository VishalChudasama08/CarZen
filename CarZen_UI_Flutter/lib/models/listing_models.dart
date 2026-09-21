import 'package:carzen_flutter/utils/json_parsing.dart';
import 'car_models.dart';
import 'enums.dart';

/// Mirrors `ListingResponse` — returned by the owner-facing listing
/// endpoints (`create/get/update/publish/unpublish`) and inside the
/// public `GET /v1/listings` list.
class Listing {
  final int id;
  final int carId;
  final int sellerId;
  final ListingType listingType;
  final String title;
  final String? description;
  final num askingPrice;
  final bool negotiable;
  final ListingStatus listingStatus;
  final int? viewsCount;

  const Listing({
    required this.id,
    required this.carId,
    required this.sellerId,
    required this.listingType,
    required this.title,
    this.description,
    required this.askingPrice,
    required this.negotiable,
    required this.listingStatus,
    this.viewsCount,
  });

  factory Listing.fromJson(Map<String, dynamic> json) => Listing(
        id: json['id'] as int,
        carId: json['car_id'] as int,
        sellerId: json['seller_id'] as int,
        listingType: ListingTypeX.fromApi(json['listing_type'] as String),
        title: json['title'] as String,
        description: json['description'] as String?,
        askingPrice: parseNum(json['asking_price']),
        negotiable: json['negotiable'] as bool? ?? true,
        listingStatus: ListingStatusX.fromApi(json['listing_status'] as String),
        viewsCount: json['views_count'] as int?,
      );
}

/// The car snapshot embedded inside a public listing (`ListingCarResponse`)
/// and inside a favorite (`marketplace_schema.CarDetailResponse` — a
/// near-identical shape missing only registration/VIN/owner fields, which
/// is why every field below is read defensively).
class ListingCar {
  final int id;
  final String brandName;
  final String? brandLogoUrl;
  final String modelName;
  final BodyType? bodyType;
  final String variantName;
  final FuelType fuelType;
  final TransmissionType transmission;
  final int manufacturingYear;
  final int? registrationYear;
  final num mileageKm;
  final num? engineCc;
  final num? horsepower;
  final String? color;
  final int? seatingCapacity;
  final int? ownerCount;
  final OwnershipType? ownershipType;
  final CarCondition condition;
  final String city;
  final String state;
  final num? expectedMarketPrice;
  final List<CarMedia> media;
  final List<CarFeature> features;

  const ListingCar({
    required this.id,
    required this.brandName,
    this.brandLogoUrl,
    required this.modelName,
    this.bodyType,
    required this.variantName,
    required this.fuelType,
    required this.transmission,
    required this.manufacturingYear,
    this.registrationYear,
    required this.mileageKm,
    this.engineCc,
    this.horsepower,
    this.color,
    this.seatingCapacity,
    this.ownerCount,
    this.ownershipType,
    required this.condition,
    required this.city,
    required this.state,
    this.expectedMarketPrice,
    required this.media,
    required this.features,
  });

  factory ListingCar.fromJson(Map<String, dynamic> json) {
    final brand = json['brand'] as Map<String, dynamic>? ?? const {};
    final model = json['model'] as Map<String, dynamic>? ?? const {};
    final variant = json['variant'] as Map<String, dynamic>? ?? const {};
    return ListingCar(
      id: json['id'] as int,
      brandName: brand['name'] as String? ?? '',
      brandLogoUrl: brand['logo_url'] as String?,
      modelName: model['name'] as String? ?? '',
      bodyType: model['body_type'] == null ? null : BodyTypeX.fromApi(model['body_type'] as String),
      variantName: variant['variant_name'] as String? ?? '',
      fuelType: FuelTypeX.fromApi(json['fuel_type'] as String),
      transmission: TransmissionTypeX.fromApi(json['transmission'] as String),
      manufacturingYear: json['manufacturing_year'] as int,
      registrationYear: json['registration_year'] as int?,
      mileageKm: parseNum(json['mileage_km']),
      engineCc: parseNumOrNull(json['engine_cc']),
      horsepower: parseNumOrNull(json['horsepower']),
      color: json['color'] as String?,
      seatingCapacity: json['seating_capacity'] as int?,
      ownerCount: json['owner_count'] as int?,
      ownershipType: json['ownership_type'] == null
          ? null
          : OwnershipTypeX.fromApi(json['ownership_type'] as String),
      condition: CarConditionX.fromApi(json['condition'] as String),
      city: json['city'] as String,
      state: json['state'] as String,
      expectedMarketPrice: parseNumOrNull(json['expected_market_price']),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) => CarMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => CarFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Mirrors `ListingResponseSecond` — returned by the *public*
/// `GET /v1/listings/{id}` detail endpoint. Includes the full [ListingCar]
/// snapshot, unlike the plain [Listing] used in the list view.
class ListingDetail extends Listing {
  final ListingCar car;

  const ListingDetail({
    required super.id,
    required super.carId,
    required super.sellerId,
    required super.listingType,
    required super.title,
    super.description,
    required super.askingPrice,
    required super.negotiable,
    required super.listingStatus,
    super.viewsCount,
    required this.car,
  });

  factory ListingDetail.fromJson(Map<String, dynamic> json) => ListingDetail(
        id: json['id'] as int,
        carId: json['car_id'] as int,
        sellerId: json['seller_id'] as int,
        listingType: ListingTypeX.fromApi(json['listing_type'] as String),
        title: json['title'] as String,
        description: json['description'] as String?,
        askingPrice: parseNum(json['asking_price']),
        negotiable: json['negotiable'] as bool? ?? true,
        listingStatus: ListingStatusX.fromApi(json['listing_status'] as String),
        viewsCount: json['views_count'] as int?,
        car: ListingCar.fromJson(json['car'] as Map<String, dynamic>),
      );
}

/// Mirrors `FavoriteResponse` (`/v1/cars/{id}/favorite`, `/v1/users/me/favorites`).
class Favorite {
  final int id;
  final int userId;
  final int carId;
  final ListingCar car;

  const Favorite({required this.id, required this.userId, required this.carId, required this.car});

  factory Favorite.fromJson(Map<String, dynamic> json) => Favorite(
        id: json['id'] as int,
        userId: json['user_id'] as int,
        carId: json['car_id'] as int,
        car: ListingCar.fromJson(json['car'] as Map<String, dynamic>),
      );
}
