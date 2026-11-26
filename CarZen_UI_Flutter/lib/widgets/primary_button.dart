import 'package:flutter/material.dart';

/// Full-width primary (ink) button with a loading state that also blocks
/// repeat taps while a request is in flight.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  /// Use the plate-yellow accent style instead of ink.
  final bool accent;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? Semantics(
            label: '$label, in progress',
            child: const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white)),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 8)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );
    final onTap = isLoading ? null : onPressed;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: accent
          ? ElevatedButton(onPressed: onTap, child: child)
          : FilledButton(
              onPressed: onTap,
              style: isLoading ? FilledButton.styleFrom(disabledBackgroundColor: const Color(0xFF22344D)) : null,
              child: child,
            ),
    );
  }
}
