import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:carzen_flutter/widgets/user_badges.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/pages/change_password_screen.dart';
import 'package:carzen_flutter/pages/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/theme/app_theme.dart';


/// Own profile — `GET /v1/users/me`. Links out to Edit Profile, Change
/// Password, and (only for `role == "admin"`) the admin screens.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  late Future<UserResponse> _future;

  @override
  void initState() {
    super.initState();
    _future = _profileService.getMe();
  }

  void _refresh() => setState(() => _future = _profileService.getMe());

  Future<void> _handleLogout() async {
    await SessionController.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text('This permanently removes your CarZen account. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.favorite),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _profileService.deleteMyAccount();
      await SessionController.instance.signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (r) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      showAppSnack(context, e.message, error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CarZenNavBar(current: NavSection.profile, title: 'Profile'),
      bottomNavigationBar: const CarZenBottomBar(current: NavSection.profile),
      body: SafeArea(
        bottom: false,
        child: FutureBuilder<UserResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading profile...');
            }
            if (snapshot.hasError) {
              return ApiErrorView(error: snapshot.error!, onRetry: _refresh, fallback: 'Could not load your profile.');
            }
            final user = snapshot.data!;
            final isAdmin = user.isAdmin;
            final nav = Navigator.of(context);

            return RefreshIndicator(
              onRefresh: () async {
                _refresh();
                await _future;
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: PageContainer(
                  maxWidth: 720,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(user: user),
                      const SizedBox(height: AppSpacing.lg),
                      SurfaceCard(
                        child: Column(
                          children: [
                            _InfoRow(icon: Icons.mail_outline_rounded, label: 'Email', value: user.email),
                            _InfoRow(icon: Icons.phone_outlined, label: 'Phone', value: user.phoneNumber ?? 'Not added'),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _Group(title: 'Account', tiles: [
                        _ActionTile(
                          icon: Icons.edit_outlined,
                          title: 'Edit profile',
                          onTap: () async {
                            await nav.push(MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)));
                            _refresh();
                          },
                        ),
                        _ActionTile(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change password',
                          onTap: () => nav.push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                        ),
                        _ActionTile(
                          icon: Icons.notifications_none_rounded,
                          title: 'Notifications',
                          onTap: () => nav.pushNamed(AppRoutes.notifications),
                        ),
                      ]),
                      if (!isAdmin) ...[
                        const SizedBox(height: AppSpacing.xl),
                        _Group(title: 'Buying & selling', tiles: [
                          _ActionTile(icon: Icons.directions_car_outlined, title: 'My cars', onTap: () => nav.pushNamed(AppRoutes.sell)),
                          _ActionTile(icon: Icons.favorite_border_rounded, title: 'Favorites', onTap: () => nav.pushNamed(AppRoutes.favorites)),
                          _ActionTile(icon: Icons.receipt_long_outlined, title: 'My orders', onTap: () => nav.pushNamed(AppRoutes.orders)),
                          _ActionTile(icon: Icons.chat_bubble_outline_rounded, title: 'Messages', onTap: () => nav.pushNamed(AppRoutes.inquiries)),
                        ]),
                        const SizedBox(height: AppSpacing.xl),
                        _Group(title: 'Services', tiles: [
                          _ActionTile(icon: Icons.home_repair_service_outlined, title: 'Browse services', onTap: () => nav.pushNamed(AppRoutes.services)),
                          _ActionTile(icon: Icons.assignment_outlined, title: 'My service requests', onTap: () => nav.pushNamed(AppRoutes.serviceRequests)),
                          _ActionTile(icon: Icons.history_rounded, title: 'Service history', onTap: () => nav.pushNamed(AppRoutes.serviceHistory)),
                        ]),
                      ] else ...[
                        const SizedBox(height: AppSpacing.xl),
                        _Group(title: 'Administration', tiles: [
                          _ActionTile(icon: Icons.group_outlined, title: 'Users', onTap: () => nav.pushNamed(AppRoutes.adminUsers)),
                          _ActionTile(icon: Icons.fact_check_outlined, title: 'Car approvals', onTap: () => nav.pushNamed(AppRoutes.adminCars)),
                          _ActionTile(icon: Icons.local_shipping_outlined, title: 'Orders', onTap: () => nav.pushNamed(AppRoutes.adminOrders)),
                          _ActionTile(icon: Icons.build_circle_outlined, title: 'Service catalog', onTap: () => nav.pushNamed(AppRoutes.adminServices)),
                          _ActionTile(icon: Icons.assignment_outlined, title: 'Service requests', onTap: () => nav.pushNamed(AppRoutes.adminServiceRequests)),
                        ]),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      _Group(title: 'Session', tiles: [
                        _ActionTile(icon: Icons.logout_rounded, title: 'Log out', onTap: _handleLogout),
                        // An admin account is removed by another admin (Users), so a stray
                        // tap here can never lock the last administrator out.
                        if (!isAdmin)
                          _ActionTile(
                            icon: Icons.delete_forever_outlined,
                            title: 'Delete account',
                            color: AppColors.favorite,
                            onTap: _handleDeleteAccount,
                          ),
                      ]),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserResponse user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primarySoft],
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: AppColors.cyan,
            child: Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
              style: const TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text('@${user.username}', style: const TextStyle(color: AppColors.textOnDarkMuted)),
                const SizedBox(height: 8),
                RoleBadge(user: user),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Group extends StatelessWidget {
  final String title;
  final List<Widget> tiles;
  const _Group({required this.title, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(fontSize: 12, letterSpacing: 0.8, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border: Border.all(color: AppColors.divider),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: 56),
                tiles[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;
  const _ActionTile({required this.icon, required this.title, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color ?? AppColors.secondary),
            const SizedBox(width: 18),
            Expanded(child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: color ?? AppColors.textPrimary))),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
