import 'package:carzen_flutter/models/enums.dart';

/// Every filter/sort `GET /v1/listings` supports, kept as one immutable value
/// so the Browse page, the filter panel and the "active filter" chips can't
/// drift apart.
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

  static const Object _keep = Object();

  /// Pass `null` explicitly to clear a field; omit it to keep the current value.
  ListingFilters copyWith({
    Object? search = _keep,
    Object? brandId = _keep,
    Object? modelId = _keep,
    Object? fuelType = _keep,
    Object? transmission = _keep,
    Object? condition = _keep,
    Object? minPrice = _keep,
    Object? maxPrice = _keep,
    Object? minYear = _keep,
    Object? maxYear = _keep,
    Object? maxMileage = _keep,
    Object? city = _keep,
    ListingSort? sort,
  }) {
    return ListingFilters(
      search: identical(search, _keep) ? this.search : search as String?,
      brandId: identical(brandId, _keep) ? this.brandId : brandId as int?,
      modelId: identical(modelId, _keep) ? this.modelId : modelId as int?,
      fuelType: identical(fuelType, _keep) ? this.fuelType : fuelType as FuelType?,
      transmission: identical(transmission, _keep) ? this.transmission : transmission as TransmissionType?,
      condition: identical(condition, _keep) ? this.condition : condition as CarCondition?,
      minPrice: identical(minPrice, _keep) ? this.minPrice : minPrice as num?,
      maxPrice: identical(maxPrice, _keep) ? this.maxPrice : maxPrice as num?,
      minYear: identical(minYear, _keep) ? this.minYear : minYear as int?,
      maxYear: identical(maxYear, _keep) ? this.maxYear : maxYear as int?,
      maxMileage: identical(maxMileage, _keep) ? this.maxMileage : maxMileage as num?,
      city: identical(city, _keep) ? this.city : city as String?,
      sort: sort ?? this.sort,
    );
  }

  /// Search text and sort order are edited in the toolbar, everything else in
  /// the filter panel; "Reset" only clears the latter.
  ListingFilters clearedPanelFilters() => ListingFilters(search: search, sort: sort);

  bool get hasPriceFilter => minPrice != null || maxPrice != null;
  bool get hasYearFilter => minYear != null || maxYear != null;

  /// How many panel filters are active (drives the badge on the Filters button).
  int get activeCount =>
      (brandId != null ? 1 : 0) +
      (fuelType != null ? 1 : 0) +
      (transmission != null ? 1 : 0) +
      (condition != null ? 1 : 0) +
      (hasPriceFilter ? 1 : 0) +
      (hasYearFilter ? 1 : 0) +
      (maxMileage != null ? 1 : 0) +
      (city != null && city!.isNotEmpty ? 1 : 0);
}
