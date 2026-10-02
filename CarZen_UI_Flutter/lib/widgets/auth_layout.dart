import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:carzen_flutter/widgets/app_logo.dart';
import 'package:flutter/material.dart';

/// Shared frame for Login and Register.
///
/// * wide screens: a navy brand panel on the left (logo + what CarZen offers)
///   and the form in a white card on the right
/// * phones/tablets: a logo badge above the form card, centred and scrollable
class AuthLayout extends StatelessWidget {
  final Widget child;
  const AuthLayout({super.key, required this.child});

  static const _points = <(IconData, String, String)>[
    (Icons.verified_outlined, 'Verified listings', 'Cars reviewed by the CarZen team before they go live.'),
    (Icons.sell_outlined, 'Sell with confidence', 'List your car in a few guided steps.'),
    (Icons.home_repair_service_outlined, 'Book a service', 'Choose services and a time slot online.'),
  ];

  @override
  Widget build(BuildContext context) {
    final wide = Breakpoints.isExpanded(context);
    final card = Container(
      padding: EdgeInsets.all(wide ? 36 : 22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.xl),
        border: Border.all(color: AppColors.divider),
        boxShadow: AppShadows.raised,
      ),
      child: child,
    );

    if (!wide) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AppLogo(height: 52, elevated: true)),
                  const SizedBox(height: 22),
                  card,
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primaryDeep, AppColors.primary, AppColors.primarySoft],
              ),
            ),
            padding: const EdgeInsets.all(56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(height: 64),
                const SizedBox(height: 36),
                const Text(
                  'Buy, sell and service\nyour car in one place.',
                  style: TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -1),
                ),
                const SizedBox(height: 32),
                for (final p in _points)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: Icon(p.$1, color: AppColors.cyan, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.$2, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                              const SizedBox(height: 2),
                              Text(p.$3, style: const TextStyle(color: AppColors.textOnDarkMuted, height: 1.4)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(40),
                child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: card),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
