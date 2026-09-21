import 'package:flutter/material.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// Centered spinner for full-page loading states.
class LoadingView extends StatelessWidget {
  final String? label;
  const LoadingView({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.secondary),
          if (label != null) ...[
            const SizedBox(height: 12),
            Text(label!, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }
}

/// Shown when a list/query legitimately came back empty (not an error).
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: AppColors.divider),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textPrimary)),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13.5)),
            if (action != null) ...[const SizedBox(height: 18), action!],
          ],
        ),
      ),
    );
  }
}

/// Shown when a request failed — always paired with a retry action so the
/// user isn't stuck.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorStateView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 44, color: AppColors.favorite),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Turns any failure from a service call into the right state: a calm
/// "not available for this account yet" message for legacy-role refusals,
/// otherwise the API message (or [fallback]) with a Retry action.
class ApiErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final String fallback;

  const ApiErrorView({super.key, required this.error, required this.onRetry, this.fallback = 'Something went wrong.'});

  @override
  Widget build(BuildContext context) {
    final e = error;
    if (e is ApiException && e.isRoleRestriction) {
      return EmptyStateView(
        icon: Icons.lock_outline_rounded,
        title: "Not available for this account yet",
        message: e.message,
      );
    }
    if (e is ApiException && e.isAuthError) {
      return EmptyStateView(
        icon: Icons.lock_clock_outlined,
        title: 'Session expired',
        message: e.message,
        action: FilledButton(
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false),
          child: const Text('Log in'),
        ),
      );
    }
    if (e is ApiException && e.statusCode == 403) {
      return EmptyStateView(icon: Icons.block_outlined, title: 'No access', message: e.message);
    }
    return ErrorStateView(message: e is ApiException ? e.message : fallback, onRetry: onRetry);
  }
}
