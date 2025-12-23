import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/user_model.dart';
import 'data/auth_service.dart';

/// Authentication Provider
///
/// Manages authentication state, including JWT token, user info, role,
/// and persistence using [SharedPreferences].
class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? authService})
    : _authService = authService ?? const AuthService();

  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'auth_user_id';
  static const _userNameKey = 'auth_user_name';
  static const _userEmailKey = 'auth_user_email';
  static const _roleKey = 'auth_role';

  final AuthService _authService;

  User? _user;
  String? _token;
  String _role = 'citizen';
  bool _isLoading = false;
  bool _isInitialized = false;

  User? get user => _user;
  String? get token => _token;
  String get role => _role;
  bool get isAuthenticated => _token != null && _user != null;
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Initialize auth state from local storage.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final storedToken = prefs.getString(_tokenKey);
    final storedId = prefs.getString(_userIdKey);
    final storedName = prefs.getString(_userNameKey);
    final storedEmail = prefs.getString(_userEmailKey);
    final storedRole = prefs.getString(_roleKey);

    // Only restore session if token exists and is not empty
    if (storedToken != null &&
        storedToken.isNotEmpty &&
        storedId != null &&
        storedId.isNotEmpty &&
        storedName != null &&
        storedName.isNotEmpty &&
        storedEmail != null &&
        storedEmail.isNotEmpty) {
      _token = storedToken;
      _user = User(id: storedId, name: storedName, email: storedEmail);
      _role = storedRole ?? 'citizen';
    } else {
      // Clear any invalid data
      _token = null;
      _user = null;
      _role = 'citizen';
    }

    _isInitialized = true;
    notifyListeners();
  }

  /// Perform login via [AuthService] and persist the session.
  Future<void> login({required String email, required String password}) async {
    await _authenticate(
      action: () => _authService.login(email: email, password: password),
    );
  }

  /// Perform registration via [AuthService] and persist the session.
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _authenticate(
      action: () =>
          _authService.register(name: name, email: email, password: password),
    );
  }

  Future<void> _authenticate({
    required Future<({String token, User user, String role})> Function() action,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await action();

      _token = result.token;
      _user = result.user;
      _role = result.role;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, result.token);
      await prefs.setString(_userIdKey, result.user.id);
      await prefs.setString(_userNameKey, result.user.name);
      await prefs.setString(_userEmailKey, result.user.email);
      await prefs.setString(_roleKey, result.role);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear auth state and remove token from storage.
  Future<void> logout() async {
    _user = null;
    _token = null;
    _role = 'citizen';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
    await prefs.remove(_roleKey);

    notifyListeners();
  }
}
