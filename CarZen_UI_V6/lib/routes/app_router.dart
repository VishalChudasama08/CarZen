import 'package:carzen_flutter/models/listing_filters.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/pages/account_pages.dart';
import 'package:carzen_flutter/pages/add_edit_car_screen.dart';
import 'package:carzen_flutter/pages/admin_cars_screen.dart';
import 'package:carzen_flutter/pages/admin_catalog_screen.dart';
import 'package:carzen_flutter/pages/admin_dashboard_screen.dart';
import 'package:carzen_flutter/pages/admin_marketplace_pages.dart';
import 'package:carzen_flutter/pages/admin_orders_screen.dart';
import 'package:carzen_flutter/pages/admin_service_requests_screen.dart';
import 'package:carzen_flutter/pages/admin_services_screen.dart';
import 'package:carzen_flutter/pages/admin_user_detail_screen.dart';
import 'package:carzen_flutter/pages/admin_users_screen.dart';
import 'package:carzen_flutter/pages/book_service_screen.dart';
import 'package:carzen_flutter/pages/browse_listings_screen.dart';
import 'package:carzen_flutter/pages/car_details_screen.dart';
import 'package:carzen_flutter/pages/car_manage_screen.dart';
import 'package:carzen_flutter/pages/change_password_screen.dart';
import 'package:carzen_flutter/pages/edit_profile_screen.dart';
import 'package:carzen_flutter/pages/favorites_screen.dart';
import 'package:carzen_flutter/pages/home_page.dart';
import 'package:carzen_flutter/pages/inquiry_thread_screen.dart';
import 'package:carzen_flutter/pages/login_page.dart';
import 'package:carzen_flutter/pages/messages_screen.dart';
import 'package:carzen_flutter/pages/my_cars_screen.dart';
import 'package:carzen_flutter/pages/my_orders_screen.dart';
import 'package:carzen_flutter/pages/my_service_requests_screen.dart';
import 'package:carzen_flutter/pages/notifications_screen.dart';
import 'package:carzen_flutter/pages/price_check_screen.dart';
import 'package:carzen_flutter/pages/profile_screen.dart';
import 'package:carzen_flutter/pages/register_page.dart';
import 'package:carzen_flutter/pages/service_history_screen.dart';
import 'package:carzen_flutter/pages/service_request_detail_screen.dart';
import 'package:carzen_flutter/pages/services_screen.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/utils/slugs.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/require_auth.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Maps URLs to pages. Public pages (home, browse, car details, price check,
/// the workshop catalogue, login, register) open without a session.
/// Everything that reads or changes account data is wrapped in
/// [RequireAuth], which validates the token when the page opens.
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? AppRoutes.home);
    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => _pageFor(uri, settings.arguments));
  }

  /// Web deep links: open exactly the requested page instead of also
  /// stacking every parent path underneath it.
  static List<Route<dynamic>> onGenerateInitialRoutes(String initialRoute) => [
        onGenerateRoute(RouteSettings(name: initialRoute.isEmpty ? AppRoutes.home : initialRoute)),
      ];

  static Route<dynamic> onUnknownRoute(RouteSettings settings) =>
      MaterialPageRoute<dynamic>(settings: settings, builder: (_) => const NotFoundPage());

  static Widget _user(Widget child) => RequireAuth(userOnly: true, child: child);
  static Widget _signedIn(Widget child) => RequireAuth(child: child);
  static Widget _admin(Widget child) => RequireAuth(adminOnly: true, child: child);

  static Widget _pageFor(Uri uri, [Object? arguments]) {
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.isEmpty) return const HomePage();

    final first = segments.first.toLowerCase();
    final second = segments.length > 1 ? segments[1].toLowerCase() : null;
    int? idAt(int i) => segments.length > i ? int.tryParse(segments[i]) : null;

    switch (first) {
      case 'cars':
        if (segments.length == 1) return _browse(uri);
        final listingId = Slugs.parseCarIdFromSlug(segments[1]);
        return listingId == null ? const NotFoundPage() : CarDetailsScreen(listingId: listingId);

      case 'price-check':
        return const PriceCheckScreen();

      case 'sell':
        if (second == null) return _user(const MyCarsScreen());
        if (second == 'new') return _user(const AddEditCarScreen());
        if (second == 'cars') {
          final carId = idAt(2);
          if (carId == null) return _user(const MyCarsScreen());
          if (segments.length == 3) return _user(CarManageScreen(carId: carId));
          if (segments.length == 4 && segments[3].toLowerCase() == 'edit') return _user(AddEditCarScreen(carId: carId));
        }
        return const NotFoundPage();

      case 'favorites':
        return _user(const FavoritesScreen());

      case 'orders':
        if (second == null) return _user(const MyOrdersScreen());
        if (second == 'sales' && segments.length == 2) return _user(const MyOrdersScreen(initialTab: OrdersTab.selling));
        return const NotFoundPage();

      case 'purchases':
        return _user(const PurchasesScreen());

      case 'recently-viewed':
        return _user(const RecentlyViewedScreen());

      case 'inquiries':
      case 'messages':
        if (segments.length == 1) {
          final selling = uri.queryParameters['tab'] == 'selling';
          return _user(MessagesScreen(initialTab: selling ? MessagesTab.selling : MessagesTab.buying));
        }
        final inquiryId = idAt(1);
        return inquiryId == null
            ? const NotFoundPage()
            : _user(InquiryThreadScreen(inquiryId: inquiryId, asSeller: uri.queryParameters['as'] == 'seller'));

      case 'notifications':
        return _signedIn(const NotificationsScreen());

      case 'account':
        return _signedIn(const ProfileScreen());

      case 'profile':
        switch (second) {
          case null:
            return _signedIn(const ProfileScreen());
          case 'edit':
            return _signedIn(EditProfileScreen(user: arguments is UserResponse ? arguments : null));
          case 'password':
            return _signedIn(const ChangePasswordScreen());
          case 'my-cars':
            return _user(const MyCarsScreen());
          case 'addresses':
            return _user(const AddressesScreen());
          case 'contact':
            return _user(const ContactPreferencesScreen());
          case 'reviews':
            return _user(const MyReviewsScreen());
          case 'reports':
            return _user(const MyReportsScreen());
        }
        return const NotFoundPage();

      case 'services':
        // The catalogue is public; booking, requests and history need an account.
        switch (second) {
          case null:
            return const ServicesScreen();
          case 'book':
            var preselected = <int>[];
            if (arguments is Iterable<int>) {
              preselected = arguments.toList();
            } else if (arguments is int) {
              preselected = [arguments];
            } else {
              preselected = _ids(uri.queryParameters['ids']);
            }
            return _user(BookServiceScreen(preselectedIds: preselected));
          case 'history':
            return _user(const ServiceHistoryScreen());
          case 'requests':
            if (segments.length == 2) return _user(const MyServiceRequestsScreen());
            final requestId = Slugs.parseServiceRequestId(segments[2]);
            return requestId == null ? const NotFoundPage() : _user(ServiceRequestDetailScreen(requestId: requestId));
        }
        return const NotFoundPage();

      case 'login':
        return const LoginPage();
      case 'register':
        return const RegisterPage();

      case 'admin':
        switch (second) {
          case null:
          case 'dashboard':
            return _admin(const AdminDashboardScreen());
          case 'cars':
            final carId = idAt(2);
            return carId == null ? _admin(const AdminCarsScreen()) : _admin(AdminCarDetailScreen(carId: carId));
          case 'listings':
            return _admin(const AdminListingsScreen());
          case 'orders':
            return _admin(const AdminOrdersScreen());
          case 'transactions':
            return _admin(const AdminTransactionsScreen());
          case 'catalog':
            return _admin(const AdminCatalogScreen());
          case 'services':
            return _admin(const AdminServicesScreen());
          case 'service-requests':
            return _admin(const AdminServiceRequestsScreen());
          case 'reviews':
            return _admin(const AdminReviewsScreen());
          case 'reports':
            return _admin(const AdminReportsScreen());
          case 'users':
            if (segments.length > 2) {
              final userId = idAt(2);
              return userId == null ? const NotFoundPage() : _admin(AdminUserDetailScreen(userId: userId));
            }
            return _admin(const AdminUsersScreen());
        }
        return const NotFoundPage();
    }
    return const NotFoundPage();
  }

  /// `1,2,3` -> `[1, 2, 3]`; anything that is not a whole number is dropped.
  static List<int> _ids(String? raw) =>
      (raw ?? '').split(',').map((e) => int.tryParse(e.trim())).whereType<int>().toList();

  static Widget _browse(Uri uri) => BrowseListingsScreen(initialFilters: ListingFilters.fromQuery(uri.queryParameters));
}

/// Shown for URLs that do not map to a page (never a blank screen).
class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) => AppScaffold(
        section: NavSection.none,
        title: 'Page not found',
        body: EmptyStateView(
          icon: Icons.wrong_location_outlined,
          title: 'This page took a wrong turn',
          message: 'The link may be old or mistyped. Head home or browse the cars on sale.',
          action: Wrap(
            spacing: 12,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              FilledButton(onPressed: () => AppNav.goFrom(context, AppRoutes.browse), child: const Text('Browse cars')),
              OutlinedButton(onPressed: () => AppNav.goFrom(context, AppRoutes.home), child: const Text('Go to home')),
            ],
          ),
        ),
      );
}
