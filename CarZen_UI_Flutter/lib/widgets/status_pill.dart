import 'package:flutter/material.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// Semantic colour families for status chips.
enum StatusTone { neutral, info, success, warning, danger }

extension StatusToneX on StatusTone {
  Color get color => switch (this) {
        StatusTone.neutral => AppColors.textSecondary,
        StatusTone.info => AppColors.secondary,
        StatusTone.success => AppColors.success,
        StatusTone.warning => AppColors.warning,
        StatusTone.danger => AppColors.favorite,
      };
}

/// Small rounded label used for statuses ("In progress", "Active", "Paid").
class StatusPill extends StatelessWidget {
  final String label;
  final StatusTone tone;
  final IconData? icon;

  const StatusPill({super.key, required this.label, this.tone = StatusTone.neutral, this.icon});

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 11.5, letterSpacing: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

/// `in_progress` -> `In progress`.
String humanizeStatus(String value) {
  final cleaned = value.replaceAll('_', ' ').trim();
  if (cleaned.isEmpty) return cleaned;
  return cleaned[0].toUpperCase() + cleaned.substring(1);
}
