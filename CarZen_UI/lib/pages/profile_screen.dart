import 'package:carzen_flutter/widgets/content_width.dart';
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
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: AppColors.favorite))),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CarZenNavBar(current: NavSection.profile, title: 'Profile'),
      body: ContentWidth(
        maxWidth: 720,
        child: SafeArea(
        child: FutureBuilder<UserResponse>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const LoadingView(label: 'Loading profile...');
            }
            if (snapshot.hasError) {
              final message =
                  snapshot.error is ApiException ? (snapshot.error as ApiException).message : 'Could not load your profile.';
              return ErrorStateView(message: message, onRetry: _refresh);
            }
            final user = snapshot.data!;
            final isAdmin = user.role == 'admin';

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.secondary, fontSize: 24, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 2),
                          Text('@${user.username}', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _InfoRow(icon: Icons.mail_outline_rounded, label: 'Email', value: user.email),
                _InfoRow(
                    icon: Icons.phone_outlined, label: 'Phone', value: user.phoneNumber ?? 'Not added'),
                // _InfoRow(icon: Icons.badge_outlined, label: 'Role', value: user.role),
                const SizedBox(height: 20),
                _ActionTile(
                  icon: Icons.edit_outlined,
                  title: 'Edit Profile',
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)));
                    _refresh();
                  },
                ),
                _ActionTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                ),
                const SizedBox(height: 16),
                _ActionTile(
                  icon: Icons.directions_car_outlined,
                  title: 'My Cars',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.sell),
                ),
                _ActionTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Favorites',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.favorites),
                ),
                _ActionTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'My Orders',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.orders),
                ),
                _ActionTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Messages',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.inquiries),
                ),
                _ActionTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  onTap: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
                ),
                if (isAdmin) ...[
                  const SizedBox(height: 16),
                  Text('Admin', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _ActionTile(
                    icon: Icons.group_outlined,
                    title: 'Manage Users',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminUsers),
                  ),
                  _ActionTile(
                    icon: Icons.fact_check_outlined,
                    title: 'Car Approvals',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminCars),
                  ),
                  _ActionTile(
                    icon: Icons.receipt_long_outlined,
                    title: 'Manage Orders',
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.adminOrders),
                  ),
                ],
                const SizedBox(height: 20),
                _ActionTile(icon: Icons.logout_rounded, title: 'Log Out', onTap: _handleLogout),
                _ActionTile(
                  icon: Icons.delete_forever_outlined,
                  title: 'Delete Account',
                  color: AppColors.favorite,
                  onTap: _handleDeleteAccount,
                ),
              ],
            );
          },
        ),
      ),
      ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.divider)),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color ?? AppColors.primary),
                const SizedBox(width: 12),
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                const Spacer(),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
