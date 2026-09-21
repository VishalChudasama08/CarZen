import 'package:carzen_flutter/utils/json_parsing.dart';
import 'enums.dart';

/// Mirrors `CarMediaResponse` (`/v1/cars/{id}/media`).
class CarMedia {
  final int id;
  final MediaType mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String? fileName;
  final int? fileSize;
  final int sortOrder;
  final bool isPrimary;

  const CarMedia({
    required this.id,
    required this.mediaType,
    required this.mediaUrl,
    this.thumbnailUrl,
    this.fileName,
    this.fileSize,
    required this.sortOrder,
    required this.isPrimary,
  });

  factory CarMedia.fromJson(Map<String, dynamic> json) => CarMedia(
        id: json['id'] as int,
        mediaType: MediaTypeX.fromApi(json['media_type'] as String),
        mediaUrl: json['media_url'] as String,
        thumbnailUrl: json['thumbnail_url'] as String?,
        fileName: json['file_name'] as String?,
        fileSize: json['file_size'] as int?,
        sortOrder: json['sort_order'] as int? ?? 0,
        isPrimary: json['is_primary'] as bool? ?? false,
      );

  /// Full URL for display — media_url from the backend is a relative
  /// `/uploads/...` path served as static files by FastAPI.
  String absoluteUrl(String baseUrl) => mediaUrl.startsWith('http') ? mediaUrl : '$baseUrl$mediaUrl';
}

extension CarMediaListX on List<CarMedia> {
  /// Best image for a card/thumbnail: the primary image, otherwise the first
  /// image. Videos and documents are never used (they can't be shown by
  /// `Image.network`).
  CarMedia? get cover {
    final images = where((m) => m.mediaType == MediaType.image).toList();
    if (images.isEmpty) return null;
    for (final image in images) {
      if (image.isPrimary) return image;
    }
    return images.first;
  }
}

/// Mirrors `CarFeatureResponse` (`/v1/cars/{id}/features`).
class CarFeature {
  final int id;
  final int? carId;
  final String featureName;
  final String? featureValue;

  const CarFeature({
    required this.id,
    this.carId,
    required this.featureName,
    this.featureValue,
  });

  factory CarFeature.fromJson(Map<String, dynamic> json) => CarFeature(
        id: json['id'] as int,
        carId: json['car_id'] as int?,
        featureName: json['feature_name'] as String,
        featureValue: json['feature_value'] as String?,
      );
}

class _BrandSummary {
  final int id;
  final String name;
  final String slug;
  const _BrandSummary({required this.id, required this.name, required this.slug});
  factory _BrandSummary.fromJson(Map<String, dynamic> json) =>
      _BrandSummary(id: json['id'] as int, name: json['name'] as String, slug: json['slug'] as String);
}

class _ModelSummary {
  final int id;
  final int brandId;
  final String name;
  final String slug;
  const _ModelSummary({required this.id, required this.brandId, required this.name, required this.slug});
  factory _ModelSummary.fromJson(Map<String, dynamic> json) => _ModelSummary(
      id: json['id'] as int,
      brandId: json['brand_id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String);
}

class _VariantSummary {
  final int id;
  final int modelId;
  final String variantName;
  final FuelType fuelType;
  final TransmissionType transmission;
  const _VariantSummary({
    required this.id,
    required this.modelId,
    required this.variantName,
    required this.fuelType,
    required this.transmission,
  });
  factory _VariantSummary.fromJson(Map<String, dynamic> json) => _VariantSummary(
        id: json['id'] as int,
        modelId: json['model_id'] as int,
        variantName: json['variant_name'] as String,
        fuelType: FuelTypeX.fromApi(json['fuel_type'] as String),
        transmission: TransmissionTypeX.fromApi(json['transmission'] as String),
      );
}

class OwnerSummary {
  final int id;
  final String firstName;
  final String? lastName;
  final String username;
  const OwnerSummary({required this.id, required this.firstName, this.lastName, required this.username});
  factory OwnerSummary.fromJson(Map<String, dynamic> json) => OwnerSummary(
        id: json['id'] as int,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String?,
        username: json['username'] as String,
      );
  String get fullName => [firstName, lastName].where((e) => e != null && e!.isNotEmpty).join(' ');
}

/// Mirrors `CarResponse` — the shape returned by `POST /v1/cars`,
/// `GET /v1/cars` (list, owner-scoped), `PATCH /v1/cars/{id}`, and the
/// admin equivalents.
class CarRecord {
  final int id;
  final int variantId;
  final int ownerId;
  final String? registrationNumber;
  final String? vinNumber;
  final int manufacturingYear;
  final int? registrationYear;
  final FuelType fuelType;
  final TransmissionType transmission;
  final num mileageKm;
  final String? color;
  final CarCondition condition;
  final String city;
  final String state;
  final num? expectedMarketPrice;
  final bool isVerified;
  final CarApprovalStatus approvalStatus;

  const CarRecord({
    required this.id,
    required this.variantId,
    required this.ownerId,
    this.registrationNumber,
    this.vinNumber,
    required this.manufacturingYear,
    this.registrationYear,
    required this.fuelType,
    required this.transmission,
    required this.mileageKm,
    this.color,
    required this.condition,
    required this.city,
    required this.state,
    this.expectedMarketPrice,
    required this.isVerified,
    required this.approvalStatus,
  });

  factory CarRecord.fromJson(Map<String, dynamic> json) => CarRecord(
        id: json['id'] as int,
        variantId: json['variant_id'] as int,
        ownerId: json['owner_id'] as int,
        registrationNumber: json['registration_number'] as String?,
        vinNumber: json['vin_number'] as String?,
        manufacturingYear: json['manufacturing_year'] as int,
        registrationYear: json['registration_year'] as int?,
        fuelType: FuelTypeX.fromApi(json['fuel_type'] as String),
        transmission: TransmissionTypeX.fromApi(json['transmission'] as String),
        mileageKm: parseNum(json['mileage_km']),
        color: json['color'] as String?,
        condition: CarConditionX.fromApi(json['condition'] as String),
        city: json['city'] as String,
        state: json['state'] as String,
        expectedMarketPrice: parseNumOrNull(json['expected_market_price']),
        isVerified: json['is_verified'] as bool? ?? false,
        approvalStatus: CarApprovalStatusX.fromApi(json['approval_status'] as String),
      );
}

/// Mirrors `CarDetailResponse` — returned by `GET /v1/cars/{id}` and the
/// admin equivalent. Adds the fields + nested brand/model/variant/owner and
/// media/features that the list endpoint doesn't include.
class CarRecordDetail extends CarRecord {
  final num? engineCc;
  final num? horsepower;
  final int? seatingCapacity;
  final int? ownerCount;
  final OwnershipType? ownershipType;
  final String? insuranceCompany;
  final String? insuranceType;
  final String? insuranceExpiry;
  final String? rcStatus;
  final String country;
  final String? postalCode;
  final String? description;
  final String? rejectionReason;
  final String brandName;
  final String modelName;
  final String variantName;
  final OwnerSummary owner;
  final List<CarMedia> media;
  final List<CarFeature> features;

  CarRecordDetail({
    required super.id,
    required super.variantId,
    required super.ownerId,
    super.registrationNumber,
    super.vinNumber,
    required super.manufacturingYear,
    super.registrationYear,
    required super.fuelType,
    required super.transmission,
    required super.mileageKm,
    super.color,
    required super.condition,
    required super.city,
    required super.state,
    super.expectedMarketPrice,
    required super.isVerified,
    required super.approvalStatus,
    this.engineCc,
    this.horsepower,
    this.seatingCapacity,
    this.ownerCount,
    this.ownershipType,
    this.insuranceCompany,
    this.insuranceType,
    this.insuranceExpiry,
    this.rcStatus,
    required this.country,
    this.postalCode,
    this.description,
    this.rejectionReason,
    required this.brandName,
    required this.modelName,
    required this.variantName,
    required this.owner,
    required this.media,
    required this.features,
  });

  factory CarRecordDetail.fromJson(Map<String, dynamic> json) {
    final brand = _BrandSummary.fromJson(json['brand'] as Map<String, dynamic>);
    final model = _ModelSummary.fromJson(json['model'] as Map<String, dynamic>);
    final variant = _VariantSummary.fromJson(json['variant'] as Map<String, dynamic>);
    return CarRecordDetail(
      id: json['id'] as int,
      variantId: json['variant_id'] as int,
      ownerId: json['owner_id'] as int,
      registrationNumber: json['registration_number'] as String?,
      vinNumber: json['vin_number'] as String?,
      manufacturingYear: json['manufacturing_year'] as int,
      registrationYear: json['registration_year'] as int?,
      fuelType: FuelTypeX.fromApi(json['fuel_type'] as String),
      transmission: TransmissionTypeX.fromApi(json['transmission'] as String),
      mileageKm: parseNum(json['mileage_km']),
      color: json['color'] as String?,
      condition: CarConditionX.fromApi(json['condition'] as String),
      city: json['city'] as String,
      state: json['state'] as String,
      expectedMarketPrice: parseNumOrNull(json['expected_market_price']),
      isVerified: json['is_verified'] as bool? ?? false,
      approvalStatus: CarApprovalStatusX.fromApi(json['approval_status'] as String),
      engineCc: parseNumOrNull(json['engine_cc']),
      horsepower: parseNumOrNull(json['horsepower']),
      seatingCapacity: json['seating_capacity'] as int?,
      ownerCount: json['owner_count'] as int?,
      ownershipType:
          json['ownership_type'] == null ? null : OwnershipTypeX.fromApi(json['ownership_type'] as String),
      insuranceCompany: json['insurance_company'] as String?,
      insuranceType: json['insurance_type'] as String?,
      insuranceExpiry: json['insurance_expiry'] as String?,
      rcStatus: json['rc_status'] as String?,
      country: json['country'] as String? ?? 'India',
      postalCode: json['postal_code'] as String?,
      description: json['description'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      brandName: brand.name,
      modelName: model.name,
      variantName: variant.variantName,
      owner: OwnerSummary.fromJson(json['owner'] as Map<String, dynamic>),
      media: (json['media'] as List<dynamic>? ?? [])
          .map((e) => CarMedia.fromJson(e as Map<String, dynamic>))
          .toList(),
      features: (json['features'] as List<dynamic>? ?? [])
          .map((e) => CarFeature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
