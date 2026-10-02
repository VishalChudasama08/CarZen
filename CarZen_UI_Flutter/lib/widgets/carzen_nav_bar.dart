import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/widgets/app_logo.dart';
import 'package:flutter/material.dart';

/// Which top-level area the current page belongs to (highlighted in the bar).
enum NavSection {
  login,
  register,
  home,
  buy,
  sell,
  services,
  favorites,
  orders,
  messages,
  notifications,
  profile,
  adminUsers,
  adminCars,
  adminOrders,
  adminServices,
  adminServiceRequests,
  none,
}

/// Navigation helper shared by the bar and its menus.
class AppNav {
  AppNav._();

  static String pathOf(String? routeName) => routeName == null ? '' : Uri.parse(routeName).path;

  /// Top-level destinations replace the stack, so the browser/back button
  /// never walks through a long chain of previously opened sections.
  static void go(NavigatorState navigator, String currentPath, String route) {
    final target = Uri.parse(route);
    if (target.path == currentPath && target.queryParameters.isEmpty) return;
    navigator.pushNamedAndRemoveUntil(route, (r) => false);
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final NavSection section;
  const _Destination(this.label, this.icon, this.selectedIcon, this.route, this.section);
}

const _primary = <_Destination>[
  _Destination('Home', Icons.home_outlined, Icons.home_rounded, AppRoutes.home, NavSection.home),
  _Destination('Buy Car', Icons.directions_car_outlined, Icons.directions_car_rounded, AppRoutes.browse, NavSection.buy),
  _Destination('Sell Car', Icons.sell_outlined, Icons.sell_rounded, AppRoutes.sell, NavSection.sell),
  _Destination('Services', Icons.home_repair_service_outlined, Icons.home_repair_service_rounded, AppRoutes.services,
      NavSection.services),
];

/// Administrators do not buy, sell or book services, so they get their own
/// navigation built from the admin endpoints instead of the marketplace one.
const _adminPrimary = <_Destination>[
  _Destination('Home', Icons.home_outlined, Icons.home_rounded, AppRoutes.home, NavSection.home),
  _Destination('Users', Icons.group_outlined, Icons.group_rounded, AppRoutes.adminUsers, NavSection.adminUsers),
  _Destination('Car Approvals', Icons.fact_check_outlined, Icons.fact_check_rounded, AppRoutes.adminCars,
      NavSection.adminCars),
  _Destination('Orders', Icons.local_shipping_outlined, Icons.local_shipping_rounded, AppRoutes.adminOrders,
      NavSection.adminOrders),
  _Destination('Service Catalog', Icons.build_circle_outlined, Icons.build_circle_rounded, AppRoutes.adminServices,
      NavSection.adminServices),
  _Destination('Service Requests', Icons.assignment_outlined, Icons.assignment_rounded,
      AppRoutes.adminServiceRequests, NavSection.adminServiceRequests),
];

const _account = <_Destination>[
  _Destination('Profile', Icons.person_outline_rounded, Icons.person_rounded, AppRoutes.profile, NavSection.profile),
  _Destination('Favorites', Icons.favorite_border_rounded, Icons.favorite_rounded, AppRoutes.favorites,
      NavSection.favorites),
  _Destination('My Orders', Icons.receipt_long_outlined, Icons.receipt_long_rounded, AppRoutes.orders,
      NavSection.orders),
  _Destination('Messages', Icons.chat_bubble_outline_rounded, Icons.chat_bubble_rounded, AppRoutes.inquiries,
      NavSection.messages),
  _Destination('Notifications', Icons.notifications_none_rounded, Icons.notifications_rounded,
      AppRoutes.notifications, NavSection.notifications),
];

const _adminAccount = <_Destination>[
  _Destination('Profile', Icons.person_outline_rounded, Icons.person_rounded, AppRoutes.profile, NavSection.profile),
  _Destination('Notifications', Icons.notifications_none_rounded, Icons.notifications_rounded,
      AppRoutes.notifications, NavSection.notifications),
];

/// The one navigation bar used by every top-level page.
///
/// * expanded width (>= 900): logo + inline links + account menu on navy
/// * smaller widths: back button or menu button, page title (or the logo on
///   Home), and a grouped bottom-sheet menu. Top-level pages also show
///   [CarZenBottomBar] for one-thumb navigation.
///
/// It only reads local session state ([SessionController]); it never calls
/// the network, so public browsing stays fast and works without login.
class CarZenNavBar extends StatefulWidget implements PreferredSizeWidget {
  final NavSection current;

  /// Page title shown on compact widths (the logo is shown when null).
  final String? title;

  const CarZenNavBar({super.key, this.current = NavSection.none, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  State<CarZenNavBar> createState() => _CarZenNavBarState();
}

class _CarZenNavBarState extends State<CarZenNavBar> {
  final SessionController _session = SessionController.instance;

  @override
  void initState() {
    super.initState();
    _session.refresh();
  }

  String get _currentPath => AppNav.pathOf(ModalRoute.of(context)?.settings.name);

  void _go(String route) => AppNav.go(Navigator.of(context), _currentPath, route);

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await _session.signOut();
    navigator.pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
  }

  void _openMenu() {
    final navigator = Navigator.of(context);
    final currentPath = _currentPath;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _MenuSheet(
        session: _session,
        currentPath: currentPath,
        onNavigate: (route) {
          Navigator.of(sheetContext).pop();
          AppNav.go(navigator, currentPath, route);
        },
        onLogout: () async {
          Navigator.of(sheetContext).pop();
          await _session.signOut();
          navigator.pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) => Breakpoints.isExpanded(context) ? _buildExpanded() : _buildCompact(context),
    );
  }

  Widget _logo() => AppLogo(height: 38, onTap: () => _go(AppRoutes.home));

  AppBar _buildExpanded() {
    final links = _session.isAdmin ? _adminPrimary : _primary;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      titleSpacing: 24,
      toolbarHeight: 64,
      title: Row(
        children: [
          _logo(),
          const SizedBox(width: 28),
          // Links share the remaining width and scroll instead of overflowing.
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final d in links)
                    _NavLink(label: d.label, selected: widget.current == d.section, onTap: () => _go(d.route)),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        if (_session.isLoggedIn)
          _AccountMenu(
            isAdmin: _session.isAdmin,
            highlighted: widget.current == NavSection.profile ||
                widget.current == NavSection.favorites ||
                widget.current == NavSection.orders ||
                widget.current == NavSection.messages ||
                widget.current == NavSection.notifications,
            onSelected: _go,
            onLogout: _logout,
          )
        else ...[
          _NavLink(label: 'Login', selected: widget.current == NavSection.login, onTap: () => _go(AppRoutes.login)),
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: ElevatedButton(
              onPressed: () => _go(AppRoutes.register),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 18)),
              child: const Text('Register'),
            ),
          ),
        ],
        const SizedBox(width: 24),
      ],
    );
  }

  AppBar _buildCompact(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final showTitle = widget.title != null && widget.current != NavSection.home;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.primary,
      leading: canPop
          ? const BackButton(color: Colors.white)
          : IconButton(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu_rounded, color: Colors.white),
              onPressed: _openMenu,
            ),
      titleSpacing: 0,
      title: showTitle
          ? Text(
              widget.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 17),
            )
          : Align(alignment: Alignment.centerLeft, child: _logo()),
      actions: [
        if (canPop) IconButton(tooltip: 'Menu', icon: const Icon(Icons.menu_rounded, color: Colors.white), onPressed: _openMenu),
        if (_session.isLoggedIn)
          IconButton(
            tooltip: 'Profile',
            icon: Icon(
              _session.isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline_rounded,
              color: Colors.white,
            ),
            onPressed: () => _go(AppRoutes.profile),
          )
        else
          TextButton(
            onPressed: () => _go(AppRoutes.login),
            style: TextButton.styleFrom(foregroundColor: AppColors.cyan),
            child: const Text('Log in'),
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: selected ? Colors.white : AppColors.textOnDarkMuted,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: selected ? AppColors.cyan : Colors.transparent, width: 2.5)),
          ),
          child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600, fontSize: 14)),
        ),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  final bool isAdmin;
  final bool highlighted;
  final ValueChanged<String> onSelected;
  final Future<void> Function() onLogout;

  const _AccountMenu({
    required this.isAdmin,
    required this.highlighted,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == '__logout__') {
          onLogout();
        } else {
          onSelected(value);
        }
      },
      itemBuilder: (_) => [
        for (final d in (isAdmin ? _adminAccount : _account))
          PopupMenuItem<String>(
            value: d.route,
            child: Row(children: [Icon(d.icon, size: 20), const SizedBox(width: 12), Text(d.label)]),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: '__logout__',
          child: Row(children: [Icon(Icons.logout_rounded, size: 20), SizedBox(width: 12), Text('Log out')]),
        ),
      ],
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: highlighted ? AppColors.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: AppColors.primarySoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAdmin ? Icons.admin_panel_settings_outlined : Icons.account_circle_outlined,
              color: highlighted ? AppColors.cyan : Colors.white,
              size: 22,
            ),
            const SizedBox(width: 6),
            Text(isAdmin ? 'Admin' : 'Account', style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
            const Icon(Icons.arrow_drop_down, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  final SessionController session;
  final String currentPath;
  final ValueChanged<String> onNavigate;
  final Future<void> Function() onLogout;

  const _MenuSheet({
    required this.session,
    required this.currentPath,
    required this.onNavigate,
    required this.onLogout,
  });

  Widget _tile(_Destination d) {
    final selected = AppNav.pathOf(d.route) == currentPath;
    return ListTile(
      leading: Icon(selected ? d.selectedIcon : d.icon, color: selected ? AppColors.secondary : AppColors.textPrimary),
      title: Text(
        d.label,
        style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: AppColors.textPrimary),
      ),
      selected: selected,
      selectedTileColor: AppColors.cyanTint,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.md)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: () => onNavigate(d.route),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
              fontSize: 12, letterSpacing: 0.8, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
          children: [
            _heading(session.isAdmin ? 'Administration' : 'Explore'),
            for (final d in (session.isAdmin ? _adminPrimary : _primary)) _tile(d),
            if (session.isLoggedIn) ...[
              _heading('My account'),
              for (final d in (session.isAdmin ? _adminAccount : _account)) _tile(d),
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.favorite),
                title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.favorite)),
                onTap: onLogout,
              ),
            ] else ...[
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Expanded(child: FilledButton(onPressed: () => onNavigate(AppRoutes.login), child: const Text('Log in'))),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(onPressed: () => onNavigate(AppRoutes.register), child: const Text('Register')),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Phone-only bottom navigation for the main sections. Add it as
/// `bottomNavigationBar:` on top-level pages; on tablets and desktops it
/// renders nothing (the top bar already carries every link).
class CarZenBottomBar extends StatelessWidget {
  final NavSection current;
  const CarZenBottomBar({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isCompact(context)) return const SizedBox.shrink();
    final session = SessionController.instance;
    return AnimatedBuilder(
      animation: session,
      builder: (context, _) {
        final items = session.isAdmin ? _adminBottom : _userBottom;
        final selected = items.indexWhere((d) => d.section == current);
        final navigator = Navigator.of(context);
        final path = AppNav.pathOf(ModalRoute.of(context)?.settings.name);
        return Container(
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
          child: NavigationBar(
            selectedIndex: selected < 0 ? 0 : selected,
            // No tab highlight when the current page is not one of the tabs.
            indicatorColor: selected < 0 ? Colors.transparent : AppColors.cyanTint,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) => AppNav.go(navigator, path, items[index].route),
            destinations: [
              for (final d in items)
                NavigationDestination(icon: Icon(d.icon), selectedIcon: Icon(d.selectedIcon), label: d.label),
            ],
          ),
        );
      },
    );
  }

  static const _userBottom = <_Destination>[
    _Destination('Home', Icons.home_outlined, Icons.home_rounded, AppRoutes.home, NavSection.home),
    _Destination('Buy', Icons.directions_car_outlined, Icons.directions_car_rounded, AppRoutes.browse, NavSection.buy),
    _Destination('Sell', Icons.sell_outlined, Icons.sell_rounded, AppRoutes.sell, NavSection.sell),
    _Destination('Services', Icons.home_repair_service_outlined, Icons.home_repair_service_rounded,
        AppRoutes.services, NavSection.services),
    _Destination('Profile', Icons.person_outline_rounded, Icons.person_rounded, AppRoutes.profile, NavSection.profile),
  ];

  static const _adminBottom = <_Destination>[
    _Destination('Users', Icons.group_outlined, Icons.group_rounded, AppRoutes.adminUsers, NavSection.adminUsers),
    _Destination('Cars', Icons.fact_check_outlined, Icons.fact_check_rounded, AppRoutes.adminCars, NavSection.adminCars),
    _Destination('Orders', Icons.local_shipping_outlined, Icons.local_shipping_rounded, AppRoutes.adminOrders,
        NavSection.adminOrders),
    _Destination('Catalog', Icons.build_circle_outlined, Icons.build_circle_rounded, AppRoutes.adminServices,
        NavSection.adminServices),
    _Destination('Requests', Icons.assignment_outlined, Icons.assignment_rounded, AppRoutes.adminServiceRequests,
        NavSection.adminServiceRequests),
  ];
}
