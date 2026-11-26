import 'package:carzen_flutter/utils/slugs.dart';

/// Route names / path builders. Paths are real URLs on Flutter Web, so every
/// screen below can be opened (and refreshed) directly from the address bar.
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String browse = '/cars';
  static const String priceCheck = '/price-check';

  // Selling
  static const String sell = '/sell';
  static const String sellNew = '/sell/new';

  // Account
  static const String account = '/account';
  static const String favorites = '/favorites';
  static const String orders = '/orders';
  static const String sales = '/orders/sales';
  static const String purchases = '/purchases';
  static const String profile = '/profile';
  static const String profileEdit = '/profile/edit';
  static const String profilePassword = '/profile/password';
  static const String profileAddresses = '/profile/addresses';
  static const String profileContact = '/profile/contact';
  static const String profileMyCars = '/profile/my-cars';
  static const String profileReviews = '/profile/reviews';
  static const String profileReports = '/profile/reports';
  static const String recentlyViewed = '/recently-viewed';
  static const String messages = '/messages';
  static const String inquiries = '/inquiries';
  static const String notifications = '/notifications';

  // Auth
  static const String login = '/login';
  static const String register = '/register';

  // Workshop
  static const String services = '/services';
  static const String serviceBook = '/services/book';
  static const String serviceRequests = '/services/requests';
  static const String serviceHistory = '/services/history';

  // Admin
  static const String admin = '/admin';
  static const String adminCars = '/admin/cars';
  static const String adminListings = '/admin/listings';
  static const String adminOrders = '/admin/orders';
  static const String adminTransactions = '/admin/transactions';
  static const String adminUsers = '/admin/users';
  static const String adminServices = '/admin/services';
  static const String adminServiceRequests = '/admin/service-requests';
  static const String adminReviews = '/admin/reviews';
  static const String adminReports = '/admin/reports';
  static const String adminCatalog = '/admin/catalog';

  /// Human-readable car details route: `/cars/{title-slug}-{id}`.
  /// If title is omitted or blank, falls back to `/cars/car-{id}`.
  static String carDetails(int listingId, [String? title]) => '/cars/${Slugs.buildCarSlug(listingId, title)}';

  /// One of the signed-in user's own cars (seller view).
  static String myCar(int carId) => '/sell/cars/$carId';

  /// A buyer conversation; [asSeller] opens the seller side of the thread.
  static String inquiry(int inquiryId, {bool asSeller = false}) =>
      asSeller ? '/messages/$inquiryId?as=seller' : '/messages/$inquiryId';

  static String adminUser(int userId) => '/admin/users/$userId';

  static String adminCar(int carId) => '/admin/cars/$carId';

  /// Readable service request URL: `/services/requests/request-{id}`.
  static String serviceRequest(int requestId) => '/services/requests/${Slugs.buildServiceRequestRef(requestId)}';

  /// `/services/book?ids=1,2` - the chosen services survive a page reload.
  static String bookServices([Iterable<int>? serviceIds]) {
    final ids = serviceIds?.toList() ?? const <int>[];
    if (ids.isEmpty) return serviceBook;
    return '$serviceBook?ids=${ids.join(',')}';
  }

  /// Seller's car edit form.
  static String myCarEdit(int carId) => '/sell/cars/$carId/edit';

  /// Messages, opened on the "Selling" tab when [selling].
  static String messagesTab({bool selling = false}) => selling ? '$messages?tab=selling' : messages;

  /// `/cars?brandId=3&fuelType=diesel...` - only non-null filters are added.
  static String browseWith({
    int? brandId,
    String? fuelType,
    String? transmission,
    num? minPrice,
    num? maxPrice,
    String? search,
    String? sort,
  }) {
    final params = <String, String>{
      if (search != null && search.isNotEmpty) 'search': search,
      if (brandId != null) 'brandId': '$brandId',
      if (fuelType != null) 'fuelType': fuelType,
      if (transmission != null) 'transmission': transmission,
      if (minPrice != null) 'minPrice': '$minPrice',
      if (maxPrice != null) 'maxPrice': '$maxPrice',
      if (sort != null) 'sort': sort,
    };
    if (params.isEmpty) return browse;
    return Uri(path: browse, queryParameters: params).toString();
  }
}
