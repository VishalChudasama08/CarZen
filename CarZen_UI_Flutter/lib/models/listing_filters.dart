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

  static const Object _sentinel = Object();

  ListingFilters copyWith({
    Object? search = _sentinel,
    Object? brandId = _sentinel,
    Object? modelId = _sentinel,
    Object? fuelType = _sentinel,
    Object? transmission = _sentinel,
    Object? condition = _sentinel,
    Object? minPrice = _sentinel,
    Object? maxPrice = _sentinel,
    Object? minYear = _sentinel,
    Object? maxYear = _sentinel,
    Object? maxMileage = _sentinel,
    Object? city = _sentinel,
    ListingSort? sort,
  }) =>
      ListingFilters(
        search: identical(search, _sentinel) ? this.search : search as String?,
        brandId: identical(brandId, _sentinel) ? this.brandId : brandId as int?,
        modelId: identical(modelId, _sentinel) ? this.modelId : modelId as int?,
        fuelType: identical(fuelType, _sentinel) ? this.fuelType : fuelType as FuelType?,
        transmission: identical(transmission, _sentinel) ? this.transmission : transmission as TransmissionType?,
        condition: identical(condition, _sentinel) ? this.condition : condition as CarCondition?,
        minPrice: identical(minPrice, _sentinel) ? this.minPrice : minPrice as num?,
        maxPrice: identical(maxPrice, _sentinel) ? this.maxPrice : maxPrice as num?,
        minYear: identical(minYear, _sentinel) ? this.minYear : minYear as int?,
        maxYear: identical(maxYear, _sentinel) ? this.maxYear : maxYear as int?,
        maxMileage: identical(maxMileage, _sentinel) ? this.maxMileage : maxMileage as num?,
        city: identical(city, _sentinel) ? this.city : city as String?,
        sort: sort ?? this.sort,
      );

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

  /// Alias for clearedPanel.
  ListingFilters clearedPanelFilters() => clearedPanel();

  /// Number of panel filters currently applied (shown on the Filters button).
  /// Groups price range (minPrice/maxPrice) and year range (minYear/maxYear).
  int get activeCount {
    var count = 0;
    if (brandId != null) count++;
    if (modelId != null) count++;
    if (fuelType != null) count++;
    if (transmission != null) count++;
    if (condition != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minYear != null || maxYear != null) count++;
    if (maxMileage != null) count++;
    if (city != null) count++;
    return count;
  }

  /// URL query parameters for the Browse page (only values that are set).
  Map<String, String> toQuery() => {
        if (search != null) 'search': search!,
        if (brandId != null) 'brandId': '$brandId',
        if (modelId != null) 'modelId': '$modelId',
        if (fuelType != null) 'fuelType': fuelType!.apiValue,
        if (transmission != null) 'transmission': transmission!.apiValue,
        if (condition != null) 'condition': condition!.apiValue,
        if (minPrice != null) 'minPrice': '${minPrice!.round()}',
        if (maxPrice != null) 'maxPrice': '${maxPrice!.round()}',
        if (minYear != null) 'minYear': '$minYear',
        if (maxYear != null) 'maxYear': '$maxYear',
        if (maxMileage != null) 'maxKm': '${maxMileage!.round()}',
        if (city != null) 'city': city!,
        if (sort != ListingSort.newest) 'sort': sort.apiValue,
      };

  /// Reads [toQuery] back; unknown or malformed values are ignored.
  factory ListingFilters.fromQuery(Map<String, String> q) {
    T? pick<T>(List<T> values, String? raw, String Function(T) api) {
      if (raw == null) return null;
      for (final v in values) {
        if (api(v) == raw) return v;
      }
      return null;
    }

    String? text(String key) {
      final v = q[key]?.trim();
      return (v == null || v.isEmpty) ? null : v;
    }

    return ListingFilters(
      search: text('search'),
      brandId: int.tryParse(q['brandId'] ?? ''),
      modelId: int.tryParse(q['modelId'] ?? ''),
      fuelType: pick(FuelType.values, q['fuelType'], (v) => v.apiValue),
      transmission: pick(TransmissionType.values, q['transmission'], (v) => v.apiValue),
      condition: pick(CarCondition.values, q['condition'], (v) => v.apiValue),
      minPrice: num.tryParse(q['minPrice'] ?? ''),
      maxPrice: num.tryParse(q['maxPrice'] ?? ''),
      minYear: int.tryParse(q['minYear'] ?? ''),
      maxYear: int.tryParse(q['maxYear'] ?? ''),
      maxMileage: num.tryParse(q['maxKm'] ?? ''),
      city: text('city'),
      sort: pick(ListingSort.values, q['sort'], (v) => v.apiValue) ?? ListingSort.newest,
    );
  }
}
