import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/service_catalog_api.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/page_container.dart';
import 'package:carzen_flutter/widgets/paged_controller.dart';
import 'package:carzen_flutter/widgets/pagination_bar.dart';
import 'package:carzen_flutter/widgets/service_widgets.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Customer service catalog — `GET /v1/services` (public, paginated, searchable).
///
/// Browsing needs no login. Picking services is local state; the booking form
/// (`/services/book`) is the protected step and validates the session itself.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  static const int _pageSize = 6;

  final _api = ServiceCatalogApi();
  final _session = SessionController.instance;
  final _searchController = TextEditingController();
  late final PagedController<ServiceOffering> _paged;

  String _search = '';

  /// Selection survives page changes and searches.
  final Map<int, ServiceOffering> _selected = {};

  @override
  void initState() {
    super.initState();
    _session.refresh();
    _paged = PagedController<ServiceOffering>(
      limit: _pageSize,
      fetch: (page, limit) => _api.list(page: page, limit: limit, search: _search),
    );
    _paged.load();
  }

  @override
  void dispose() {
    _paged.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch(String value) {
    _search = value.trim();
    _paged.reset();
  }

  void _toggle(ServiceOffering service) {
    setState(() {
      if (_selected.containsKey(service.id)) {
        _selected.remove(service.id);
      } else {
        _selected[service.id] = service;
      }
    });
  }

  num get _total => _selected.values.fold<num>(0, (sum, s) => sum + s.price);

  void _book(Iterable<int> ids) => Navigator.of(context).pushNamed(AppRoutes.bookServices(ids));

  void _openDetails(ServiceOffering service) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _ServiceDetailSheet(
        service: service,
        canBook: !_session.isAdmin,
        selected: _selected.containsKey(service.id),
        onToggle: () {
          Navigator.of(sheetContext).pop();
          _toggle(service);
        },
        onBookNow: () {
          Navigator.of(sheetContext).pop();
          final ids = {..._selected.keys, service.id};
          _book(ids);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_paged, _session]),
      builder: (context, _) {
        final isAdmin = _session.isAdmin;
        return Scaffold(
          appBar: const CarZenNavBar(current: NavSection.services, title: 'Services'),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selected.isNotEmpty && !isAdmin)
                _SelectionTray(
                  count: _selected.length,
                  total: _total,
                  onClear: () => setState(_selected.clear),
                  onBook: () => _book(_selected.keys),
                ),
              const CarZenBottomBar(current: NavSection.services),
            ],
          ),
          body: SafeArea(
            bottom: false,
            child: RefreshIndicator(
              onRefresh: _paged.refresh,
              child: _buildScroll(context, isAdmin),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScroll(BuildContext context, bool isAdmin) {
    final width = MediaQuery.sizeOf(context).width;
    final side = PageContainer.sidePadding(width);
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: side.copyWith(top: AppSpacing.xl),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Hero(controller: _searchController, onSubmitted: _submitSearch, total: _paged.meta?.total),
                const SizedBox(height: AppSpacing.lg),
                const ServiceTabs(current: ServicesTab.catalog),
                const SizedBox(height: AppSpacing.lg),
                if (isAdmin) ...[
                  _AdminNotice(onOpen: () => Navigator.of(context).pushNamed(AppRoutes.adminServices)),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (_paged.loading && _paged.hasData)
                  const Padding(padding: EdgeInsets.only(bottom: 12), child: LinearProgressIndicator(minHeight: 3)),
              ],
            ),
          ),
        ),
        ..._buildBody(side, isAdmin),
        SliverPadding(
          padding: side.copyWith(top: AppSpacing.xl, bottom: AppSpacing.section + (_selected.isNotEmpty ? 8 : 0)),
          sliver: SliverToBoxAdapter(
            child: PaginationBar(meta: _paged.meta, busy: _paged.loading, itemLabel: 'services', onPageChanged: _paged.goTo),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildBody(EdgeInsets side, bool isAdmin) {
    if (_paged.isFirstLoad) {
      return [
        SliverPadding(padding: side, sliver: const SliverToBoxAdapter(child: SkeletonGrid(count: 6, tileHeight: 340))),
      ];
    }
    if (_paged.error != null && !_paged.hasData) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: ApiErrorView(error: _paged.error!, onRetry: _paged.refresh, fallback: 'Could not load services.'),
        ),
      ];
    }
    if (!_paged.hasData) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateView(
            icon: Icons.build_circle_outlined,
            title: _search.isEmpty ? 'No services available yet' : 'No services match "$_search"',
            message: _search.isEmpty
                ? 'The CarZen workshop has not published any services yet. Please check back soon.'
                : 'Try a different word, or clear the search to see the full catalog.',
            action: _search.isEmpty
                ? null
                : OutlinedButton(
                    onPressed: () {
                      _searchController.clear();
                      _submitSearch('');
                    },
                    child: const Text('Clear search'),
                  ),
          ),
        ),
      ];
    }
    return [
      if (_paged.error != null)
        SliverPadding(
          padding: side,
          sliver: SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InlineError('Could not refresh this page: ${_paged.error}'),
            ),
          ),
        ),
      SliverPadding(
        padding: side,
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 380,
            mainAxisExtent: 352,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final service = _paged.items[index];
              return ServiceCard(
                service: service,
                selected: _selected.containsKey(service.id),
                canSelect: !isAdmin,
                onOpen: () => _openDetails(service),
                onToggle: () => _toggle(service),
              );
            },
            childCount: _paged.items.length,
          ),
        ),
      ),
    ];
  }
}

class _Hero extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final int? total;

  const _Hero({required this.controller, required this.onSubmitted, required this.total});

  @override
  Widget build(BuildContext context) {
    final compact = Breakpoints.isCompact(context);
    return Container(
      padding: EdgeInsets.all(compact ? 20 : 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primarySoft],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppRadii.pill),
            ),
            child: const Text(
              'CARZEN WORKSHOP',
              style: TextStyle(color: AppColors.cyan, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Car care, booked in minutes.',
            style: TextStyle(color: Colors.white, fontSize: compact ? 26 : 34, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.6),
          ),
          const SizedBox(height: 8),
          Text(
            total == null
                ? 'Pick one or more services, choose a time that suits you, and we will take it from there.'
                : '${formatCount(total!)} service${total == 1 ? '' : 's'} to choose from. Pick a few, choose a time, and we take it from there.',
            style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 14.5, height: 1.45),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
              decoration: InputDecoration(
                hintText: 'Search services (e.g. oil change)',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: controller,
                  builder: (_, value, __) => value.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: 'Clear',
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            controller.clear();
                            onSubmitted('');
                          },
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminNotice extends StatelessWidget {
  final VoidCallback onOpen;
  const _AdminNotice({required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cyanTint,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          const Icon(Icons.admin_panel_settings_outlined, color: AppColors.secondary),
          const Text(
            "You're signed in as an admin. This is the customer view; manage services from Service Catalog.",
            style: TextStyle(fontWeight: FontWeight.w600, height: 1.35),
          ),
          FilledButton(onPressed: onOpen, child: const Text('Open Service Catalog')),
        ],
      ),
    );
  }
}

class _SelectionTray extends StatelessWidget {
  final int count;
  final num total;
  final VoidCallback onClear;
  final VoidCallback onBook;

  const _SelectionTray({required this.count, required this.total, required this.onClear, required this.onBook});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$count service${count == 1 ? '' : 's'} selected',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                        ),
                        Text(
                          'Estimated ${formatInr(total)}',
                          style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12.5),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onClear,
                    style: TextButton.styleFrom(foregroundColor: AppColors.textOnDarkMuted),
                    child: const Text('Clear'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: onBook,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(0, 44), padding: const EdgeInsets.symmetric(horizontal: 20)),
                    child: const Text('Book now'),
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

class _ServiceDetailSheet extends StatelessWidget {
  final ServiceOffering service;
  final bool canBook;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onBookNow;

  const _ServiceDetailSheet({
    required this.service,
    required this.canBook,
    required this.selected,
    required this.onToggle,
    required this.onBookNow,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.9, maxWidth: 640),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: NetworkPhoto(url: service.imageUrl, fallbackIcon: Icons.build_circle_rounded),
                ),
              ),
              const SizedBox(height: 16),
              Text(service.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(formatInr(service.price),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  if (service.durationMinutes != null)
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(formatDuration(service.durationMinutes!), style: Theme.of(context).textTheme.bodyMedium),
                    ]),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                (service.description == null || service.description!.trim().isEmpty)
                    ? 'No further details have been added for this service yet.'
                    : service.description!,
                style: const TextStyle(height: 1.55, color: AppColors.textSecondary, fontSize: 14.5),
              ),
              const SizedBox(height: 20),
              if (canBook) ...[
                ElevatedButton.icon(
                  onPressed: onBookNow,
                  icon: const Icon(Icons.event_available_rounded),
                  label: const Text('Book this service'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: onToggle,
                  icon: Icon(selected ? Icons.remove_circle_outline_rounded : Icons.add_rounded),
                  label: Text(selected ? 'Remove from my selection' : 'Add to my selection'),
                ),
              ] else
                const Text(
                  'Admins manage services from Service Catalog; booking is done from user accounts.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.4),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
