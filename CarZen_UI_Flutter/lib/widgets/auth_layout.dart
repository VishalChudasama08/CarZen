import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/utils/breakpoints.dart';
import 'package:flutter/material.dart';

/// Shared frame for Login and Register.
///
/// * desktop: one panel split in two - what an account lets you do on an
///   ink side, the form on the other
/// * tablet/phone: just the form, centred, in a readable column
class AuthLayout extends StatelessWidget {
  final Widget child;
  final String sideTitle;

  const AuthLayout({super.key, required this.child, this.sideTitle = 'One account for buying, selling and servicing your car.'});

  static const _points = <(IconData, String)>[
    (Icons.favorite_border, 'Save cars and get told when the price changes'),
    (Icons.chat_bubble_outline, 'Message sellers and keep every reply in one thread'),
    (Icons.garage_outlined, 'List your car - our team checks it before it goes live'),
    (Icons.event_available_outlined, 'Book workshop slots and pay online or at the counter'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = Breakpoints.widthOf(context);
    final wide = width >= 1000;
    final narrow = width < 380;

    final form = Padding(padding: EdgeInsets.all(wide ? 44 : (narrow ? 18 : 28)), child: child);

    if (!wide) {
      return SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(narrow ? 12 : 16, 20, narrow ? 12 : 16, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.xl),
                  border: Border.all(color: AppColors.divider),
                ),
                child: form,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.xl),
                border: Border.all(color: AppColors.divider),
                boxShadow: AppShadows.raised,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 9,
                      child: Container(
                        color: AppColors.ink,
                        padding: const EdgeInsets.fromLTRB(44, 48, 44, 44),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sideTitle, style: AppText.heading(30, color: Colors.white, height: 1.18)),
                            const SizedBox(height: 32),
                            for (final p in _points)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 18),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(p.$1, color: AppColors.plate, size: 22),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        p.$2,
                                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.45),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Spacer(),
                            const Text(
                              'Free to join. No card needed.',
                              style: TextStyle(color: AppColors.textOnDarkMuted, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(flex: 10, child: form),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
