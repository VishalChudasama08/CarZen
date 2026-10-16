import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:flutter/material.dart';

/// Reusable Back button used across all screens that are not top-level
/// navigation destinations, across phone, tablet, and desktop viewports.
///
/// If there is no previous route on the Navigator stack (e.g. direct deep link
/// or page refresh), it gracefully navigates to [fallbackRoute] or [AppRoutes.home].
class PageBackButton extends StatelessWidget {
  final String? fallbackRoute;
  final VoidCallback? onPressed;
  final Color? color;
  final String tooltip;

  const PageBackButton({
    super.key,
    this.fallbackRoute,
    this.onPressed,
    this.color,
    this.tooltip = 'Back',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(Icons.arrow_back_rounded, color: color ?? Colors.white),
      constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
          return;
        }
        final navigator = Navigator.of(context);
        if (navigator.canPop()) {
          navigator.pop();
        } else if (fallbackRoute != null && fallbackRoute!.isNotEmpty) {
          navigator.pushNamedAndRemoveUntil(fallbackRoute!, (r) => false);
        } else {
          navigator.pushNamedAndRemoveUntil(AppRoutes.home, (r) => false);
        }
      },
    );
  }
}
