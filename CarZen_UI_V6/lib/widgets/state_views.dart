import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/api_exception.dart';
import 'package:carzen_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Shows a floating snackbar. [error] marks it as a failure (red, with an
/// icon - colour is never the only signal).
void showAppSnack(BuildContext context, String message, {bool error = false, SnackBarAction? action}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  final width = MediaQuery.sizeOf(context).width;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        width: width > 640 ? 480 : null,
        backgroundColor: error ? AppColors.danger : AppColors.ink,
        action: action,
        content: Row(
          children: [
            Icon(error ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Asks the user to confirm an action. Returns `true` when confirmed.
/// [destructive] styles the confirm button in red.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: Text(message)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          style: TextButton.styleFrom(foregroundColor: AppColors.ink),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: destructive ? FilledButton.styleFrom(backgroundColor: AppColors.danger) : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Centered spinner for full-page loading states.
class LoadingView extends StatelessWidget {
  final String? label;
  const LoadingView({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: label ?? 'Loading',
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 30, height: 30, child: CircularProgressIndicator(strokeWidth: 3)),
            if (label != null) ...[
              const SizedBox(height: 14),
              Text(label!, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
            ],
          ],
        ),
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
  final bool compact;

  const _StateFrame({
    required this.icon,
    required this.iconColor,
    required this.wellColor,
    required this.title,
    required this.message,
    this.action,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 48 : 60,
            height: compact ? 48 : 60,
            decoration: BoxDecoration(color: wellColor, borderRadius: BorderRadius.circular(AppRadii.lg)),
            child: Icon(icon, size: compact ? 24 : 28, color: iconColor),
          ),
          SizedBox(height: compact ? 12 : 18),
          Text(title, textAlign: TextAlign.center, style: AppText.heading(compact ? 16 : 18)),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14.5, height: 1.5),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
    if (compact) return Padding(padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16), child: Center(child: content));
    return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: content));
  }
}

/// Shown when a list/query legitimately came back empty (not an error).
/// Empty states point to the next action.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  /// Smaller variant for use inside cards and sections.
  final bool compact;

  const EmptyStateView({
    super.key,
    this.icon = Icons.inbox_outlined,
    required this.title,
    required this.message,
    this.action,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => _StateFrame(
        icon: icon,
        iconColor: AppColors.chrome,
        wellColor: AppColors.chromeTint,
        title: title,
        message: message,
        action: action,
        compact: compact,
      );
}

/// Shown when a request failed - always with a retry action.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String title;
  final bool compact;

  const ErrorStateView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'This didn\'t load',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => _StateFrame(
        icon: Icons.cloud_off_outlined,
        iconColor: AppColors.danger,
        wellColor: AppColors.dangerTint,
        title: title,
        message: message,
        compact: compact,
        action: OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Try again'),
        ),
      );
}

/// Turns any failure from a service call into the right state: a login
/// prompt for expired sessions, "no access" for 403s, "not found" for 404s,
/// a connection message for network failures, otherwise the API message with
/// a retry action.
class ApiErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final String fallback;
  final bool compact;

  const ApiErrorView({
    super.key,
    required this.error,
    required this.onRetry,
    this.fallback = 'Something went wrong.',
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final e = error;
    if (e is ApiException && e.isRoleRestriction) {
      return EmptyStateView(compact: compact, icon: Icons.lock_outline, title: 'Not available for this account', message: e.message);
    }
    if (e is ApiException && e.isAuthError) {
      return EmptyStateView(
        compact: compact,
        icon: Icons.lock_clock_outlined,
        title: 'Your session has ended',
        message: 'Log in again to continue where you left off.',
        action: FilledButton(
          onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false),
          child: const Text('Log in'),
        ),
      );
    }
    if (e is ApiException && e.statusCode == 403) {
      return EmptyStateView(compact: compact, icon: Icons.block, title: 'No access', message: e.message);
    }
    if (e is ApiException && e.statusCode == 404) {
      return EmptyStateView(compact: compact, icon: Icons.search_off, title: 'Not found', message: e.message);
    }
    if (e is ApiException && e.isNetworkError) {
      return ErrorStateView(compact: compact, title: "Can't reach CarZen", message: e.message, onRetry: onRetry);
    }
    return ErrorStateView(compact: compact, message: e is ApiException ? e.message : fallback, onRetry: onRetry);
  }
}

/// Compact inline error for forms and sheets. Announced to screen readers.
class InlineError extends StatelessWidget {
  final String message;
  const InlineError(this.message, {super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.dangerTint,
          borderRadius: BorderRadius.circular(AppRadii.sm),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.danger, fontSize: 13.5, height: 1.4))),
          ],
        ),
      ),
    );
  }
}

/// Informational callout (neutral, warning or success) used inside pages.
class Callout extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final CalloutTone tone;
  final Widget? action;

  const Callout({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.info_outline,
    this.tone = CalloutTone.info,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      CalloutTone.info => (AppColors.chromeTint, AppColors.chrome),
      CalloutTone.warning => (AppColors.warningTint, AppColors.warning),
      CalloutTone.success => (AppColors.successTint, AppColors.success),
      CalloutTone.danger => (AppColors.dangerTint, AppColors.danger),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadii.md)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(title!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.ink, fontSize: 14.5)),
                  const SizedBox(height: 2),
                ],
                Text(message, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13.5, height: 1.45)),
                if (action != null) ...[const SizedBox(height: 8), action!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum CalloutTone { info, warning, success, danger }
