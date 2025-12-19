import 'dart:io';

/// API related constants and helpers.
///
/// Uses an Android–emulator-safe base URL (10.0.2.2) by default for development.
class ApiConstants {
  ApiConstants._();

  /// Base URL for the backend API.
  ///
  /// - Android emulator: uses 10.0.2.2 to reach host `localhost`.
  /// - Other platforms: defaults to `localhost`.
  static String get baseUrl {
    // You can adjust the port to match your Node.js server port (e.g. 3000).
    const port = 5000;

    if (Platform.isAndroid) {
      return 'http://172.16.6.105:$port';
    }

    return 'http://localhost:$port';
  }

  /// Auth endpoints
  static String get register => '$baseUrl/api/auth/register';
  static String get login => '$baseUrl/api/auth/login';
}
