import 'package:flutter/material.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// Full-width CTA button used for "Login" / "Register" / "Explore Cars"
/// style actions. Reuses the app's gold [ElevatedButton] theme and adds a
/// built-in loading spinner so screens don't have to manage that state
/// themselves.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.primary),
              )
            : Text(label),
      ),
    );
  }
}
