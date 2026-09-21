import 'package:carzen_flutter/utils/json_parsing.dart';
import 'enums.dart';

/// Mirrors `CarBrandResponse` (`GET/POST/PATCH /v1/car-brands`).
class CatalogBrand {
  final int id;
  final String name;
  final String slug;
  final String? country;
  final String? logoUrl;
  final String? description;
  final bool isActive;

  const CatalogBrand({
    required this.id,
    required this.name,
    required this.slug,
    this.country,
    this.logoUrl,
    this.description,
    required this.isActive,
  });

  factory CatalogBrand.fromJson(Map<String, dynamic> json) => CatalogBrand(
        id: json['id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        country: json['country'] as String?,
        logoUrl: json['logo_url'] as String?,
        description: json['description'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );
}

/// Mirrors `CarModelResponse` (`GET/POST/PATCH /v1/car-models`).
class CatalogCarModel {
  final int id;
  final int brandId;
  final String name;
  final String slug;
  final BodyType? bodyType;
  final int? seatingCapacity;
  final String? description;
  final bool isActive;

  const CatalogCarModel({
    required this.id,
    required this.brandId,
    required this.name,
    required this.slug,
    this.bodyType,
    this.seatingCapacity,
    this.description,
    required this.isActive,
  });

  factory CatalogCarModel.fromJson(Map<String, dynamic> json) => CatalogCarModel(
        id: json['id'] as int,
        brandId: json['brand_id'] as int,
        name: json['name'] as String,
        slug: json['slug'] as String,
        bodyType: json['body_type'] == null ? null : BodyTypeX.fromApi(json['body_type'] as String),
        seatingCapacity: json['seating_capacity'] as int?,
        description: json['description'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );
}

/// Mirrors `CarVariantResponse` (`GET/POST/PATCH /v1/car-variants`).
class CatalogVariant {
  final int id;
  final int modelId;
  final String variantName;
  final FuelType fuelType;
  final TransmissionType transmission;
  final num? engineCc;
  final num? horsepower;
  final int? seatingCapacity;
  final num? exShowroomPrice;

  const CatalogVariant({
    required this.id,
    required this.modelId,
    required this.variantName,
    required this.fuelType,
    required this.transmission,
    this.engineCc,
    this.horsepower,
    this.seatingCapacity,
    this.exShowroomPrice,
  });

  factory CatalogVariant.fromJson(Map<String, dynamic> json) => CatalogVariant(
        id: json['id'] as int,
        modelId: json['model_id'] as int,
        variantName: json['variant_name'] as String,
        fuelType: FuelTypeX.fromApi(json['fuel_type'] as String),
        transmission: TransmissionTypeX.fromApi(json['transmission'] as String),
        engineCc: parseNumOrNull(json['engine_cc']),
        horsepower: parseNumOrNull(json['horsepower']),
        seatingCapacity: json['seating_capacity'] as int?,
        exShowroomPrice: parseNumOrNull(json['ex_showroom_price']),
      );
}
