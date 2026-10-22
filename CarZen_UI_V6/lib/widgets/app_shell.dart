import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/widgets/app_logo.dart';
import 'package:carzen_flutter/widgets/page_back_button.dart';
import 'package:flutter/material.dart';

/// Which area the current page belongs to (highlighted in the navigation).
enum NavSection {
  login,
  register,
  home,
  buy,
  sell,
  services,
  priceCheck,
  favorites,
  orders,
  messages,
  notifications,
  profile,
  account,
  adminDashboard,
  adminUsers,
  adminCars,
  adminListings,
  adminOrders,
  adminTransactions,
  adminServices,
  adminServiceRequests,
  adminReviews,
  adminReports,
  adminCatalog,
  adminNotifications,
  none,
}

extension NavSectionX on NavSection {
  bool get isAdmin => name.startsWith('admin');

  /// Pages reached from the account menu.
  bool get isAccount => const {
        NavSection.favorites,
        NavSection.orders,
        NavSection.messages,
        NavSection.notifications,
        NavSection.profile,
        NavSection.account,
      }.contains(this);
}

/// Navigation helper shared by the bars and menus.
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

  static void goFrom(BuildContext context, String route) =>
      go(Navigator.of(context), pathOf(ModalRoute.of(context)?.settings.name), route);
}

class NavDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String route;
  final NavSection section;
  const NavDestination(this.label, this.icon, this.selectedIcon, this.route, this.section);
}

const marketplaceDestinations = <NavDestination>[
  NavDestination('Buy cars', Icons.directions_car_outlined, Icons.directions_car, AppRoutes.browse, NavSection.buy),
  NavDestination('Sell your car', Icons.sell_outlined, Icons.sell, AppRoutes.sell, NavSection.sell),
  NavDestination('Workshop', Icons.build_outlined, Icons.build, AppRoutes.services, NavSection.services),
  NavDestination('Price check', Icons.query_stats_outlined, Icons.query_stats, AppRoutes.priceCheck, NavSection.priceCheck),
];

const accountDestinations = <NavDestination>[
  NavDestination('My account', Icons.person_outline, Icons.person, AppRoutes.profile, NavSection.profile),
  NavDestination('Selling', Icons.garage_outlined, Icons.garage, AppRoutes.sell, NavSection.sell),
  NavDestination('Orders', Icons.receipt_long_outlined, Icons.receipt_long, AppRoutes.orders, NavSection.orders),
  NavDestination('Messages', Icons.chat_bubble_outline, Icons.chat_bubble, AppRoutes.messages, NavSection.messages),
  NavDestination('Saved cars', Icons.favorite_border, Icons.favorite, AppRoutes.favorites, NavSection.favorites),
  NavDestination('Service bookings', Icons.event_note_outlined, Icons.event_note, AppRoutes.serviceRequests, NavSection.services),
  NavDestination('Notifications', Icons.notifications_none, Icons.notifications, AppRoutes.notifications, NavSection.notifications),
];

class AdminNavGroup {
  final String title;
  final List<NavDestination> items;
  const AdminNavGroup(this.title, this.items);
}

const adminNavGroups = <AdminNavGroup>[
  AdminNavGroup('Overview', [
    NavDestination('Dashboard', Icons.space_dashboard_outlined, Icons.space_dashboard, AppRoutes.admin, NavSection.adminDashboard),
  ]),
  AdminNavGroup('Marketplace', [
    NavDestination('Car approvals', Icons.fact_check_outlined, Icons.fact_check, AppRoutes.adminCars, NavSection.adminCars),
    NavDestination('Listings', Icons.storefront_outlined, Icons.storefront, AppRoutes.adminListings, NavSection.adminListings),
    NavDestination('Orders', Icons.receipt_long_outlined, Icons.receipt_long, AppRoutes.adminOrders, NavSection.adminOrders),
    NavDestination('Transactions', Icons.account_balance_wallet_outlined, Icons.account_balance_wallet, AppRoutes.adminTransactions,
        NavSection.adminTransactions),
    NavDestination('Car catalogue', Icons.category_outlined, Icons.category, AppRoutes.adminCatalog, NavSection.adminCatalog),
  ]),
  AdminNavGroup('Workshop', [
    NavDestination('Service requests', Icons.assignment_outlined, Icons.assignment, AppRoutes.adminServiceRequests,
        NavSection.adminServiceRequests),
    NavDestination('Services', Icons.build_outlined, Icons.build, AppRoutes.adminServices, NavSection.adminServices),
  ]),
  AdminNavGroup('Trust & people', [
    NavDestination('Users', Icons.group_outlined, Icons.group, AppRoutes.adminUsers, NavSection.adminUsers),
    NavDestination('Reports', Icons.flag_outlined, Icons.flag, AppRoutes.adminReports, NavSection.adminReports),
    NavDestination('Reviews', Icons.reviews_outlined, Icons.reviews, AppRoutes.adminReviews, NavSection.adminReviews),
  ]),
];

/// The scaffold every page uses. It picks the navigation chrome for the
/// section and the available width:
///
/// * marketplace pages: white top bar (inline links from 760 px) and, on
///   narrower screens, a bottom navigation bar on top-level pages;
/// * admin pages: an ink sidebar on desktop, an icon rail on tablets and a
///   drawer on phones.
class AppScaffold extends StatelessWidget {
  final NavSection section;

  /// Title for compact bars and the admin header.
  final String? title;
  final Widget body;
  final Widget? floatingActionButton;

  /// Route to go to when "back" is pressed on a deep-linked page.
  final String? fallbackRoute;

  /// Show the back button (defaults to: route can pop or [fallbackRoute] set).
  final bool? showBackButton;

  /// Show the phone bottom navigation (top-level pages only).
  final bool showBottomNav;

  /// Extra actions for the admin header / compact bar.
  final List<Widget> actions;

  /// Fixed bottom area (e.g. a sticky "Buy" bar on phones).
  final Widget? bottomBar;

  final Color? backgroundColor;

  const AppScaffold({
    super.key,
    required this.section,
    required this.body,
    this.title,
    this.floatingActionButton,
    this.fallbackRoute,
    this.showBackButton,
    this.showBottomNav = false,
    this.actions = const [],
    this.bottomBar,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    if (section.isAdmin) return _AdminScaffold(page: this);
    final width = Breakpoints.widthOf(context);
    final bottomNav = showBottomNav && width < Breakpoints.inlineNav ? CarZenBottomBar(current: section) : null;
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CarZenNavBar(
        current: section,
        title: title,
        fallbackRoute: fallbackRoute,
        showBackButton: showBackButton,
        actions: actions,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomBar == null
          ? bottomNav
          : Column(mainAxisSize: MainAxisSize.min, children: [bottomBar!, ?bottomNav]),
      body: body,
    );
  }
}

// ---------------------------------------------------------------------------
// Marketplace top bar
// ---------------------------------------------------------------------------

class CarZenNavBar extends StatefulWidget implements PreferredSizeWidget {
  final NavSection current;
  final String? title;
  final String? fallbackRoute;
  final bool? showBackButton;
  final List<Widget> actions;

  const CarZenNavBar({
    super.key,
    this.current = NavSection.none,
    this.title,
    this.fallbackRoute,
    this.showBackButton,
    this.actions = const [],
  });

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

  bool _hasBack(BuildContext context) =>
      widget.showBackButton ?? (widget.fallbackRoute != null || Navigator.of(context).canPop());

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await _session.signOut();
    navigator.pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        final wide = Breakpoints.hasInlineNav(context);
        return Material(
          color: AppColors.surface,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 64,
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
              child: wide ? _wide(context) : _compact(context),
            ),
          ),
        );
      },
    );
  }

  Widget _logo({bool markOnly = false}) => AppLogo(
        height: 32,
        markOnly: markOnly,
        onTap: () => _go(_session.isAdmin ? AppRoutes.admin : AppRoutes.home),
      );

  Widget _wide(BuildContext context) {
    final hasBack = _hasBack(context) && widget.current == NavSection.none;
    final width = Breakpoints.widthOf(context);
    final gutter = AppSpacing.pageGutter(width);
    final showPriceCheck = width >= 900;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth + 80),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: gutter - 4),
          child: Row(
            children: [
              if (hasBack) ...[
                PageBackButton(fallbackRoute: widget.fallbackRoute, color: AppColors.ink),
                const SizedBox(width: 4),
              ],
              _logo(),
              const SizedBox(width: 28),
              if (!_session.isAdmin)
                for (final d in marketplaceDestinations)
                  if (d.section != NavSection.priceCheck || showPriceCheck)
                    _NavLink(label: d.label, selected: widget.current == d.section, onTap: () => _go(d.route)),
              const Spacer(),
              ...widget.actions,
              if (_session.isLoggedIn) ...[
                _NotificationBell(
                  count: _session.unreadCount,
                  selected: widget.current == NavSection.notifications,
                  onTap: () => _go(AppRoutes.notifications),
                ),
                const SizedBox(width: 6),
                _AccountMenu(session: _session, highlighted: widget.current.isAccount, onSelected: _go, onLogout: _logout),
              ] else ...[
                TextButton(
                  onPressed: () => _go(AppRoutes.login),
                  style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                  child: const Text('Log in'),
                ),
                const SizedBox(width: 6),
                FilledButton(
                  onPressed: () => _go(AppRoutes.register),
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40), padding: const EdgeInsets.symmetric(horizontal: 16)),
                  child: const Text('Create account'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _compact(BuildContext context) {
    final hasBack = _hasBack(context);
    final narrow = Breakpoints.isNarrow(context);
    final showTitle = widget.title != null && widget.current != NavSection.home && hasBack;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: narrow ? 4 : 8),
      child: Row(
        children: [
          if (hasBack) PageBackButton(fallbackRoute: widget.fallbackRoute, color: AppColors.ink) else const SizedBox(width: 8),
          if (showTitle)
            Expanded(
              child: Text(
                widget.title!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: AppColors.ink),
              ),
            )
          else ...[
            _logo(markOnly: narrow && hasBack),
            const Spacer(),
          ],
          ...widget.actions,
          if (_session.isLoggedIn) ...[
            _NotificationBell(
              count: _session.unreadCount,
              selected: widget.current == NavSection.notifications,
              onTap: () => _go(AppRoutes.notifications),
            ),
            if (_session.isAdmin || hasBack)
              _AccountMenu(session: _session, highlighted: widget.current.isAccount, onSelected: _go, onLogout: _logout, compact: true),
          ] else
            TextButton(
              onPressed: () => _go(AppRoutes.login),
              child: const Text('Log in'),
            ),
          SizedBox(width: narrow ? 2 : 4),
        ],
      ),
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
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: selected ? AppColors.ink : Colors.transparent, width: 2.5)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14.5,
              color: selected ? AppColors.ink : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  final int count;
  final bool selected;
  final VoidCallback onTap;
  const _NotificationBell({required this.count, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = count == 0 ? 'Notifications' : 'Notifications, $count unread';
    return IconButton(
      tooltip: label,
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text(count > 99 ? '99+' : '$count'),
        child: Icon(selected ? Icons.notifications : Icons.notifications_none, color: AppColors.ink, semanticLabel: label),
      ),
    );
  }
}

/// Initials avatar used in menus and profile headers.
class UserAvatar extends StatelessWidget {
  final String initials;
  final double size;
  final Color background;
  final Color foreground;

  const UserAvatar({
    super.key,
    required this.initials,
    this.size = 34,
    this.background = AppColors.ink,
    this.foreground = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: size * 0.38, height: 1),
      ),
    );
  }
}

class _AccountMenu extends StatelessWidget {
  final SessionController session;
  final bool highlighted;
  final ValueChanged<String> onSelected;
  final Future<void> Function() onLogout;
  final bool compact;
  final bool onDark = false;

  const _AccountMenu({
    required this.session,
    required this.highlighted,
    required this.onSelected,
    required this.onLogout,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final user = session.user;
    final initials = user?.initials ?? (session.isAdmin ? 'A' : '');
    final items = session.isAdmin
        ? const [
            NavDestination('My profile', Icons.person_outline, Icons.person, AppRoutes.profile, NavSection.profile),
            NavDestination('Notifications', Icons.notifications_none, Icons.notifications, AppRoutes.notifications,
                NavSection.notifications),
          ]
        : accountDestinations;
    return PopupMenuButton<String>(
      tooltip: 'Account menu',
      position: PopupMenuPosition.under,
      offset: const Offset(0, 8),
      constraints: const BoxConstraints(minWidth: 240),
      onSelected: (value) => value == '__logout__' ? onLogout() : onSelected(value),
      itemBuilder: (_) => [
        if (user != null)
          PopupMenuItem<String>(
            enabled: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 14.5)),
                  Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5)),
                ],
              ),
            ),
          ),
        if (user != null) const PopupMenuDivider(),
        for (final d in items)
          PopupMenuItem<String>(
            value: d.route,
            child: Row(children: [Icon(d.icon, size: 20, color: AppColors.textSecondary), const SizedBox(width: 12), Text(d.label)]),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: '__logout__',
          child: Row(children: [
            Icon(Icons.logout, size: 20, color: AppColors.danger),
            SizedBox(width: 12),
            Text('Log out', style: TextStyle(color: AppColors.danger)),
          ]),
        ),
      ],
      child: Container(
        padding: EdgeInsets.fromLTRB(4, 4, compact ? 4 : 10, 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadii.pill),
          border: Border.all(color: highlighted ? AppColors.ink : (onDark ? AppColors.inkSoft : AppColors.divider)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            initials.isEmpty
                ? const Icon(Icons.account_circle, size: 30, color: AppColors.textSecondary)
                : UserAvatar(initials: initials, size: 30),
            if (!compact) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  user?.firstName ?? (session.isAdmin ? 'Admin' : 'Account'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w600, color: onDark ? Colors.white : AppColors.ink),
                ),
              ),
              Icon(Icons.expand_more, size: 20, color: onDark ? Colors.white : AppColors.textSecondary),
            ],
          ],
        ),
      ),
    );
  }
}

/// Phone bottom navigation for the main sections. Shown by [AppScaffold] on
/// top-level marketplace pages below the inline-navigation width.
class CarZenBottomBar extends StatelessWidget {
  final NavSection current;
  const CarZenBottomBar({super.key, required this.current});

  static const _items = <NavDestination>[
    NavDestination('Home', Icons.home_outlined, Icons.home, AppRoutes.home, NavSection.home),
    NavDestination('Buy', Icons.directions_car_outlined, Icons.directions_car, AppRoutes.browse, NavSection.buy),
    NavDestination('Sell', Icons.sell_outlined, Icons.sell, AppRoutes.sell, NavSection.sell),
    NavDestination('Workshop', Icons.build_outlined, Icons.build, AppRoutes.services, NavSection.services),
    NavDestination('Account', Icons.person_outline, Icons.person, AppRoutes.account, NavSection.account),
  ];

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.hasInlineNav(context)) return const SizedBox.shrink();
    final navigator = Navigator.of(context);
    final path = AppNav.pathOf(ModalRoute.of(context)?.settings.name);
    var selected = _items.indexWhere((d) => d.section == current);
    if (selected < 0 && current.isAccount) selected = _items.length - 1;
    // Price check belongs with selling on phones (it is how sellers price a car).
    if (selected < 0 && current == NavSection.priceCheck) selected = 2;
    final narrow = Breakpoints.widthOf(context) < 340;
    return DecoratedBox(
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
      child: NavigationBar(
        selectedIndex: selected < 0 ? 0 : selected,
        indicatorColor: selected < 0 ? Colors.transparent : AppColors.chromeTint,
        labelBehavior:
            narrow ? NavigationDestinationLabelBehavior.onlyShowSelected : NavigationDestinationLabelBehavior.alwaysShow,
        onDestinationSelected: (index) => AppNav.go(navigator, path, _items[index].route),
        destinations: [
          for (var i = 0; i < _items.length; i++)
            NavigationDestination(
              icon: Icon(_items[i].icon),
              selectedIcon: Icon(selected == i ? _items[i].selectedIcon : _items[i].icon),
              label: _items[i].label,
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Admin console
// ---------------------------------------------------------------------------

class _AdminScaffold extends StatefulWidget {
  final AppScaffold page;
  const _AdminScaffold({required this.page});

  @override
  State<_AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<_AdminScaffold> {
  final SessionController _session = SessionController.instance;

  @override
  void initState() {
    super.initState();
    _session.refresh();
  }

  String get _path => AppNav.pathOf(ModalRoute.of(context)?.settings.name);

  void _go(String route) => AppNav.go(Navigator.of(context), _path, route);

  Future<void> _logout() async {
    final navigator = Navigator.of(context);
    await _session.signOut();
    navigator.pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final page = widget.page;
    final hasBack = page.showBackButton ?? (page.fallbackRoute != null && Navigator.of(context).canPop());
    return AnimatedBuilder(
      animation: _session,
      builder: (context, _) {
        final header = _AdminHeader(
          title: page.title ?? 'Admin',
          hasBack: hasBack,
          fallbackRoute: page.fallbackRoute,
          showMenu: width < Breakpoints.medium,
          actions: page.actions,
          session: _session,
          onGo: _go,
          onLogout: _logout,
          current: page.section,
        );
        if (width < Breakpoints.medium) {
          return Scaffold(
            backgroundColor: page.backgroundColor,
            drawer: Drawer(
              backgroundColor: AppColors.ink,
              shape: const RoundedRectangleBorder(),
              child: _AdminSidebar(current: page.section, onGo: (r) {
                Navigator.of(context).pop();
                _go(r);
              }),
            ),
            floatingActionButton: page.floatingActionButton,
            bottomNavigationBar: page.bottomBar,
            body: Column(children: [header, Expanded(child: page.body)]),
          );
        }
        final rail = width < Breakpoints.expanded;
        return Scaffold(
          backgroundColor: page.backgroundColor,
          floatingActionButton: page.floatingActionButton,
          bottomNavigationBar: page.bottomBar,
          body: Row(
            children: [
              rail
                  ? _AdminRail(current: page.section, onGo: _go)
                  : SizedBox(width: 248, child: _AdminSidebar(current: page.section, onGo: _go)),
              Expanded(child: Column(children: [header, Expanded(child: page.body)])),
            ],
          ),
        );
      },
    );
  }
}

class _AdminHeader extends StatelessWidget {
  final String title;
  final bool hasBack;
  final String? fallbackRoute;
  final bool showMenu;
  final List<Widget> actions;
  final SessionController session;
  final ValueChanged<String> onGo;
  final Future<void> Function() onLogout;
  final NavSection current;

  const _AdminHeader({
    required this.title,
    required this.hasBack,
    required this.fallbackRoute,
    required this.showMenu,
    required this.actions,
    required this.session,
    required this.onGo,
    required this.onLogout,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))),
          child: Row(
            children: [
              if (showMenu)
                Builder(
                  builder: (context) => IconButton(
                    tooltip: 'Admin menu',
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              if (hasBack) PageBackButton(fallbackRoute: fallbackRoute, color: AppColors.ink),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.heading(18),
                ),
              ),
              ...actions,
              _NotificationBell(
                count: session.unreadCount,
                selected: current == NavSection.adminNotifications,
                onTap: () => onGo(AppRoutes.notifications),
              ),
              const SizedBox(width: 4),
              _AccountMenu(
                session: session,
                highlighted: false,
                onSelected: onGo,
                onLogout: onLogout,
                compact: Breakpoints.widthOf(context) < Breakpoints.expanded,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminSidebar extends StatelessWidget {
  final NavSection current;
  final ValueChanged<String> onGo;

  const _AdminSidebar({required this.current, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.ink,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
              child: Row(
                children: [
                  AppLogo(height: 30, onDark: true, onTap: () => onGo(AppRoutes.admin)),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Text('Admin console', style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12.5)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 4, 10, 16),
                children: [
                  for (final group in adminNavGroups) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                      child: Text(
                        group.title,
                        style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    for (final d in group.items) _SidebarItem(d: d, selected: d.section == current, onTap: () => onGo(d.route)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final NavDestination d;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({required this.d, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: selected ? AppColors.inkSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.sm),
          onTap: onTap,
          hoverColor: Colors.white.withValues(alpha: 0.06),
          child: Semantics(
            selected: selected,
            button: true,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 3,
                    height: 18,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.plate : Colors.transparent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Icon(selected ? d.selectedIcon : d.icon, size: 20, color: selected ? Colors.white : AppColors.textOnDarkMuted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      d.label,
                      style: TextStyle(
                        color: selected ? Colors.white : AppColors.textOnDarkMuted,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdminRail extends StatelessWidget {
  final NavSection current;
  final ValueChanged<String> onGo;

  const _AdminRail({required this.current, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final items = [for (final g in adminNavGroups) ...g.items];
    return Container(
      width: 76,
      color: AppColors.ink,
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 14),
            AppLogo(height: 34, markOnly: true, onDark: true, onTap: () => onGo(AppRoutes.admin)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                children: [
                  for (final d in items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Tooltip(
                        message: d.label,
                        preferBelow: false,
                        child: Material(
                          color: d.section == current ? AppColors.inkSoft : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadii.sm),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                            onTap: () => onGo(d.route),
                            child: SizedBox(
                              height: 46,
                              child: Icon(
                                d.section == current ? d.selectedIcon : d.icon,
                                color: d.section == current ? AppColors.plate : AppColors.textOnDarkMuted,
                                semanticLabel: d.label,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
