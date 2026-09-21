import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/pages/login_page.dart';
import 'package:carzen_flutter/services/auth_exception.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:flutter/material.dart';

/// Keeps public browsing public while consistently protecting mutations.
///
/// Nothing here runs at startup: it is only called right before a protected
/// action (favorite, order, sell, profile...).
class AuthGate {
  AuthGate._();

  /// Returns `true` when the user holds a valid session, prompting for login
  /// when they don't. If the server can't be reached the user is told so and
  /// the stored session is left untouched (no logout, no login prompt).
  static Future<bool> requireAuthenticated(BuildContext context) async {
    final auth = AuthService();
    UserResponse? user;
    try {
      user = await auth.validateToken();
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
      return false;
    }
    if (user != null) return true;
    if (!context.mounted) return false;
    return (await Navigator.of(context).push<bool>(
          MaterialPageRoute(builder: (_) => const LoginPage(returnToPrevious: true)),
        )) ??
        false;
  }
}
