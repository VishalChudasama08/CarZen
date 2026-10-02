import 'package:flutter/material.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/theme/app_theme.dart';

/// Shows a floating snackbar. [error] tints it red so failures are obvious.
void showAppSnack(BuildContext context, String message, {bool error = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.favorite : AppColors.primary,
      ),
    );
}

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
          const SizedBox(
            width: 34,
            height: 34,
            child: CircularProgressIndicator(color: AppColors.secondary, strokeWidth: 3),
          ),
          if (label != null) ...[
            const SizedBox(height: 14),
            Text(label!, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}

class _StateFrame extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color wellColor;
  final String title;
  final String message;
  final Widget? action;

  const _StateFrame({
    required this.icon,
    required this.iconColor,
    required this.wellColor,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(color: wellColor, shape: BoxShape.circle),
                child: Icon(icon, size: 36, color: iconColor),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.45),
              ),
              if (action != null) ...[const SizedBox(height: 20), action!],
            ],
          ),
        ),
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
  Widget build(BuildContext context) => _StateFrame(
        icon: icon,
        iconColor: AppColors.secondary,
        wellColor: AppColors.cyanTint,
        title: title,
        message: message,
        action: action,
      );
}

/// Shown when a request failed — always paired with a retry action so the
/// user isn't stuck.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
  });

  @override
  Widget build(BuildContext context) => _StateFrame(
        icon: Icons.cloud_off_rounded,
        iconColor: AppColors.favorite,
        wellColor: AppColors.favorite.withValues(alpha: 0.1),
        title: title,
        message: message,
        action: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('Try again'),
        ),
      );
}

/// Turns any failure from a service call into the right state: a calm
/// "not available for this account yet" message for legacy-role refusals,
/// a login prompt for expired sessions, a "no access" state for 403s, a
/// "not found" state for 404s, otherwise the API message with a Retry action.
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
        title: 'Not available for this account yet',
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
    if (e is ApiException && e.statusCode == 404) {
      return EmptyStateView(icon: Icons.search_off_rounded, title: 'Not found', message: e.message);
    }
    if (e is ApiException && e.isNetworkError) {
      return ErrorStateView(
        title: "Can't reach CarZen",
        message: e.message,
        onRetry: onRetry,
      );
    }
    return ErrorStateView(message: e is ApiException ? e.message : fallback, onRetry: onRetry);
  }
}

/// Compact inline error for forms and sheets.
class InlineError extends StatelessWidget {
  final String message;
  const InlineError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.favorite.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: AppColors.favorite.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.favorite, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.favorite, fontSize: 13.5, height: 1.35))),
        ],
      ),
    );
  }
}
