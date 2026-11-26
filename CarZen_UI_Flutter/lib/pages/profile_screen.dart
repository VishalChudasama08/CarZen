import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/marketplace_models.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/buyer_service.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/services/seller_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/listing_card.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// The signed-in user's home base: profile, what's happening when buying
/// and selling, recently viewed cars, and every account area.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profile = ProfileService();
  final _buyer = BuyerService();
  final _seller = SellerService();

  late Future<UserResponse> _me;
  Future<BuyerDashboard>? _buyerStats;
  Future<SellerDashboard>? _sellerStats;
  Future<List<RecentlyViewed>>? _recent;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _me = _profile.getMe().then((user) {
      SessionController.instance.updateUser(user);
      if (!user.isAdmin) {
        _buyerStats = _buyer.dashboard();
        _sellerStats = _seller.dashboard();
        _recent = _buyer.recentlyViewed(limit: 8).catchError((_) => <RecentlyViewed>[]);
      }
      return user;
    });
  }

  Future<void> _logout() async {
    await SessionController.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
  }

  Future<void> _deleteAccount() async {
    final ok = await confirmAction(
      context,
      title: 'Delete your account?',
      message: 'Your profile, saved cars and messages are removed and you are signed out. This cannot be undone.',
      confirmLabel: 'Delete account',
      destructive: true,
    );
    if (!ok) return;
    try {
      await _profile.deleteMyAccount();
      await SessionController.instance.signOut();
      if (!mounted) return;
      showAppSnack(context, 'Your account was deleted');
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    }
  }

  void _go(String route) => Navigator.of(context).pushNamed(route).then((_) {
        if (mounted) setState(_load);
      });

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      section: NavSection.account,
      title: 'My account',
      showBottomNav: true,
      body: FutureBuilder<UserResponse>(
        future: _me,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const LoadingView(label: 'Loading your account...');
          if (snap.hasError) return ApiErrorView(error: snap.error!, onRetry: () => setState(_load));
          return _content(context, snap.data!);
        },
      ),
    );
  }

  Widget _content(BuildContext context, UserResponse user) {
    final width = Breakpoints.widthOf(context);
    final wide = width >= Breakpoints.expanded;
    final compact = width < Breakpoints.medium;

    final profileCard = _ProfileCard(user: user, onEdit: () => _go(AppRoutes.profileEdit));

    final groups = user.isAdmin
        ? [
            _LinkGroup('Administration', [
              _Link(Icons.space_dashboard_outlined, 'Open the admin console', AppRoutes.admin),
            ]),
            _LinkGroup('Account', [
              _Link(Icons.edit_outlined, 'Edit profile', AppRoutes.profileEdit),
              _Link(Icons.lock_outline, 'Change password', AppRoutes.profilePassword),
              _Link(Icons.notifications_none, 'Notifications', AppRoutes.notifications),
            ]),
          ]
        : [
            _LinkGroup('Buying', [
              _Link(Icons.favorite_border, 'Saved cars', AppRoutes.favorites),
              _Link(Icons.receipt_long_outlined, 'Orders', AppRoutes.orders),
              _Link(Icons.chat_bubble_outline, 'Messages', AppRoutes.messages),
              _Link(Icons.history, 'Recently viewed', AppRoutes.recentlyViewed),
              _Link(Icons.workspace_premium_outlined, 'Purchase history', AppRoutes.purchases),
              _Link(Icons.star_outline, 'My reviews', AppRoutes.profileReviews),
              _Link(Icons.flag_outlined, 'Listings I reported', AppRoutes.profileReports),
            ]),
            _LinkGroup('Selling', [
              _Link(Icons.garage_outlined, 'My cars', AppRoutes.sell),
              _Link(Icons.inventory_2_outlined, 'Orders received', AppRoutes.sales),
              _Link(Icons.contact_phone_outlined, 'Contact preferences', AppRoutes.profileContact),
              _Link(Icons.query_stats, 'Price check', AppRoutes.priceCheck),
            ]),
            _LinkGroup('Workshop', [
              _Link(Icons.event_note_outlined, 'Service bookings', AppRoutes.serviceRequests),
              _Link(Icons.history_edu_outlined, 'Service history', AppRoutes.serviceHistory),
              _Link(Icons.home_outlined, 'Saved addresses', AppRoutes.profileAddresses),
            ]),
            _LinkGroup('Account', [
              _Link(Icons.edit_outlined, 'Edit profile', AppRoutes.profileEdit),
              _Link(Icons.lock_outline, 'Change password', AppRoutes.profilePassword),
              _Link(Icons.notifications_none, 'Notifications', AppRoutes.notifications),
            ]),
          ];

    final linkPanels = [
      for (final g in groups) ...[_GroupPanel(group: g, onGo: _go), const SizedBox(height: 16)],
      _SignOutPanel(onLogout: _logout, onDelete: user.isAdmin ? null : _deleteAccount),
    ];

    final overview = user.isAdmin
        ? const <Widget>[]
        : <Widget>[
            _BuyerOverview(future: _buyerStats, onGo: _go),
            const SizedBox(height: 16),
            _SellerOverview(future: _sellerStats, onGo: _go),
            const SizedBox(height: 28),
            _RecentStrip(future: _recent),
          ];

    return RefreshIndicator(
      onRefresh: () async {
        setState(_load);
        await _me;
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: PageContainer(
          verticalPadding: compact ? 18 : 32,
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 340,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [profileCard, const SizedBox(height: 16), ...linkPanels]),
                    ),
                    const SizedBox(width: 28),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Hello, ${user.firstName}', style: AppText.heading(28)),
                          const SizedBox(height: 4),
                          const Text('Here is what is happening with your cars.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
                          const SizedBox(height: 20),
                          ...overview,
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [profileCard, const SizedBox(height: 16), ...overview, if (overview.isNotEmpty) const SizedBox(height: 24), ...linkPanels],
                ),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserResponse user;
  final VoidCallback onEdit;
  const _ProfileCard({required this.user, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(AppRadii.lg)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(initials: user.initials, size: 56, background: AppColors.plate, foreground: AppColors.ink),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName, style: AppText.heading(19, color: Colors.white)),
                    const SizedBox(height: 2),
                    Text('@${user.username}', style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13.5)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _darkRow(Icons.mail_outline, user.email),
          _darkRow(Icons.phone_outlined, user.phoneNumber ?? 'No phone number added'),
          if (user.createdAtDate != null) _darkRow(Icons.calendar_today_outlined, 'Member since ${formatDate(user.createdAtDate)}'),
          if (user.isAdmin) _darkRow(Icons.shield_outlined, 'Administrator'),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.transparent,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
            ),
            child: const Text('Edit profile'),
          ),
        ],
      ),
    );
  }

  Widget _darkRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 17, color: AppColors.textOnDarkMuted),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14))),
          ],
        ),
      );
}

class _Link {
  final IconData icon;
  final String label;
  final String route;
  const _Link(this.icon, this.label, this.route);
}

class _LinkGroup {
  final String title;
  final List<_Link> links;
  const _LinkGroup(this.title, this.links);
}

class _GroupPanel extends StatelessWidget {
  final _LinkGroup group;
  final ValueChanged<String> onGo;
  const _GroupPanel({required this.group, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Semantics(header: true, child: Text(group.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textSecondary))),
          ),
          for (final l in group.links)
            ListTile(
              leading: Icon(l.icon, size: 22),
              title: Text(l.label),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
              onTap: () => onGo(l.route),
              visualDensity: const VisualDensity(vertical: -1),
            ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}

class _SignOutPanel extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback? onDelete;
  const _SignOutPanel({required this.onLogout, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(onPressed: onLogout, icon: const Icon(Icons.logout, size: 19), label: const Text('Log out')),
        if (onDelete != null)
          TextButton(onPressed: onDelete, style: TextButton.styleFrom(foregroundColor: AppColors.danger), child: const Text('Delete account')),
      ],
    );
  }
}

class _OverviewPanel extends StatelessWidget {
  final String title;
  final List<(String, int?, String)> items;
  final ValueChanged<String> onGo;
  final bool loading;
  const _OverviewPanel({required this.title, required this.items, required this.onGo, required this.loading});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: AppText.heading(16)),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, c) {
            final cols = c.maxWidth >= 560 ? items.length : 2;
            final w = (c.maxWidth - (cols - 1) * 10) / cols;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final i in items)
                  SizedBox(
                    width: w,
                    child: Material(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppRadii.md),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.md),
                        onTap: () => onGo(i.$3),
                        child: Semantics(
                          button: true,
                          label: '${i.$1}: ${i.$2 ?? 'loading'}',
                          excludeSemantics: true,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                loading ? const SkeletonBox(width: 30, height: 24) : Text('${i.$2 ?? 0}', style: AppText.price(24)),
                                const SizedBox(height: 4),
                                Text(i.$1, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _BuyerOverview extends StatelessWidget {
  final Future<BuyerDashboard>? future;
  final ValueChanged<String> onGo;
  const _BuyerOverview({required this.future, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BuyerDashboard>(
      future: future,
      builder: (context, snap) {
        final d = snap.data;
        return _OverviewPanel(
          title: 'Buying',
          loading: snap.connectionState != ConnectionState.done,
          onGo: onGo,
          items: [
            ('Saved cars', d?.favorites, AppRoutes.favorites),
            ('Open conversations', d?.activeInquiries, AppRoutes.messages),
            ('Recently viewed', d?.recentlyViewed, AppRoutes.recentlyViewed),
            ('Purchases', d?.purchases, AppRoutes.purchases),
          ],
        );
      },
    );
  }
}

class _SellerOverview extends StatelessWidget {
  final Future<SellerDashboard>? future;
  final ValueChanged<String> onGo;
  const _SellerOverview({required this.future, required this.onGo});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SellerDashboard>(
      future: future,
      builder: (context, snap) {
        final d = snap.data;
        return _OverviewPanel(
          title: 'Selling',
          loading: snap.connectionState != ConnectionState.done,
          onGo: onGo,
          items: [
            ('Live listings', d?.activeListings, AppRoutes.sell),
            ('Waiting for review', d?.pendingApprovals, AppRoutes.sell),
            ('Buyer questions', d?.inquiries, '${AppRoutes.messages}?tab=selling'),
            ('Sold', d?.soldCars, AppRoutes.sales),
          ],
        );
      },
    );
  }
}

class _RecentStrip extends StatelessWidget {
  final Future<List<RecentlyViewed>>? future;
  const _RecentStrip({required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RecentlyViewed>>(
      future: future,
      builder: (context, snap) {
        final items = (snap.data ?? const <RecentlyViewed>[]).map((r) => r.listing).toList();
        if (items.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionTitle(
              'Recently viewed',
              trailing: TextButton(onPressed: () => Navigator.of(context).pushNamed(AppRoutes.recentlyViewed), child: const Text('See all')),
            ),
            ListingCollection(
              listings: items.take(Breakpoints.isCompact(context) ? 3 : 4).toList(),
              maxColumns: 2,
              minTileWidth: 260,
              onOpen: (ListingDetail l) => Navigator.of(context).pushNamed(AppRoutes.carDetails(l.id, l.title)),
            ),
          ],
        );
      },
    );
  }
}
