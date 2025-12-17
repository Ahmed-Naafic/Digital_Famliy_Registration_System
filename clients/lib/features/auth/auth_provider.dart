import 'package:flutter/foundation.dart';
import 'data/user_model.dart';

/// Authentication Provider
/// Manages authentication state throughout the application using ChangeNotifier
/// This provider holds the current user and login status, and notifies listeners
/// when authentication state changes
class AuthProvider extends ChangeNotifier {
  /// Current logged-in user
  /// null if user is not logged in
  User? _user;

  /// Login status flag
  /// true if user is logged in, false otherwise
  bool _isLoggedIn = false;

  /// Getter for current user
  /// Returns null if no user is logged in
  User? get user => _user;

  /// Getter for login status
  /// Returns true if user is logged in
  bool get isLoggedIn => _isLoggedIn;

  /// Login method
  /// Sets the current user and updates login status
  /// Notifies all listeners about the state change
  ///
  /// [user] - The user object to set as current user
  void login(User user) {
    _user = user;
    _isLoggedIn = true;
    notifyListeners();
  }

  /// Logout method
  /// Clears the current user and sets login status to false
  /// Notifies all listeners about the state change
  void logout() {
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  /// Update user information
  /// Updates the current user's data
  /// Notifies all listeners about the state change
  ///
  /// [updatedUser] - The updated user object
  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}


