import 'dart:convert';
import 'dart:io';

import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/engagement_models.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/order_models.dart';
import 'package:carzen_flutter/models/pagination.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fixtures in `test/fixtures` are real responses captured from the FastAPI
/// backend (decimals arrive as strings such as "1325000.00"). These tests fail
/// if a model stops matching what the backend actually sends.
dynamic fixture(String name) => jsonDecode(File('test/fixtures/$name.json').readAsStringSync());

void main() {
  test('public listing detail parses string decimals', () {
    final listing = ListingDetail.fromJson(fixture('listing_detail') as Map<String, dynamic>);
    expect(listing.askingPrice, 1325000);
    expect(listing.car.mileageKm, 14200);
    expect(listing.car.engineCc, isNull); // electric car
    expect(listing.car.brandName, 'Tata');
    expect(listing.car.media, isNotEmpty);
    expect(listing.car.media.cover, isNotNull);
  });

  test('listing page parses', () {
    final page = PaginatedList.fromJson(fixture('listings_page') as Map<String, dynamic>, Listing.fromJson);
    expect(page.data, isNotEmpty);
    expect(page.data.first.askingPrice, greaterThan(0));
    expect(page.pagination.total, greaterThan(0));
  });

  test('favorites parse', () {
    final favorites = (fixture('favorites') as List<dynamic>)
        .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
        .toList();
    expect(favorites, isNotEmpty);
    expect(favorites.first.carId, favorites.first.car.id);
  });

  test('orders parse', () {
    final page = PaginatedList.fromJson(fixture('buyer_orders') as Map<String, dynamic>, OrderRecord.fromJson);
    expect(page.data, isNotEmpty);
    expect(page.data.first.amount, greaterThan(0));
  });

  test('inquiry with messages parses', () {
    final inquiry = InquiryRecord.fromJson(fixture('inquiry_detail') as Map<String, dynamic>);
    expect(inquiry.messages, isNotEmpty);
    expect(inquiry.listing.askingPrice, greaterThan(0));
    expect(inquiry.seller.displayName, isNotEmpty);
  });

  test('notifications parse', () {
    final page = PaginatedList.fromJson(
      fixture('notifications') as Map<String, dynamic>,
      NotificationRecord.fromJson,
    );
    expect(page.data, isNotEmpty);
  });
}
