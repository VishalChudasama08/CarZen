import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:flutter/material.dart';

/// Used only for areas with no corresponding current backend API.
class IntegrationUnavailableScreen extends StatelessWidget {
  final String title;
  final String message;
  final NavSection section;

  const IntegrationUnavailableScreen({
    super.key,
    required this.title,
    required this.message,
    this.section = NavSection.none,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: CarZenNavBar(current: section, title: title),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.extension_off_outlined, size: 52, color: AppColors.textSecondary),
                  const SizedBox(height: 16),
                  Text('Not available yet', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
          ),
        ),
      );
}
