import 'package:carzen_flutter/utils/slugs.dart';

/// Route names / path builders. Paths are real URLs on Flutter Web, so every
/// screen below can be opened (and refreshed) directly from the address bar.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String browse = '/cars';
  static const String sell = '/sell';
  static const String sellNew = '/sell/new';
  static const String favorites = '/favorites';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String profilePassword = '/profile/password';
  static const String profileMyCars = '/profile/my-cars';
  static const String services = '/services';
  static const String login = '/Login';
  static const String register = '/Register';
  static const String inquiries = '/inquiries';
  static const String messages = '/messages';
  static const String notifications = '/notifications';
  static const String admin = '/admin';
  static const String adminCars = '/admin/cars';
  static const String adminOrders = '/admin/orders';
  static const String adminUsers = '/admin/users';
  static const String adminServices = '/admin/services';
  static const String adminServiceRequests = '/admin/service-requests';
  static const String serviceBook = '/services/book';
  static const String serviceRequests = '/services/requests';
  static const String serviceHistory = '/services/history';

  /// Human-readable car details route: `/cars/{title-slug}-{id}`.
  /// If title is omitted or blank, falls back to `/cars/car-{id}`.
  static String carDetails(int listingId, [String? title]) =>
      '/cars/${Slugs.buildCarSlug(listingId, title)}';

  static String inquiry(int inquiryId) => '/inquiries/$inquiryId';

  static String adminUser(int userId) => '/admin/users/$userId';

  /// Readable service request URL: `/services/requests/request-{id}`.
  static String serviceRequest(int requestId) =>
      '/services/requests/${Slugs.buildServiceRequestRef(requestId)}';

  /// Clean `/services/book` URL without query parameters. Preselected IDs
  /// are passed via RouteSettings.arguments.
  static String bookServices([Iterable<int>? serviceIds]) => serviceBook;

  /// `/cars?brandId=3&fuelType=diesel...` — only non-null filters are added.
  static String browseWith({
    int? brandId,
    String? fuelType,
    String? transmission,
    num? minPrice,
    num? maxPrice,
    String? search,
  }) {
    final params = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (brandId != null) 'brandId': '$brandId',
      if (fuelType != null) 'fuelType': fuelType,
      if (transmission != null) 'transmission': transmission,
      if (minPrice != null) 'minPrice': '$minPrice',
      if (maxPrice != null) 'maxPrice': '$maxPrice',
    };
    if (params.isEmpty) return browse;
    return Uri(path: browse, queryParameters: params).toString();
  }
}
