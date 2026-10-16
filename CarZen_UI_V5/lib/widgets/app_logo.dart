import 'package:flutter/material.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// The CarZen logo, presented as a rounded "badge".
///
/// The artwork (`assets/images/carzen_logo.png`) is a wide, opaque banner:
/// brushed-silver lettering on dark carbon fibre. On a light page it would
/// look like a stray black rectangle, so it is always shown as a deliberate
/// dark badge with rounded corners and a thin cyan hairline — which also
/// sits naturally on the navy navigation bar.
class AppLogo extends StatelessWidget {
  final double height;
  final VoidCallback? onTap;

  /// Adds a soft shadow; use on light surfaces (auth pages), not on the navy bar.
  final bool elevated;

  const AppLogo({super.key, this.height = 40, this.onTap, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height * 0.24);
    final badge = Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: radius,
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35)),
        boxShadow: elevated ? AppShadows.raised : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          'assets/images/carzen_logo.png',
          height: height,
          fit: BoxFit.contain,
          semanticLabel: 'CarZen',
          errorBuilder: (_, __, ___) => SizedBox(
            height: height,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Center(
                child: Text(
                  'CarZen',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: height * 0.42),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (onTap == null) return badge;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: badge),
    );
  }
}
