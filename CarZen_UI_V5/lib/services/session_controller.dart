import 'package:carzen_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Local-only view of "is somebody signed in, and as which role".
///
/// It only reads secure storage (no network), so it is safe for public pages
/// and the navigation bar to use. It is deliberately **not** a second
/// authentication system: tokens are still created, validated and cleared by
/// [AuthService]. The role comes from the JWT purely to decide which links to
/// show; the backend stays the authority for every protected request.
class SessionController extends ChangeNotifier {
  SessionController._();

  static final SessionController instance = SessionController._();

  final AuthService _auth = AuthService();

  bool _isLoggedIn = false;
  String? _role;
  bool _loaded = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isLoaded => _loaded;

  /// Re-reads the stored token. Cheap; call after login/logout or when a
  /// navigation bar mounts.
  Future<void> refresh() async {
    final hasToken = await _auth.hasStoredToken();
    final role = hasToken ? await _auth.storedRole() : null;
    if (_loaded && hasToken == _isLoggedIn && role == _role) return;
    _isLoggedIn = hasToken;
    _role = role;
    _loaded = true;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.logout();
    _isLoggedIn = false;
    _role = null;
    _loaded = true;
    notifyListeners();
  }
}
