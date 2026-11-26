import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subTitle;

  const AuthHeader({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(header: true, child: Text(title, style: AppText.heading(26))),
          const SizedBox(height: 8),
          Text(subTitle, style: const TextStyle(fontSize: 15, height: 1.5, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
