import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme Provider
/// Manages app theme state (light/dark mode) using ChangeNotifier
/// Persists theme preference using SharedPreferences
class ThemeProvider extends ChangeNotifier {
  /// SharedPreferences key for storing theme mode
  static const String _themeKey = 'theme_mode';

  /// Current theme mode
  /// true = dark mode, false = light mode
  bool _isDarkMode = true; // Default to dark mode

  /// Getter for current theme mode
  bool get isDarkMode => _isDarkMode;

  /// Getter for ThemeMode enum
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Constructor - loads saved theme preference
  ThemeProvider() {
    _loadThemePreference();
  }

  /// Load theme preference from SharedPreferences
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themeKey) ?? true; // Default to dark
      notifyListeners();
    } catch (e) {
      // If error, use default dark mode
      _isDarkMode = true;
    }
  }

  /// Toggle between light and dark mode
  /// Saves preference to SharedPreferences
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    // Save preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isDarkMode);
    } catch (e) {
      // Handle error silently
    }
  }

  /// Set theme mode explicitly
  /// [isDark] - true for dark mode, false for light mode
  Future<void> setTheme(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      notifyListeners();

      // Save preference
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_themeKey, _isDarkMode);
      } catch (e) {
        // Handle error silently
      }
    }
  }
}

