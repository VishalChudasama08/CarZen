import 'package:carzen_flutter/models/service_models.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/formatters.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/network_photo.dart';
import 'package:carzen_flutter/widgets/status_pill.dart';
import 'package:carzen_flutter/widgets/surface_card.dart';
import 'package:flutter/material.dart';

/// Which tab of the customer Services area is showing.
enum ServicesTab { catalog, requests, history }

/// Catalog / My requests / History switcher shown on every customer service page.
class ServiceTabs extends StatelessWidget {
  final ServicesTab current;
  const ServiceTabs({super.key, required this.current});

  static const _items = <(ServicesTab, String, IconData, String)>[
    (ServicesTab.catalog, 'Catalog', Icons.grid_view_rounded, AppRoutes.services),
    (ServicesTab.requests, 'My requests', Icons.assignment_outlined, AppRoutes.serviceRequests),
    (ServicesTab.history, 'Service history', Icons.history_rounded, AppRoutes.serviceHistory),
  ];

  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);
    final path = AppNav.pathOf(ModalRoute.of(context)?.settings.name);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final item in _items)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                avatar: Icon(item.$3, size: 18, color: item.$1 == current ? Colors.white : AppColors.textSecondary),
                label: Text(item.$2),
                selected: item.$1 == current,
                showCheckmark: false,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: item.$1 == current ? Colors.white : AppColors.textPrimary,
                ),
                onSelected: (_) => AppNav.go(navigator, path, item.$4),
              ),
            ),
        ],
      ),
    );
  }
}

/// Catalog tile for one service.
class ServiceCard extends StatelessWidget {
  final ServiceOffering service;
  final bool selected;

  /// False for admins (they manage the catalog elsewhere, they don't book).
  final bool canSelect;
  final VoidCallback onOpen;
  final VoidCallback onToggle;

  const ServiceCard({
    super.key,
    required this.service,
    required this.selected,
    required this.canSelect,
    required this.onOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(color: selected ? AppColors.secondary : AppColors.divider, width: selected ? 2 : 1),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    NetworkPhoto(url: service.imageUrl, fallbackIcon: Icons.build_circle_rounded),
                    if (service.durationMinutes != null)
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(AppRadii.pill),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule_rounded, size: 13, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                formatDuration(service.durationMinutes!),
                                style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(service.name,
                        maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 54,
                      child: Text(
                        (service.description == null || service.description!.trim().isEmpty)
                            ? 'Professional service by the CarZen workshop team.'
                            : service.description!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            formatInr(service.price),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                          ),
                        ),
                        if (canSelect)
                          selected
                              ? FilledButton.icon(
                                  onPressed: onToggle,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    minimumSize: const Size(0, 40),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  icon: const Icon(Icons.check_rounded, size: 18),
                                  label: const Text('Added'),
                                )
                              : OutlinedButton.icon(
                                  onPressed: onToggle,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 40),
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                  ),
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Add'),
                                )
                        else
                          TextButton(onPressed: onOpen, child: const Text('Details')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label / value line used in detail panels.
class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const DetailRow(this.label, this.value, {super.key, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                fontSize: emphasize ? 16 : 14,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress through the normal request lifecycle, or a clear banner for the
/// two dead ends (cancelled / rejected).
class RequestProgress extends StatelessWidget {
  final ServiceRequestRecord request;
  const RequestProgress({super.key, required this.request});

  static const _steps = <ServiceRequestStatus>[
    ServiceRequestStatus.requested,
    ServiceRequestStatus.accepted,
    ServiceRequestStatus.scheduled,
    ServiceRequestStatus.inProgress,
    ServiceRequestStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    final status = request.status;
    if (status == ServiceRequestStatus.cancelled || status == ServiceRequestStatus.rejected) {
      final rejected = status == ServiceRequestStatus.rejected;
      final tone = rejected ? AppColors.favorite : AppColors.textSecondary;
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(color: tone.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(rejected ? Icons.block_rounded : Icons.cancel_outlined, color: tone),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                rejected ? 'This request was rejected.' : 'This request was cancelled.',
                style: TextStyle(color: tone, fontWeight: FontWeight.w700, height: 1.35),
              ),
            ),
          ],
        ),
      );
    }
    final current = _steps.indexOf(status);
    return Row(
      children: [
        for (var i = 0; i < _steps.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= current ? AppColors.secondary : AppColors.surfaceMuted,
                  ),
                  child: Icon(
                    i < current ? Icons.check_rounded : Icons.circle,
                    size: i < current ? 16 : 8,
                    color: i <= current ? Colors.white : AppColors.divider,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _steps[i].label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: i == current ? FontWeight.w800 : FontWeight.w600,
                    color: i <= current ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (i < _steps.length - 1)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 22),
                child: Container(height: 2, color: i < current ? AppColors.secondary : AppColors.surfaceMuted),
              ),
            ),
        ],
      ],
    );
  }
}

/// Summary card used in the customer "My requests" list.
class ServiceRequestCard extends StatelessWidget {
  final ServiceRequestRecord request;
  final VoidCallback onTap;
  final Widget? footer;
  final bool showCustomer;

  const ServiceRequestCard({
    super.key,
    required this.request,
    required this.onTap,
    this.footer,
    this.showCustomer = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = request;
    return SurfaceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: AppColors.cyanTint, borderRadius: BorderRadius.circular(AppRadii.md)),
                child: const Icon(Icons.build_rounded, color: AppColors.secondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text('Request #${r.id}', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusPill(label: r.status.label, tone: r.status.tone),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 18,
            runSpacing: 8,
            children: [
              _Meta(Icons.event_rounded, '${formatDate(r.scheduledDate)} · ${formatClock(r.scheduledTime)}'),
              if (r.car != null) _Meta(Icons.directions_car_outlined, r.car!.label),
              if (showCustomer && r.user != null) _Meta(Icons.person_outline_rounded, r.user!.displayName),
              _Meta(Icons.currency_rupee_rounded, formatInr(r.amount)),
            ],
          ),
          if (footer != null) ...[const SizedBox(height: 12), footer!],
        ],
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Flexible(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
      ],
    );
  }
}

/// Informational payment line. Deliberately not a button: payment is not part of this app.
String paymentInfo(ServiceRequestRecord r) {
  final status = humanizeStatus(r.paymentStatus);
  if (r.paymentMethod == null || r.paymentMethod!.isEmpty) return status;
  return '$status (${r.paymentMethod})';
}
