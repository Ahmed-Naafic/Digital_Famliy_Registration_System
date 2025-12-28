import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

/// Service for fetching location master data (districts and sectors)
class LocationService {
  const LocationService();

  /// Get all districts (optionally filtered by region)
  /// [region] - Optional region filter (e.g., 'Banadir')
  /// Returns list of district names
  Future<List<String>> getDistricts({String? region}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/locations/districts')
          .replace(queryParameters: region != null ? {'region': region} : {});

      debugPrint('Fetching districts: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Districts API Response Status: ${response.statusCode}');
      debugPrint('Districts API Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];

        if (data is List) {
          return data.cast<String>();
        } else {
          throw Exception('Invalid response format from server');
        }
      } else {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final message =
            body['message'] as String? ?? 'Failed to fetch districts';
        debugPrint('API Error: $message (Status: ${response.statusCode})');
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Error fetching districts: $e');
      rethrow;
    }
  }

  /// Get sectors for a specific district
  /// [district] - District name (e.g., 'Hodan')
  /// [region] - Optional region filter (e.g., 'Banadir')
  /// Returns list of sector names
  Future<List<String>> getSectorsByDistrict(
    String district, {
    String? region,
  }) async {
    try {
      final queryParams = <String, String>{'district': district};
      if (region != null) {
        queryParams['region'] = region;
      }

      final uri = Uri.parse('${ApiConstants.baseUrl}/api/locations/sectors')
          .replace(queryParameters: queryParams);

      debugPrint('Fetching sectors for district $district: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Sectors API Response Status: ${response.statusCode}');
      debugPrint('Sectors API Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];

        if (data is List) {
          return data.cast<String>();
        } else {
          throw Exception('Invalid response format from server');
        }
      } else {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final message =
            body['message'] as String? ?? 'Failed to fetch sectors';
        debugPrint('API Error: $message (Status: ${response.statusCode})');
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Error fetching sectors: $e');
      rethrow;
    }
  }

  /// Get all regions
  /// Returns list of region names
  Future<List<String>> getRegions() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/locations/regions');

      debugPrint('Fetching regions: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Regions API Response Status: ${response.statusCode}');
      debugPrint('Regions API Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data'];

        if (data is List) {
          return data.cast<String>();
        } else {
          throw Exception('Invalid response format from server');
        }
      } else {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final message =
            body['message'] as String? ?? 'Failed to fetch regions';
        debugPrint('API Error: $message (Status: ${response.statusCode})');
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Error fetching regions: $e');
      rethrow;
    }
  }
}

