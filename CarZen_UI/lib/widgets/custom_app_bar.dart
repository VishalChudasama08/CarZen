import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Top bar shown on the Home screen: brand mark + current location on the
/// left, notification and profile actions on the right.
///
/// [location] and the tap callbacks are passed in from the screen so this
/// widget stays presentation-only and easy to wire up to real
/// location/auth state later.
class CustomHomeAppBar extends StatelessWidget {
  final String location;
  final VoidCallback? onLocationTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;
  final bool hasUnreadNotifications;

  const CustomHomeAppBar({
    super.key,
    required this.location,
    this.onLocationTap,
    this.onNotificationTap,
    this.onProfileTap,
    this.hasUnreadNotifications = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          _Logo(),
          const SizedBox(width: 10),
          Expanded(
            child: InkWell(
              onTap: onLocationTap,
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'CarZen',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          location,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                    ],
                  ),
                ],
              ),
            ),
          ),
          _IconButton(
            icon: Icons.notifications_none_rounded,
            onTap: onNotificationTap,
            showDot: hasUnreadNotifications,
          ),
          const SizedBox(width: 10),
          _IconButton(icon: Icons.person_outline_rounded, onTap: onProfileTap),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.secondary, size: 22),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool showDot;

  const _IconButton({required this.icon, this.onTap, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 42,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 22),
            if (showDot)
              Positioned(
                right: -1,
                top: -1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.favorite, shape: BoxShape.circle),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
