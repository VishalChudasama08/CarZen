import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_filters.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/utils/json_parsing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('json_parsing', () {
    test('accepts numbers and numeric strings', () {
      expect(parseNum(5), 5);
      expect(parseNum('1680000.00'), 1680000);
      expect(parseNumOrNull(null), isNull);
      expect(parseNumOrNull('abc'), isNull);
    });

    test('parseNum throws a FormatException for missing values', () {
      expect(() => parseNum(null), throwsFormatException);
    });
  });

  group('formatters', () {
    test('rupees use Indian grouping', () {
      expect(formatInr(1680000), contains('16,80,000'));
      expect(formatKm(24100.0), '24,100 km');
    });
  });

  group('ListingFilters', () {
    test('copyWith keeps unspecified fields and clears explicit nulls', () {
      const filters = ListingFilters(brandId: 4, fuelType: FuelType.diesel, minPrice: 500000);
      final changed = filters.copyWith(fuelType: null);
      expect(changed.brandId, 4);
      expect(changed.fuelType, isNull);
      expect(changed.minPrice, 500000);
    });

    test('activeCount groups price and year ranges', () {
      const filters = ListingFilters(minPrice: 1, maxPrice: 2, minYear: 2020, city: 'Surat');
      expect(filters.activeCount, 3);
      expect(filters.clearedPanelFilters().activeCount, 0);
    });
  });

  group('AppRoutes', () {
    test('browseWith only includes provided filters', () {
      expect(AppRoutes.browseWith(), '/cars');
      expect(AppRoutes.browseWith(brandId: 3, fuelType: 'diesel'), '/cars?brandId=3&fuelType=diesel');
    });

    test('details and inquiry paths', () {
      expect(AppRoutes.carDetails(7), '/cars/7');
      expect(AppRoutes.inquiry(2), '/inquiries/2');
    });
  });
}
