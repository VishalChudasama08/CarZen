import 'package:carzen_flutter/models/enums.dart';

/// Every filter `GET /v1/listings` understands that the Browse page exposes.
/// Immutable: the filter panel builds a new instance on "Apply".
class ListingFilters {
  final String? search;
  final int? brandId;
  final int? modelId;
  final FuelType? fuelType;
  final TransmissionType? transmission;
  final CarCondition? condition;
  final num? minPrice;
  final num? maxPrice;
  final int? minYear;
  final int? maxYear;
  final num? maxMileage;
  final String? city;
  final ListingSort sort;

  const ListingFilters({
    this.search,
    this.brandId,
    this.modelId,
    this.fuelType,
    this.transmission,
    this.condition,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.maxMileage,
    this.city,
    this.sort = ListingSort.newest,
  });

  ListingFilters withSearch(String? value) {
    final trimmed = value?.trim();
    return ListingFilters(
      search: (trimmed == null || trimmed.isEmpty) ? null : trimmed,
      brandId: brandId,
      modelId: modelId,
      fuelType: fuelType,
      transmission: transmission,
      condition: condition,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minYear: minYear,
      maxYear: maxYear,
      maxMileage: maxMileage,
      city: city,
      sort: sort,
    );
  }

  ListingFilters withSort(ListingSort value) => ListingFilters(
        search: search,
        brandId: brandId,
        modelId: modelId,
        fuelType: fuelType,
        transmission: transmission,
        condition: condition,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minYear: minYear,
        maxYear: maxYear,
        maxMileage: maxMileage,
        city: city,
        sort: value,
      );

  /// Keeps search + sort but drops every panel filter.
  ListingFilters clearedPanel() => ListingFilters(search: search, sort: sort);

  /// Number of panel filters currently applied (shown on the Filters button).
  int get activeCount => [
        brandId,
        modelId,
        fuelType,
        transmission,
        condition,
        minPrice,
        maxPrice,
        minYear,
        maxYear,
        maxMileage,
        city,
      ].where((v) => v != null).length;
}
