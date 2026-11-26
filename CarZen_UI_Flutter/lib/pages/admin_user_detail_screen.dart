import 'package:carzen_flutter/models/car_models.dart';
import 'package:carzen_flutter/models/enums.dart';
import 'package:carzen_flutter/models/listing_models.dart';
import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/pages/admin_cars_screen.dart' show adminApprovalLabel, adminApprovalTone;
import 'package:carzen_flutter/pages/admin_marketplace_pages.dart' show listingTone;
import 'package:carzen_flutter/pages/admin_users_screen.dart' show userStatusTone;
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/admin_listing_service.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/services/car_service.dart';
import 'package:carzen_flutter/services/profile_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/admin_user_dialogs.dart';
import 'package:carzen_flutter/widgets/admin_widgets.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// One account for an admin - `GET /v1/admin/users/{id}` - with their cars
/// (`/admin/cars?owner_id=`) and listings (`/admin/listings?seller_id=`).
class AdminUserDetailScreen extends StatefulWidget {
  final int userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final _profiles = ProfileService();
  final _cars = CarService();
  final _listings = AdminListingService();

  UserResponse? _user;
  Object? _error;
  bool _busy = false;
  List<CarRecord>? _userCars;
  List<Listing>? _userListings;
  final Set<int> _suspending = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final user = await _profiles.adminGetUser(widget.userId);
      if (!mounted) return;
      setState(() => _user = user);
      _loadRelated();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _loadRelated() async {
    try {
      final cars = await _cars.listAdminCars(limit: 50, ownerId: widget.userId);
      if (mounted) setState(() => _userCars = cars.data);
    } catch (_) {
      if (mounted) setState(() => _userCars = const []);
    }
    try {
      final listings = await _listings.list(limit: 50, sellerId: widget.userId);
      if (mounted) setState(() => _userListings = listings.data);
    } catch (_) {
      if (mounted) setState(() => _userListings = const []);
    }
  }

  Future<void> _editStatus(UserResponse user) async {
    final change = await showUserRoleStatusDialog(context, user);
    if (change == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final updated = await _profiles.adminUpdateRoleStatus(user.id, role: change.role, status: change.status);
      if (!mounted) return;
      setState(() => _user = updated);
      showAppSnack(context, '@${updated.username} is now ${updated.statusLabel.toLowerCase()}');
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(UserResponse user) async {
    if (!await confirmDeleteUser(context, user) || !mounted) return;
    setState(() => _busy = true);
    try {
      await _profiles.adminDeleteUser(user.id);
      if (!mounted) return;
      showAppSnack(context, '@${user.username} deleted');
      AppNav.goFrom(context, AppRoutes.adminUsers);
    } on ApiException catch (e) {
      if (mounted) {
        showAppSnack(context, e.message, error: true);
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _suspend(Listing l) async {
    final ok = await confirmAction(context,
        title: 'Suspend "${l.title}"?', message: 'Buyers will no longer see it.', confirmLabel: 'Suspend', destructive: true);
    if (!ok) return;
    setState(() => _suspending.add(l.id));
    try {
      await _listings.suspend(l.id);
      if (!mounted) return;
      showAppSnack(context, 'Listing suspended');
      await _loadRelated();
    } on ApiException catch (e) {
      if (mounted) showAppSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _suspending.remove(l.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    if (user == null) {
      final error = _error;
      return AppScaffold(
        section: NavSection.adminUsers,
        title: 'User',
        fallbackRoute: AppRoutes.adminUsers,
        showBackButton: true,
        body: error == null
            ? const LoadingView(label: 'Loading user...')
            : (error is ApiException && error.statusCode == 404)
                ? EmptyStateView(
                    icon: Icons.person_off_outlined,
                    title: 'User not found',
                    message: 'This account does not exist or was deleted.',
                    action: FilledButton(onPressed: () => AppNav.goFrom(context, AppRoutes.adminUsers), child: const Text('Back to users')),
                  )
                : ApiErrorView(error: error, onRetry: _load, fallback: 'This user could not be loaded.'),
      );
    }
    final isMe = user.id == SessionController.instance.user?.id;
    final wide = Breakpoints.widthOf(context) >= 1100;
    final profile = _ProfileCard(user: user, isMe: isMe, busy: _busy, onStatus: () => _editStatus(user), onDelete: () => _delete(user));
    final related = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle('Cars', subtitle: _userCars == null ? null : '${_userCars!.length} added'),
        _carsSection(),
        const SizedBox(height: 24),
        SectionTitle('Listings', subtitle: _userListings == null ? null : '${_userListings!.length} created'),
        _listingsSection(),
      ],
    );

    return AdminPage(
      section: NavSection.adminUsers,
      title: user.fullName.isEmpty ? '@${user.username}' : user.fullName,
      subtitle: 'User #${user.id}  |  Joined ${formatDate(user.createdAtDate)}',
      fallbackRoute: AppRoutes.adminUsers,
      onRefresh: _load,
      child: wide
          ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 380, child: profile),
              const SizedBox(width: 24),
              Expanded(child: related),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [profile, const SizedBox(height: 24), related]),
    );
  }

  Widget _empty(String text) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
      );

  Widget _carsSection() {
    final cars = _userCars;
    if (cars == null) return const Column(children: [SkeletonLine(), SizedBox(height: 12), SkeletonLine()]);
    if (cars.isEmpty) return _empty('No cars added.');
    return AdminTable<CarRecord>(
      items: cars,
      tableBreakpoint: 640,
      onTap: (c) => Navigator.of(context).pushNamed(AppRoutes.adminCar(c.id)),
      cardTitle: (c) => Text('${c.manufacturingYear} car #${c.id}'),
      cardBadge: (c) => StatusPill(label: adminApprovalLabel(c.approvalStatus), tone: adminApprovalTone(c.approvalStatus)),
      columns: [
        AdminColumn('Car', (c) => StackedCell('${c.manufacturingYear} car #${c.id}', c.registrationNumber ?? 'No registration'), flex: 3, showInCard: false),
        AdminColumn('Details', (c) => TextCell('${c.fuelType.label}  |  ${formatKm(c.mileageKm)}  |  ${c.city}'), flex: 4),
        AdminColumn('Status', (c) => StatusPill(label: adminApprovalLabel(c.approvalStatus), tone: adminApprovalTone(c.approvalStatus)), flex: 2, showInCard: false),
      ],
    );
  }

  Widget _listingsSection() {
    final listings = _userListings;
    if (listings == null) return const Column(children: [SkeletonLine(), SizedBox(height: 12), SkeletonLine()]);
    if (listings.isEmpty) return _empty('No listings created.');
    return AdminTable<Listing>(
      items: listings,
      tableBreakpoint: 640,
      actionsWidth: 120,
      cardTitle: (l) => Text(l.title),
      cardBadge: (l) => StatusPill(label: l.listingStatus.label, tone: listingTone(l.listingStatus)),
      columns: [
        AdminColumn('Listing', (l) => StackedCell(l.title, 'Listing #${l.id}'), flex: 4, showInCard: false),
        AdminColumn('Price', (l) => Text(formatLakh(l.askingPrice), style: AppText.figures(14)), flex: 2),
        AdminColumn('Status', (l) => StatusPill(label: l.listingStatus.label, tone: listingTone(l.listingStatus)), flex: 2, showInCard: false),
      ],
      actions: (l) {
        if (_suspending.contains(l.id)) return const [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))];
        final canSuspend = l.listingStatus == ListingStatus.active || l.listingStatus == ListingStatus.approved || l.listingStatus == ListingStatus.reserved;
        return [if (canSuspend) RowAction('Suspend', destructive: true, onPressed: () => _suspend(l))];
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final UserResponse user;
  final bool isMe;
  final bool busy;
  final VoidCallback onStatus;
  final VoidCallback onDelete;

  const _ProfileCard({required this.user, required this.isMe, required this.busy, required this.onStatus, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: user.isAdmin ? AppColors.ink : AppColors.chromeTint,
                child: Text(user.initials, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: user.isAdmin ? Colors.white : AppColors.chrome)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@${user.username}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      StatusPill(label: user.statusLabel, tone: userStatusTone(user.status)),
                      if (user.isAdmin) const StatusPill(label: 'Admin', tone: StatusTone.highlight, icon: Icons.shield_outlined),
                      if (isMe) const StatusPill(label: 'You', tone: StatusTone.info),
                    ]),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          InfoRow(label: 'Email', value: user.email),
          InfoRow(label: 'Phone', value: (user.phoneNumber ?? '').isEmpty ? 'Not added' : user.phoneNumber!),
          InfoRow(label: 'Role', value: user.isAdmin ? 'Admin' : 'Customer'),
          InfoRow(label: 'Member since', value: user.createdAtDate == null ? 'Unknown' : formatDate(user.createdAtDate)),
          InfoRow(label: 'Last updated', value: user.updatedAtDate == null ? 'Never' : formatDateTime(user.updatedAtDate)),
          const SizedBox(height: 16),
          if (isMe)
            const Text('This is your own account. Change your details from your profile.', style: TextStyle(color: AppColors.textSecondary))
          else if (busy)
            const Center(child: CircularProgressIndicator())
          else ...[
            FilledButton(onPressed: onStatus, child: const Text('Change account status')),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onDelete,
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
              child: const Text('Delete user'),
            ),
          ],
        ],
      ),
    );
  }
}
