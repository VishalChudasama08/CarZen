import 'package:carzen_flutter/models/user_response.dart';
import 'package:carzen_flutter/services/api_client.dart';
import 'package:carzen_flutter/services/auth_service.dart';
import 'package:flutter/foundation.dart';

/// Local view of "is somebody signed in, as which role, and what's new".
///
/// Signed-in state and role come from the stored token (no network), so it is
/// safe for public pages and the navigation bar. It is deliberately **not** a
/// second authentication system: tokens are created, validated and cleared by
/// [AuthService], and the backend stays the authority for every protected
/// request. The cached [user] and [unreadCount] are display-only conveniences
/// fetched lazily for the navigation bar.
class SessionController extends ChangeNotifier {
  SessionController._();

  static final SessionController instance = SessionController._();

  final AuthService _auth = AuthService();

  bool _isLoggedIn = false;
  String? _role;
  bool _loaded = false;
  UserResponse? _user;
  int _unread = 0;
  DateTime? _unreadFetchedAt;
  bool _fetchingUser = false;
  bool _fetchingUnread = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get role => _role;
  bool get isAdmin => _role == 'admin';
  bool get isLoaded => _loaded;

  /// The signed-in user's profile, when it has been fetched.
  UserResponse? get user => _user;

  /// Unread notifications for the badge in the navigation bar.
  int get unreadCount => _unread;

  /// Re-reads the stored token. Cheap; call after login/logout or when a
  /// navigation bar mounts.
  Future<void> refresh() async {
    final hasToken = await _auth.hasStoredToken();
    final role = hasToken ? await _auth.storedRole() : null;
    final changed = !_loaded || hasToken != _isLoggedIn || role != _role;
    _isLoggedIn = hasToken;
    _role = role;
    _loaded = true;
    if (!hasToken) {
      _user = null;
      _unread = 0;
      _unreadFetchedAt = null;
    }
    if (changed) notifyListeners();
    if (hasToken) {
      _loadUser();
      refreshUnread();
    }
  }

  Future<void> _loadUser({bool force = false}) async {
    if (_fetchingUser || (_user != null && !force)) return;
    _fetchingUser = true;
    try {
      final json = await ApiClient().get('/users/me');
      _user = UserResponse.fromJson(json as Map<String, dynamic>);
      notifyListeners();
    } catch (_) {
      // Display-only; the nav falls back to initials from the role.
    } finally {
      _fetchingUser = false;
    }
  }

  /// Replace the cached profile after the user edits it.
  void updateUser(UserResponse user) {
    _user = user;
    notifyListeners();
  }

  /// Re-fetches the unread notification count (at most every 30 seconds
  /// unless [force] is set).
  Future<void> refreshUnread({bool force = false}) async {
    if (!_isLoggedIn || _fetchingUnread) return;
    final last = _unreadFetchedAt;
    if (!force && last != null && DateTime.now().difference(last) < const Duration(seconds: 30)) return;
    _fetchingUnread = true;
    try {
      final json = await ApiClient().get('/notifications/unread', query: {'page': 1, 'limit': 1});
      final total = ((json as Map<String, dynamic>)['pagination'] as Map<String, dynamic>?)?['total'];
      _unreadFetchedAt = DateTime.now();
      final value = total is int ? total : 0;
      if (value != _unread) {
        _unread = value;
        notifyListeners();
      }
    } catch (_) {
      // Badge is best-effort.
    } finally {
      _fetchingUnread = false;
    }
  }

  /// Called by the API client when the server rejects the stored token.
  void handleSessionExpired() {
    if (!_isLoggedIn) return;
    _isLoggedIn = false;
    _role = null;
    _user = null;
    _unread = 0;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.logout();
    _isLoggedIn = false;
    _role = null;
    _user = null;
    _unread = 0;
    _unreadFetchedAt = null;
    _loaded = true;
    notifyListeners();
  }
}
