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
  static const String services = '/services';
  static const String login = '/Login';
  static const String register = '/Register';
  static const String inquiries = '/inquiries';
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

  static String carDetails(int listingId) => '/cars/$listingId';

  static String inquiry(int inquiryId) => '/inquiries/$inquiryId';

  static String adminUser(int userId) => '/admin/users/$userId';

  static String serviceRequest(int requestId) => '/services/requests/$requestId';

  /// `/services/book?ids=1,2` — the service ids to pre-select in the booking form.
  static String bookServices(Iterable<int> serviceIds) {
    final ids = serviceIds.toList();
    if (ids.isEmpty) return serviceBook;
    return Uri(path: serviceBook, queryParameters: {'ids': ids.join(',')}).toString();
  }

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
