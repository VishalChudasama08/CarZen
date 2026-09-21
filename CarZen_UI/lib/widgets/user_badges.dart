import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const _Badge({required this.text, required this.color, this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.13), borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
            Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
          ],
        ),
      );
}

/// `Admin` / `User`. Legacy backend roles (seller, service_provider...) are
/// shown as `User`, matching the two-role product model.
class RoleBadge extends StatelessWidget {
  final UserResponse user;
  const RoleBadge({super.key, required this.user});

  @override
  Widget build(BuildContext context) => user.isAdmin
      ? const _Badge(text: 'Admin', color: AppColors.primary, icon: Icons.shield_outlined)
      : const _Badge(text: 'User', color: AppColors.textSecondary, icon: Icons.person_outline_rounded);
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final label = status.isEmpty ? '' : status[0].toUpperCase() + status.substring(1);
    switch (status) {
      case 'active':
        return _Badge(text: label, color: AppColors.success);
      case 'blocked':
        return _Badge(text: label, color: AppColors.favorite);
      default:
        return _Badge(text: label, color: AppColors.secondary);
    }
  }
}

class YouBadge extends StatelessWidget {
  const YouBadge({super.key});

  @override
  Widget build(BuildContext context) => const _Badge(text: 'You', color: AppColors.secondary);
}
