import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Semantic colour families for status labels.
enum StatusTone { neutral, info, success, warning, danger, highlight }

extension StatusToneX on StatusTone {
  Color get color => switch (this) {
        StatusTone.neutral => AppColors.textSecondary,
        StatusTone.info => AppColors.chrome,
        StatusTone.success => AppColors.success,
        StatusTone.warning => AppColors.warning,
        StatusTone.danger => AppColors.danger,
        StatusTone.highlight => AppColors.ink,
      };

  Color get tint => switch (this) {
        StatusTone.neutral => AppColors.surfaceMuted,
        StatusTone.info => AppColors.chromeTint,
        StatusTone.success => AppColors.successTint,
        StatusTone.warning => AppColors.warningTint,
        StatusTone.danger => AppColors.dangerTint,
        StatusTone.highlight => AppColors.plateTint,
      };
}

/// Small label for statuses ("In progress", "Paid"). A leading dot plus the
/// word carries the meaning; colour reinforces it.
class StatusPill extends StatelessWidget {
  final String label;
  final StatusTone tone;
  final IconData? icon;

  const StatusPill({super.key, required this.label, this.tone = StatusTone.neutral, this.icon});

  @override
  Widget build(BuildContext context) {
    final color = tone.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: tone.tint, borderRadius: BorderRadius.circular(AppRadii.xs)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 13, color: color)
          else
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: tone == StatusTone.neutral ? AppColors.textPrimary : color, fontWeight: FontWeight.w600, fontSize: 12),
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
