import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Error message shown above the Login/Register fields.
class AuthErrorBanner extends StatelessWidget {
  final String message;
  const AuthErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) => InlineError(message);
}
