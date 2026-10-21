import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/pages/login_page.dart';
import 'package:carzen_flutter/routes/app_routes.dart';
import 'package:carzen_flutter/services/auth_exception.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/widgets/app_shell.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Guards a protected page. The session is validated here, when the page
/// opens (never at app start-up), through [AuthService.validateToken].
///
/// * valid session      -> shows [child]
/// * no/expired session -> "Log in to continue" with Log in / Create account
/// * server unreachable -> error + Try again (the stored session is kept)
/// * [adminOnly] but the account is not an admin -> "Admins only"
/// * [userOnly] but the account is an admin -> explanation and a link to the
///   admin console, instead of a confusing 403 from the API
class RequireAuth extends StatefulWidget {
  final Widget child;
  final bool adminOnly;
  final bool userOnly;

  const RequireAuth({super.key, required this.child, this.adminOnly = false, this.userOnly = false});

  @override
  State<RequireAuth> createState() => _RequireAuthState();
}

class _RequireAuthState extends State<RequireAuth> {
  final AuthService _auth = AuthService();
  late Future<UserResponse?> _future = _auth.validateToken();

  void _recheck() {
    setState(() => _future = _auth.validateToken());
    SessionController.instance.refresh();
  }

  Future<void> _openLogin() async {
    final signedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginPage(returnToPrevious: true)),
    );
    if (signedIn == true && mounted) _recheck();
  }

  Widget _frame(Widget body) => AppScaffold(section: NavSection.none, body: SafeArea(child: body));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserResponse?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _frame(const LoadingView(label: 'Checking your session...'));
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is AuthException ? error.message : 'We could not check your session. Check your connection and try again.';
          return _frame(ErrorStateView(message: message, onRetry: _recheck));
        }
        final user = snapshot.data;
        if (user == null) {
          return _frame(EmptyStateView(
            icon: Icons.lock_outline,
            title: 'Log in to continue',
            message: 'This page is part of your CarZen account. Log in, or create a free account in a minute.',
            action: Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(onPressed: _openLogin, child: const Text('Log in')),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
                  child: const Text('Create account'),
                ),
              ],
            ),
          ));
        }
        if (widget.adminOnly && !user.isAdmin) {
          return _frame(EmptyStateView(
            icon: Icons.shield_outlined,
            title: 'Admins only',
            message: 'Your account does not have access to the admin console.',
            action: FilledButton(onPressed: () => AppNav.goFrom(context, AppRoutes.home), child: const Text('Go to home')),
          ));
        }
        if (widget.userOnly && user.isAdmin) {
          return _frame(EmptyStateView(
            icon: Icons.shield_outlined,
            title: 'Not available for admin accounts',
            message: 'Buying, selling, messaging and workshop bookings are done from customer accounts. Manage the marketplace from the admin console.',
            action: FilledButton(
              onPressed: () => AppNav.goFrom(context, AppRoutes.admin),
              child: const Text('Open admin console'),
            ),
          ));
        }
        return widget.child;
      },
    );
  }
}
