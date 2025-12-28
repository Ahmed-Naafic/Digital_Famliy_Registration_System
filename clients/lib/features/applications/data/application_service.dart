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

  /// Fetch person identity from NIRA via backend
  ///
  /// [nationalId] - National ID number
  /// [token] - JWT authentication token
  /// Returns identity data from NIRA
  Future<Map<String, dynamic>> fetchPersonByNationalId({
    required String nationalId,
    required String token,
  }) async {
    debugPrint('=== IDENTITY LOOKUP START ===');
    debugPrint('National ID: $nationalId');

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/identity/nira/$nationalId');
    debugPrint('URL: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Response received:');
    debugPrint('  Status Code: ${response.statusCode}');
    debugPrint('  Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('=== IDENTITY LOOKUP SUCCESS ===');
      return body['data'] as Map<String, dynamic>? ?? {};
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to fetch identity';
      debugPrint('=== IDENTITY LOOKUP FAILED ===');
      debugPrint('Error: $message');
      throw ApplicationException(message);
    }
  }

  /// Submit a Birth application to the backend using multipart/form-data
  ///
  /// [applicantNationalId] - Applicant's National ID
  /// [child] - Child information map
  /// [fatherNationalId] - Father's National ID
  /// [motherNationalId] - Mother's National ID
  /// [fatherResidence] - Father's residence (district, sector)
  /// [motherResidence] - Mother's residence (district, sector)
  /// [documents] - List of File objects to upload
  /// [token] - JWT authentication token
  Future<Map<String, dynamic>> submitBirthApplication({
    required String applicantNationalId,
    required Map<String, dynamic> child,
    required String fatherNationalId,
    required String motherNationalId,
    required Map<String, dynamic> fatherResidence,
    required Map<String, dynamic> motherResidence,
    required String token,
    List<File> documents = const [],
  }) async {
    debugPrint('=== BIRTH APPLICATION SUBMISSION START ===');
    debugPrint('Applicant National ID: $applicantNationalId');
    debugPrint('Father National ID: $fatherNationalId');
    debugPrint('Mother National ID: $motherNationalId');

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/applications/birth');
    debugPrint('URL: $uri');

    // Create multipart request
    final request = http.MultipartRequest('POST', uri);

    // Add headers
    request.headers['Authorization'] = 'Bearer $token';
    debugPrint('Authorization header set');

    // Add form fields
    request.fields['applicantNationalId'] = applicantNationalId;
    request.fields['child'] = jsonEncode(child);
    request.fields['fatherNationalId'] = fatherNationalId;
    request.fields['motherNationalId'] = motherNationalId;
    request.fields['fatherResidence'] = jsonEncode(fatherResidence);
    request.fields['motherResidence'] = jsonEncode(motherResidence);
    debugPrint('Form fields added');

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
      debugPrint('=== BIRTH APPLICATION SUBMISSION SUCCESS ===');
      debugPrint('Response data: ${body['data']}');
      return body['data'] as Map<String, dynamic>? ?? {};
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to submit birth application';
      debugPrint('=== BIRTH APPLICATION SUBMISSION FAILED ===');
      debugPrint('Error: $message');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');
      throw ApplicationException(message);
    }
  }

  /// Submit a Marriage application (CRVS - Islamic Law)
  ///
  /// [applicantNationalId] - Applicant's National ID
  /// [groomNationalId] - Groom's National ID
  /// [brideNationalId] - Bride's National ID
  /// [wali] - Wali information {nationalId, relationship}
  /// [witnesses] - Array of 2 witness objects [{nationalId}, {nationalId}]
  /// [sheikh] - Sheikh information {nationalId}
  /// [meher] - Meher information {type, value, currency?, deferred}
  /// [marriageDetails] - Marriage details {date, district, sector, place?}
  /// [documents] - List of File objects to upload
  /// [token] - JWT authentication token
  Future<Map<String, dynamic>> submitMarriageApplication({
    required String applicantNationalId,
    required String groomNationalId,
    required String brideNationalId,
    required Map<String, dynamic> wali,
    required List<Map<String, dynamic>> witnesses,
    required Map<String, dynamic> sheikh,
    required Map<String, dynamic> meher,
    required Map<String, dynamic> marriageDetails,
    required String token,
    List<File> documents = const [],
  }) async {
    debugPrint('=== MARRIAGE APPLICATION SUBMISSION START ===');
    debugPrint('Applicant National ID: $applicantNationalId');
    debugPrint('Groom National ID: $groomNationalId');
    debugPrint('Bride National ID: $brideNationalId');

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/applications/marriage');
    debugPrint('URL: $uri');

    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['applicantNationalId'] = applicantNationalId;
    request.fields['groomNationalId'] = groomNationalId;
    request.fields['brideNationalId'] = brideNationalId;
    request.fields['wali'] = jsonEncode(wali);
    request.fields['witnesses'] = jsonEncode(witnesses);
    request.fields['sheikh'] = jsonEncode(sheikh);
    request.fields['meher'] = jsonEncode(meher);
    request.fields['marriageDetails'] = jsonEncode(marriageDetails);

    for (final file in documents) {
      if (await file.exists()) {
        final fileName = file.path.split('/').last;
        final fileExtension = fileName.split('.').last.toLowerCase();
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

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    debugPrint('Response Status: ${response.statusCode}');
    debugPrint('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      debugPrint('=== MARRIAGE APPLICATION SUBMISSION SUCCESS ===');
      return body['data'] as Map<String, dynamic>? ?? {};
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to submit marriage application';
      debugPrint('=== MARRIAGE APPLICATION SUBMISSION FAILED ===');
      debugPrint('Error: $message');
      throw ApplicationException(message);
    }
  }

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

  /// Get family members by family ID (admin only)
  ///
  /// [familyId] - Family ID
  /// [token] - JWT authentication token (must be admin)
  /// Returns list of family members
  Future<List<Map<String, dynamic>>> getFamilyMembersByFamilyId({
    required String familyId,
    required String token,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/admin/families/$familyId/members');

    debugPrint('Fetching family members for family: $familyId');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Family Members API Response Status: ${response.statusCode}');
    debugPrint('Family Members API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];

      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else {
        throw ApplicationException('Invalid response format from server');
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

  /// Get all families (admin only)
  ///
  /// [token] - JWT authentication token (must be admin)
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 50)
  /// [search] - Search query (optional)
  /// Returns families list with pagination info
  Future<Map<String, dynamic>> getAllFamilies({
    required String token,
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/families')
        .replace(queryParameters: queryParams);

    debugPrint('Fetching families from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Families API Response Status: ${response.statusCode}');
    debugPrint('Families API Response Body: ${response.body}');

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
          body['message'] as String? ?? 'Failed to fetch families';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get all citizens (admin only)
  ///
  /// [token] - JWT authentication token (must be admin)
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 50)
  /// [search] - Search query (optional)
  /// Returns citizens list with pagination info
  Future<Map<String, dynamic>> getAllCitizens({
    required String token,
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/citizens')
        .replace(queryParameters: queryParams);

    debugPrint('Fetching citizens from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Citizens API Response Status: ${response.statusCode}');
    debugPrint('Citizens API Response Body: ${response.body}');

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
          body['message'] as String? ?? 'Failed to fetch citizens';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Update service status (admin only)
  ///
  /// [serviceType] - Service type (birth, marriage, divorce, death)
  /// [enabled] - Whether service is enabled
  /// [token] - JWT authentication token (must be admin)
  Future<void> updateServiceStatus({
    required String serviceType,
    required bool enabled,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/services/$serviceType');

    debugPrint('Updating service status: $serviceType = $enabled');

    final response = await http.put(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({ 'enabled': enabled }),
    );

    debugPrint('Update Service Status API Response Status: ${response.statusCode}');
    debugPrint('Update Service Status API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to update service status';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get certificates for the logged-in citizen
  ///
  /// [token] - JWT authentication token
  /// Returns list of certificates
  Future<List<Map<String, dynamic>>> getMyCertificates({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/certificates/my');

    debugPrint('Fetching certificates: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Certificates API Response Status: ${response.statusCode}');
    debugPrint('Certificates API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];

      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      } else {
        throw ApplicationException('Invalid response format from server');
      }
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to fetch certificates';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get certificate by application ID
  ///
  /// [applicationId] - Application ID
  /// [token] - JWT authentication token
  /// Returns certificate info or null if not found
  Future<Map<String, dynamic>?> getCertificateByApplicationId({
    required String applicationId,
    required String token,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/certificates/by-application/$applicationId');

    debugPrint('Fetching certificate by application ID: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Certificate by Application API Response Status: ${response.statusCode}');
    debugPrint('Certificate by Application API Response Body: ${response.body}');

    if (response.statusCode == 404) {
      // Certificate not found - this is expected if not generated yet
      return null;
    }

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
          body['message'] as String? ?? 'Failed to get certificate';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get certificate download URL
  ///
  /// [certificateId] - Certificate ID
  /// [token] - JWT authentication token
  /// Returns download URL
  Future<String> getCertificateDownloadUrl({
    required String certificateId,
    required String token,
  }) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/certificates/$certificateId/download');

    debugPrint('Fetching certificate download URL: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Certificate Download API Response Status: ${response.statusCode}');
    debugPrint('Certificate Download API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>?;

      if (data != null && data['downloadUrl'] != null) {
        return data['downloadUrl'] as String;
      } else {
        throw ApplicationException('Invalid response format from server');
      }
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to get certificate download URL';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get all certificates (admin only)
  ///
  /// [token] - JWT authentication token (must be admin)
  /// [page] - Page number (default: 1)
  /// [limit] - Items per page (default: 50)
  /// [search] - Search query (optional)
  /// Returns certificates list with pagination info
  Future<Map<String, dynamic>> getAllCertificates({
    required String token,
    int page = 1,
    int limit = 50,
    String search = '',
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/certificates')
        .replace(queryParameters: queryParams);

    debugPrint('Fetching certificates from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Certificates API Response Status: ${response.statusCode}');
    debugPrint('Certificates API Response Body: ${response.body}');

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
          body['message'] as String? ?? 'Failed to fetch certificates';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get enabled services (for citizens)
  ///
  /// [token] - JWT authentication token
  /// Returns list of enabled service types
  Future<List<String>> getEnabledServices({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/services/enabled');

    debugPrint('Fetching enabled services: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Enabled Services API Response Status: ${response.statusCode}');
    debugPrint('Enabled Services API Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'];

      if (data is List) {
        final enabledList = data.cast<String>();
        debugPrint('Enabled services from API: $enabledList');
        return enabledList;
      } else {
        debugPrint('API returned non-list data, returning empty list');
        return [];
      }
    } else {
      debugPrint('API error, returning empty list');
      // Return empty list on error - better to show nothing than show disabled services
      return [];
    }
  }

  /// Get service-specific statistics (admin only)
  ///
  /// [token] - JWT authentication token (must be admin)
  /// Returns statistics by service type
  Future<Map<String, dynamic>> getServiceStatistics({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/services/statistics');

    debugPrint('Fetching service statistics from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Service Statistics API Response Status: ${response.statusCode}');
    debugPrint('Service Statistics API Response Body: ${response.body}');

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
          body['message'] as String? ?? 'Failed to fetch service statistics';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get admin dashboard statistics
  ///
  /// [token] - JWT authentication token (must be admin)
  /// Returns statistics object with counts
  Future<Map<String, dynamic>> getAdminStatistics({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/statistics');

    debugPrint('Fetching admin statistics from: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Admin statistics API Response Status: ${response.statusCode}');
    debugPrint('Admin statistics API Response Body: ${response.body}');

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
          body['message'] as String? ?? 'Failed to fetch admin statistics';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get applications by status (admin only)
  ///
  /// [status] - Application status: 'pending', 'approved', or 'rejected'
  /// [token] - JWT authentication token (must be admin)
  /// Returns list of applications with the specified status
  Future<List<Map<String, dynamic>>> getApplicationsByStatus({
    required String status,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/applications?status=$status');

    debugPrint('Fetching applications by status: $status from $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Applications by status API Response Status: ${response.statusCode}');
    debugPrint('Applications by status API Response Body: ${response.body}');

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
          debugPrint('API Response: Data field is a list of ${data.length} applications');
          return data.cast<Map<String, dynamic>>();
        } else {
          debugPrint('WARNING: API Response: Data field is unexpected type: ${data.runtimeType}');
          return [];
        }
      } else if (decodedBody is List) {
        debugPrint('API Response: Direct list of ${decodedBody.length} applications');
        return decodedBody.cast<Map<String, dynamic>>();
      } else {
        debugPrint('WARNING: Unexpected response format: ${decodedBody.runtimeType}');
        return [];
      }
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to fetch applications';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Get all pending applications (admin only)
  ///
  /// [token] - JWT authentication token (must be admin)
  /// Returns list of pending applications
  Future<List<Map<String, dynamic>>> getPendingApplications({
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/applications/pending');

    debugPrint('Fetching pending applications: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Pending applications API Response Status: ${response.statusCode}');
    debugPrint('Pending applications API Response Body: ${response.body}');

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
          debugPrint('API Response: Data field is a list of ${data.length} applications');
          return data.cast<Map<String, dynamic>>();
        } else {
          debugPrint('WARNING: API Response: Data field is unexpected type: ${data.runtimeType}');
          return [];
        }
      } else if (decodedBody is List) {
        debugPrint('API Response: Direct list of ${decodedBody.length} applications');
        return decodedBody.cast<Map<String, dynamic>>();
      } else {
        debugPrint('WARNING: Unexpected response format: ${decodedBody.runtimeType}');
        return [];
      }
    } else {
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;
      final message =
          body['message'] as String? ?? 'Failed to fetch pending applications';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Approve an application (admin only)
  ///
  /// [applicationId] - Application ID to approve
  /// [token] - JWT authentication token (must be admin)
  /// Returns updated application
  Future<Map<String, dynamic>> approveApplication({
    required String applicationId,
    required String token,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/applications/$applicationId/approve');

    debugPrint('Approving application: $uri');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('Approve application API Response Status: ${response.statusCode}');
    debugPrint('Approve application API Response Body: ${response.body}');

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
          body['message'] as String? ?? 'Failed to approve application';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }

  /// Reject an application (admin only)
  ///
  /// [applicationId] - Application ID to reject
  /// [token] - JWT authentication token (must be admin)
  /// [reason] - Reason for rejection
  /// Returns updated application
  Future<Map<String, dynamic>> rejectApplication({
    required String applicationId,
    required String token,
    required String reason,
  }) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}/api/admin/applications/$applicationId/reject');

    debugPrint('Rejecting application: $uri');
    debugPrint('Rejection reason: $reason');

    final response = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'reason': reason}),
    );

    debugPrint('Reject application API Response Status: ${response.statusCode}');
    debugPrint('Reject application API Response Body: ${response.body}');

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
          body['message'] as String? ?? 'Failed to reject application';
      debugPrint('API Error: $message (Status: ${response.statusCode})');
      throw ApplicationException(message);
    }
  }
}
