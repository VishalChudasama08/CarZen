import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/pages/add_edit_car_screen.dart';
import 'package:carzen_flutter/pages/admin_cars_screen.dart';
import 'package:carzen_flutter/pages/admin_service_requests_screen.dart';
import 'package:carzen_flutter/pages/admin_services_screen.dart';
import 'package:carzen_flutter/pages/admin_orders_screen.dart';
import 'package:carzen_flutter/pages/admin_user_detail_screen.dart';
import 'package:carzen_flutter/pages/admin_users_screen.dart';
import 'package:carzen_flutter/pages/book_service_screen.dart';
import 'package:carzen_flutter/pages/browse_listings_screen.dart';
import 'package:carzen_flutter/pages/car_details_screen.dart';
import 'package:carzen_flutter/pages/favorites_screen.dart';
import 'package:carzen_flutter/pages/home_page.dart';
import 'package:carzen_flutter/pages/inquiries_screen.dart';
import 'package:carzen_flutter/pages/inquiry_thread_screen.dart';
import 'package:carzen_flutter/pages/login_page.dart';
import 'package:carzen_flutter/pages/my_cars_screen.dart';
import 'package:carzen_flutter/pages/my_orders_screen.dart';
import 'package:carzen_flutter/pages/notifications_screen.dart';
import 'package:carzen_flutter/pages/my_service_requests_screen.dart';
import 'package:carzen_flutter/pages/profile_screen.dart';
import 'package:carzen_flutter/pages/register_page.dart';
import 'package:carzen_flutter/pages/service_history_screen.dart';
import 'package:carzen_flutter/pages/service_request_detail_screen.dart';
import 'package:carzen_flutter/pages/services_screen.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/require_auth.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Maps URLs to pages. Public pages (home, browse, car details, the service
/// catalog, login, register) open without a session. Everything that reads or changes
/// account data is wrapped in [RequireAuth], which validates the token at that
/// moment through the existing `AuthService.validateToken()`.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? AppRoutes.home);
    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => _pageFor(uri));
  }

  /// Web deep links: open exactly the requested page instead of Flutter's
  /// default behaviour of also stacking every parent path underneath it.
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
        onGenerateRoute(RouteSettings(name: initialRoute.isEmpty ? AppRoutes.home : initialRoute)),
      ];

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      MaterialPageRoute<dynamic>(settings: settings, builder: (_) => const NotFoundPage());

  static Widget _pageFor(Uri uri) {
    final segments = uri.pathSegments;
    if (segments.isEmpty) return const HomePage();

    final first = segments.first.toLowerCase();
    final second = segments.length > 1 ? segments[1].toLowerCase() : null;

    switch (first) {
      case 'cars':
        if (segments.length == 1) return _browse(uri);
        final listingId = int.tryParse(segments[1]);
        return listingId == null ? const NotFoundPage() : CarDetailsScreen(listingId: listingId);
      case 'sell':
        return RequireAuth(userOnly: true, child: second == 'new' ? const AddEditCarScreen() : const MyCarsScreen());
      case 'favorites':
        return const RequireAuth(userOnly: true, child: FavoritesScreen());
      case 'orders':
        return const RequireAuth(userOnly: true, child: MyOrdersScreen());
      case 'inquiries':
        if (segments.length == 1) return const RequireAuth(userOnly: true, child: InquiriesScreen());
        final inquiryId = int.tryParse(segments[1]);
        return inquiryId == null
            ? const NotFoundPage()
            : RequireAuth(userOnly: true, child: InquiryThreadScreen(inquiryId: inquiryId));
      case 'notifications':
        return const RequireAuth(child: NotificationsScreen());
      case 'profile':
        return const RequireAuth(child: ProfileScreen());
      case 'services':
        // The catalog is public. Booking, requests and history are account pages.
        switch (second) {
          case null:
            return const ServicesScreen();
          case 'book':
            return RequireAuth(userOnly: true, child: BookServiceScreen(preselectedIds: _ids(uri.queryParameters['ids'])));
          case 'history':
            return const RequireAuth(userOnly: true, child: ServiceHistoryScreen());
          case 'requests':
            if (segments.length == 2) return const RequireAuth(userOnly: true, child: MyServiceRequestsScreen());
            final requestId = int.tryParse(segments[2]);
            return requestId == null
                ? const NotFoundPage()
                : RequireAuth(userOnly: true, child: ServiceRequestDetailScreen(requestId: requestId));
        }
        return const NotFoundPage();
      case 'login':
        return const LoginPage();
      case 'register':
        return const RegisterPage();
      case 'admin':
        switch (second) {
          case null:
          case 'cars':
            return const RequireAuth(adminOnly: true, child: AdminCarsScreen());
          case 'orders':
            return const RequireAuth(adminOnly: true, child: AdminOrdersScreen());
          case 'services':
            return const RequireAuth(adminOnly: true, child: AdminServicesScreen());
          case 'service-requests':
            return const RequireAuth(adminOnly: true, child: AdminServiceRequestsScreen());
          case 'users':
            if (segments.length > 2) {
              final userId = int.tryParse(segments[2]);
              return userId == null
                  ? const NotFoundPage()
                  : RequireAuth(adminOnly: true, child: AdminUserDetailScreen(userId: userId));
            }
            return const RequireAuth(adminOnly: true, child: AdminUsersScreen());
        }
        return const NotFoundPage();
    }
    return const NotFoundPage();
  }

  /// `1,2,3` -> `[1, 2, 3]`; anything that is not a whole number is dropped.
  static List<int> _ids(String? raw) =>
      (raw ?? '').split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();

  static Widget _browse(Uri uri) {
    final q = uri.queryParameters;
    String? knownOrNull(String? value, Iterable<String> allowed) =>
        value != null && allowed.contains(value) ? value : null;
    return BrowseListingsScreen(
      brandId: int.tryParse(q['brandId'] ?? ''),
      fuelType: knownOrNull(q['fuelType'], FuelType.values.map((e) => e.name)),
      transmission: knownOrNull(q['transmission'], TransmissionType.values.map((e) => e.name)),
      minPrice: num.tryParse(q['minPrice'] ?? ''),
      maxPrice: num.tryParse(q['maxPrice'] ?? ''),
      search: (q['search'] ?? '').trim().isEmpty ? null : q['search']!.trim(),
    );
  }
}

/// Shown for URLs that do not map to a page (never a blank screen).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CarZenNavBar(title: 'Page not found'),
        body: SafeArea(
          child: EmptyStateView(
            icon: Icons.search_off_rounded,
            title: 'Page not found',
            message: 'The page you are looking for does not exist or has moved.',
            action: FilledButton(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false),
              child: const Text('Go to Home'),
            ),
          ),
        ),
      );
}
