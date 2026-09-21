import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/pages/login_page.dart';
import 'package:carzen_flutter/services/auth_exception.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:carzen_flutter/services/session_controller.dart';
import 'package:carzen_flutter/widgets/carzen_nav_bar.dart';
import 'package:carzen_flutter/widgets/state_views.dart';
import 'package:flutter/material.dart';

/// Guards a protected page. Validation happens here, when the protected page
/// is opened (never at app start-up), through the existing
/// [AuthService.validateToken].
///
/// * valid session      -> shows [child]
/// * no/expired session -> "Sign in required" state with Login / Register
/// * server unreachable -> error + Retry (the stored session is kept)
/// * [adminOnly] but the account is not an admin -> "Admins only" state
class RequireAuth extends StatefulWidget {
  final Widget child;
  final bool adminOnly;

  const RequireAuth({super.key, required this.child, this.adminOnly = false});

  @override
  State<RequireAuth> createState() => _RequireAuthState();
}

class _RequireAuthState extends State<RequireAuth> {
  final AuthService _auth = AuthService();
  late Future<UserResponse?> _future;

  @override
  void initState() {
    super.initState();
    _future = _auth.validateToken();
  }

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

  Widget _frame(Widget body) => Scaffold(appBar: const CarZenNavBar(), body: SafeArea(child: body));

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
          final message = error is AuthException ? error.message : 'Could not verify your session.';
          return _frame(ErrorStateView(message: message, onRetry: _recheck));
        }
        final user = snapshot.data;
        if (user == null) {
          return _frame(EmptyStateView(
            icon: Icons.lock_outline_rounded,
            title: 'Sign in required',
            message: 'Log in or create a free account to continue.',
            action: Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton(onPressed: _openLogin, child: const Text('Log in')),
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pushNamed('/Register'),
                  child: const Text('Create account'),
                ),
              ],
            ),
          ));
        }
        if (widget.adminOnly && user.role != 'admin') {
          return _frame(const EmptyStateView(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Admins only',
            message: 'Your account does not have access to this area.',
          ));
        }
        return widget.child;
      },
    );
  }
}
