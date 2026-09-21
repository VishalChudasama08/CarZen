import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {

  final String title;
  final String subTitle;

  const AuthHeader({super.key, required this.title, required this.subTitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(title, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 6),
        Text(subTitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 28)
      ],
    );
  }
}