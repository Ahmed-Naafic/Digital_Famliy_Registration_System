import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import 'user_model.dart';

/// Exception type used for readable API errors.
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => message;
}

/// HTTP layer for authentication.
///
/// Responsible for calling the backend auth endpoints and translating
/// responses into domain models or readable errors.
class AuthService {
  const AuthService();

  /// Register a new user.
  ///
  /// Returns a tuple of `(token, user, role)` on success.
  Future<({String token, User user, String role})> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConstants.register);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': name,
        'email': email,
        'password': password,
      }),
    );

    return _handleAuthResponse(response);
  }

  /// Log in an existing user.
  ///
  /// Returns a tuple of `(token, user, role)` on success.
  Future<({String token, User user, String role})> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse(ApiConstants.login);

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _handleAuthResponse(response);
  }

  ({String token, User user, String role}) _handleAuthResponse(
    http.Response response,
  ) {
    try {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = body['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

        final token = data['token'] as String? ?? '';
        if (token.isEmpty) {
          throw const AuthException('Invalid response: token missing.');
        }

        final userJson =
            (data['user'] as Map<String, dynamic>? ?? <String, dynamic>{});
        
        // Get role from top-level data first, then from user object, default to 'citizen'
        final role = data['role'] as String? ?? 
                     userJson['role'] as String? ?? 
                     'citizen';
        
        debugPrint('🔐 Auth Response - Role: $role');
        debugPrint('🔐 Auth Response - User JSON: $userJson');
        debugPrint('🔐 Auth Response - Data: $data');

        final user = User.fromJson(userJson);

        return (token: token, user: user, role: role);
      } else {
        final message =
            body['message'] as String? ??
            'Authentication failed. Please try again.';
        throw AuthException(message);
      }
    } on AuthException {
      rethrow;
    } catch (_) {
      throw const AuthException('Unable to process server response.');
    }
  }
}
