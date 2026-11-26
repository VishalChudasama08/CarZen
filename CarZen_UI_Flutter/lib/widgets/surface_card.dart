import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// The standard white card: hairline border, no resting shadow, optional
/// tap with a hover lift on pointer devices.
class SurfaceCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool shadow;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final String? semanticLabel;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.onTap,
    this.color,
    this.shadow = false,
    this.borderRadius,
    this.borderColor,
    this.semanticLabel,
  });

  @override
  State<SurfaceCard> createState() => _SurfaceCardState();
}

class _SurfaceCardState extends State<SurfaceCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(AppRadii.lg);
    final interactive = widget.onTap != null;
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      decoration: BoxDecoration(
        color: widget.color ?? AppColors.surface,
        borderRadius: radius,
        border: Border.all(color: _hover && interactive ? AppColors.lineStrong : (widget.borderColor ?? AppColors.divider)),
        boxShadow: (_hover && interactive) ? AppShadows.raised : (widget.shadow ? AppShadows.card : null),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHover: interactive ? (v) => setState(() => _hover = v) : null,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
    if (widget.semanticLabel == null) return card;
    return Semantics(label: widget.semanticLabel, button: interactive, child: card);
  }
}

/// Label/value pair used in detail panels ("Fuel  Diesel").
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final bool emphasize;

  const InfoRow({super.key, required this.label, required this.value, this.icon, this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: AppColors.textSecondary), const SizedBox(width: 10)],
          Expanded(
            flex: 4,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: emphasize
                  ? AppText.price(16)
                  : const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
