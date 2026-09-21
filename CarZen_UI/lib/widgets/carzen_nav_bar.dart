import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:flutter/material.dart';

/// Which top-level area the current page belongs to (highlighted in the bar).
enum NavSection {
  login,
  register,
  home,
  buy,
  sell,
  accessories,
  favorites,
  orders,
  messages,
  notifications,
  profile,
  adminUsers,
  adminCars,
  adminOrders,
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
  final String route;
  final NavSection section;
  const _Destination(this.label, this.icon, this.route, this.section);
}

const _primary = <_Destination>[
  _Destination('Home', Icons.home_outlined, AppRoutes.home, NavSection.home),
  _Destination('Buy Car', Icons.directions_car_outlined, AppRoutes.browse, NavSection.buy),
  _Destination('Sell Car', Icons.sell_outlined, AppRoutes.sell, NavSection.sell),
  _Destination('Car Accessories', Icons.build_outlined, AppRoutes.accessories, NavSection.accessories),
];

const _account = <_Destination>[
  _Destination('Profile', Icons.person_outline_rounded, AppRoutes.profile, NavSection.profile),
  _Destination('Favorites', Icons.favorite_border_rounded, AppRoutes.favorites, NavSection.favorites),
  _Destination('My Orders', Icons.receipt_long_outlined, AppRoutes.orders, NavSection.orders),
  _Destination('Messages', Icons.chat_bubble_outline_rounded, AppRoutes.inquiries, NavSection.messages),
  _Destination('Notifications', Icons.notifications_none_rounded, AppRoutes.notifications, NavSection.notifications),
];

const _admin = <_Destination>[
  _Destination('Car Approvals', Icons.fact_check_outlined, AppRoutes.adminCars, NavSection.adminCars),
  _Destination('Manage Orders', Icons.local_shipping_outlined, AppRoutes.adminOrders, NavSection.adminOrders),
  _Destination('Manage Users', Icons.group_outlined, AppRoutes.adminUsers, NavSection.adminUsers),
];

/// The one navigation bar used by every top-level page.
///
/// * expanded width (>= 900): logo + inline links + account menu
/// * smaller widths: back button or menu button, page title, and a bottom
///   sheet menu that groups Browse / Account / Admin links
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
      showDragHandle: true,
      backgroundColor: AppColors.surface,
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

  Widget _logo() => InkWell(
        onTap: () => _go(AppRoutes.home),
        borderRadius: BorderRadius.circular(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/carzen_logo.png', height: 40),
        ),
      );

  AppBar _buildExpanded() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 24,
      title: Align(alignment: Alignment.centerLeft, child: _logo()),
      actions: [
        for (final d in _primary)
          _NavLink(label: d.label, selected: widget.current == d.section, onTap: () => _go(d.route)),
        const SizedBox(width: 8),
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
          _NavLink(label: 'Login', selected: false, onTap: () => _go(AppRoutes.login)),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: FilledButton(onPressed: () => _go(AppRoutes.register), child: const Text('Register')),
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
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: canPop
          ? const BackButton()
          : IconButton(tooltip: 'Menu', icon: const Icon(Icons.menu_rounded), onPressed: _openMenu),
      title: showTitle
          ? Text(
              widget.title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            )
          : _logo(),
      actions: [
        if (canPop) IconButton(tooltip: 'Menu', icon: const Icon(Icons.menu_rounded), onPressed: _openMenu),
        if (_session.isLoggedIn)
          IconButton(
            tooltip: 'Profile',
            icon: Icon(_session.isAdmin ? Icons.admin_panel_settings_outlined : Icons.person_outline_rounded),
            onPressed: () => _go(AppRoutes.profile),
          )
        else
          TextButton(onPressed: () => _go(AppRoutes.login), child: const Text('Log in')),
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
        style: TextButton.styleFrom(foregroundColor: AppColors.textPrimary),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: selected ? AppColors.secondary : Colors.transparent, width: 2),
            ),
          ),
          child: Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
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
        for (final d in _account)
          PopupMenuItem<String>(
            value: d.route,
            child: Row(children: [Icon(d.icon, size: 20), const SizedBox(width: 12), Text(d.label)]),
          ),
        if (isAdmin) ...[
          const PopupMenuDivider(),
          for (final d in _admin)
            PopupMenuItem<String>(
              value: d.route,
              child: Row(children: [Icon(d.icon, size: 20), const SizedBox(width: 12), Text(d.label)]),
            ),
        ],
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: '__logout__',
          child: Row(children: [Icon(Icons.logout_rounded, size: 20), SizedBox(width: 12), Text('Log out')]),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isAdmin ? Icons.admin_panel_settings_outlined : Icons.account_circle_outlined,
              color: highlighted ? AppColors.secondary : AppColors.textPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              isAdmin ? 'Admin' : 'Account',
              style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textPrimary),
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
      leading: Icon(d.icon, color: selected ? AppColors.secondary : AppColors.textPrimary),
      title: Text(
        d.label,
        style: TextStyle(fontWeight: selected ? FontWeight.w800 : FontWeight.w600, color: AppColors.textPrimary),
      ),
      selected: selected,
      onTap: () => onNavigate(d.route),
    );
  }

  Widget _heading(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(fontSize: 12, letterSpacing: 0.8, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedBuilder(
        animation: session,
        builder: (context, _) => ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 16),
          children: [
            _heading('Browse'),
            for (final d in _primary) _tile(d),
            if (session.isLoggedIn) ...[
              _heading('My account'),
              for (final d in _account) _tile(d),
              if (session.isAdmin) ...[
                _heading('Admin'),
                for (final d in _admin) _tile(d),
              ],
              const Divider(height: 24),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: AppColors.favorite),
                title: const Text('Log out', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.favorite)),
                onTap: onLogout,
              ),
            ] else ...[
              const Divider(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton(onPressed: () => onNavigate(AppRoutes.login), child: const Text('Log in')),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => onNavigate(AppRoutes.register),
                        child: const Text('Register'),
                      ),
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
