import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

/// Exception type for application API errors
class ApplicationException implements Exception {
  final String message;

  const ApplicationException(this.message);

  @override
  String toString() => message;
}

/// Service for handling application submissions to backend
class ApplicationService {
  const ApplicationService();

  /// Submit an application to the backend using multipart/form-data
  ///
  /// [type] - Application type: "birth", "marriage", "divorce", or "death"
  /// [payload] - Complete payload object with child and parents data
  /// [documents] - List of File objects to upload
  /// [token] - JWT authentication token
  Future<Map<String, dynamic>> submitApplication({
    required String type,
    required Map<String, dynamic> payload,
    required String token,
    List<File> documents = const [],
  }) async {
    debugPrint('=== APPLICATION SUBMISSION START ===');
    debugPrint('Type: $type');
    debugPrint('Payload: ${jsonEncode(payload)}');
    debugPrint('Token present: ${token.isNotEmpty}');
    debugPrint('Documents count: ${documents.length}');

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/applications');
    debugPrint('URL: $uri');

    // Create multipart request
    final request = http.MultipartRequest('POST', uri);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    debugPrint('Authorization header set');

    // Add form fields
    request.fields['type'] = type;
    request.fields['payload'] = jsonEncode(payload);
    debugPrint('Form fields added: type=$type, payload length=${jsonEncode(payload).length}');

    // Add files
    for (final file in documents) {
      if (await file.exists()) {
        final fileName = file.path.split('/').last;
        final fileExtension = fileName.split('.').last.toLowerCase();

        // Determine content type
        String contentType;
        if (fileExtension == 'pdf') {
          contentType = 'application/pdf';
        } else if (['jpg', 'jpeg'].contains(fileExtension)) {
          contentType = 'image/jpeg';
        } else if (fileExtension == 'png') {
          contentType = 'image/png';
        } else {
          contentType = 'application/octet-stream';
        }

        final fileStream = http.ByteStream(file.openRead());
        final fileLength = await file.length();
        final multipartFile = http.MultipartFile(
          'documents',
          fileStream,
          fileLength,
          filename: fileName,
          contentType: http.MediaType.parse(contentType),
        );

        request.files.add(multipartFile);
      }
    }

    // Send request
    debugPrint('Sending POST request to backend...');
    final streamedResponse = await request.send();
    debugPrint('Request sent, waiting for response...');
    
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('Response received:');
    debugPrint('  Status Code: ${response.statusCode}');
    debugPrint('  Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('=== APPLICATION SUBMISSION SUCCESS ===');
      debugPrint('Response data: ${body['data']}');
      return body['data'] as Map<String, dynamic>? ?? {};
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to submit application';
      debugPrint('=== APPLICATION SUBMISSION FAILED ===');
      debugPrint('Error: $message');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      throw ApplicationException(message);
    }
  }

  /// Get all applications for the logged-in user
  ///
  /// [token] - JWT authentication token
  /// Returns list of applications from the backend
  /// Returns empty list only if backend returns empty array
  Future<List<Map<String, dynamic>>> getMyApplications({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/applications/my');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decodedBody = jsonDecode(response.body);

      // Debug: Log raw response structure
      debugPrint('API Response status: ${response.statusCode}');
      debugPrint('API Response type: ${decodedBody.runtimeType}');

      // Handle different response formats
      if (decodedBody is List) {
        // Response is directly a list of applications
        debugPrint('API returned List with ${decodedBody.length} items');
        return decodedBody.cast<Map<String, dynamic>>();
      } else if (decodedBody is Map<String, dynamic>) {
        final body = decodedBody;
        final data = body['data'];

        debugPrint('API returned Map, data type: ${data?.runtimeType}');

        // Only return empty if data is explicitly null or empty array
        if (data == null) {
          debugPrint('WARNING: Backend returned null data field');
          return [];
        }

        if (data is List) {
          // Backend returned array in data field
          debugPrint('API data is List with ${data.length} items');
          return data.cast<Map<String, dynamic>>();
        } else if (data is Map<String, dynamic>) {
          // Backend returned single object in data field - wrap in list
          debugPrint('API data is single Map object, wrapping in list');
          return [data];
        } else {
          // Unexpected data type
          debugPrint('WARNING: Unexpected data type: ${data.runtimeType}');
          return [];
        }
      } else {
        // Unexpected response format
        debugPrint(
          'WARNING: Unexpected response format: ${decodedBody.runtimeType}',
        );
        return [];
      }
    } else {
      // Handle error response
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to fetch applications';
      throw ApplicationException(message);
    }
  }

  /// Get married couples for the logged-in user's family
  ///
  /// [token] - JWT authentication token
  /// Returns list of married couples from the backend
  Future<List<Map<String, dynamic>>> getMarriedCouples({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/family/married-couples');

    debugPrint('Fetching married couples from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Married couples API Response Status: ${response.statusCode}');
    debugPrint('Married couples API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decodedBody = jsonDecode(response.body);

      if (decodedBody is Map<String, dynamic>) {
        final body = decodedBody;
        final data = body['data'];

        if (data == null) {
          debugPrint('API Response: Data field is null, returning empty list');
          return [];
        }

        if (data is List) {
          debugPrint('API Response: Data field is a list of ${data.length} couples');
          return data.cast<Map<String, dynamic>>();
        } else {
          debugPrint('WARNING: API Response: Data field is unexpected type: ${data.runtimeType}');
          return [];
        }
      } else if (decodedBody is List) {
        debugPrint('API Response: Direct list of ${decodedBody.length} couples');
        return decodedBody.cast<Map<String, dynamic>>();
      } else {
        debugPrint('WARNING: Unexpected response format: ${decodedBody.runtimeType}');
        return [];
      }
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to fetch married couples';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Check if the logged-in user has a family
  ///
  /// [token] - JWT authentication token
  /// Returns { hasFamily: bool, familyId?: string }
  Future<Map<String, dynamic>> checkFamily({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/family/check');

    debugPrint('Checking family existence: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Family check API Response Status: ${response.statusCode}');
    debugPrint('Family check API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>? ?? {};

      return data;
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to check family';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get all family members for the logged-in user's family
  ///
  /// [token] - JWT authentication token
  /// Returns list of family members
  Future<List<Map<String, dynamic>>> getFamilyMembers({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/family/members');

    debugPrint('Fetching family members: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Family members API Response Status: ${response.statusCode}');
    debugPrint('Family members API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final dynamic decodedBody = jsonDecode(response.body);

      if (decodedBody is Map<String, dynamic>) {
        final body = decodedBody;
        final data = body['data'];

        if (data == null) {
          debugPrint('API Response: Data field is null, returning empty list');
          return [];
        }

        if (data is List) {
          debugPrint('API Response: Data field is a list of ${data.length} members');
          return data.cast<Map<String, dynamic>>();
        } else {
          debugPrint('WARNING: API Response: Data field is unexpected type: ${data.runtimeType}');
          return [];
        }
      } else if (decodedBody is List) {
        debugPrint('API Response: Direct list of ${decodedBody.length} members');
        return decodedBody.cast<Map<String, dynamic>>();
      } else {
        debugPrint('WARNING: Unexpected response format: ${decodedBody.runtimeType}');
        return [];
      }
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to fetch family members';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Create a new family member for the logged-in user's family
  ///
  /// [token] - JWT authentication token
  /// [memberData] - Family member data (firstName, lastName, gender, etc.)
  /// Returns created family member
  Future<Map<String, dynamic>> addFamilyMember({
    required String token,
    required Map<String, dynamic> memberData,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/family/members');

    debugPrint('Creating family member: $uri');
    debugPrint('Member data: ${jsonEncode(memberData)}');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(memberData),
    );

    debugPrint('Add family member API Response Status: ${response.statusCode}');
    debugPrint('Add family member API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data != null) {
        return data;
      } else {
        throw ApplicationException('Invalid response format from server');
      }
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to create family member';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Create a new family for the logged-in user
  ///
  /// [token] - JWT authentication token
  /// [familyData] - Family data (familyName, address, etc.)
  /// Returns created family
  Future<Map<String, dynamic>> createFamily({
    required String token,
    required Map<String, dynamic> familyData,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/family/create');

    debugPrint('Creating family: $uri');
    debugPrint('Family data: ${jsonEncode(familyData)}');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(familyData),
    );

    debugPrint('Create family API Response Status: ${response.statusCode}');
    debugPrint('Create family API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data != null) {
        return data;
      } else {
        throw ApplicationException('Invalid response format from server');
      }
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to create family';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }
}
