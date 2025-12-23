import 'package:flutter/foundation.dart';
import '../data/application_service.dart';
import '../../application_status/data/application_model.dart';

/// Application Provider
/// Manages application state and fetches applications from backend
class ApplicationProvider extends ChangeNotifier {
  ApplicationProvider({ApplicationService? applicationService})
    : _applicationService = applicationService ?? const ApplicationService();

  final ApplicationService _applicationService;

  List<Application> _applications = [];
  bool _isLoading = false;
  String? _error;

  List<Application> get applications => List.unmodifiable(_applications);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get recent applications (latest 3-5 items)
  /// Sorted by submittedAt (newest first)
  /// Does NOT modify the original list
  List<Application> get recentApplications {
    if (_applications.isEmpty) {
      return [];
    }
    // Applications are already sorted by newest first in fetchMyApplications
    // Return the first 5 items (or all if less than 5)
    return _applications.take(5).toList();
  }

  /// Fetch applications for the logged-in user
  /// Clears old list before adding new data
  Future<void> fetchMyApplications({required String token}) async {
    // Set loading state and clear error
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify UI of loading state

    try {
      final responseData = await _applicationService.getMyApplications(
        token: token,
      );

      debugPrint('=== FETCHING APPLICATIONS ===');
      debugPrint('Fetched ${responseData.length} applications from backend');

      // Clear old list before adding new data
      _applications.clear();

      // Parse and add new applications
      int successCount = 0;
      int errorCount = 0;
      for (int i = 0; i < responseData.length; i++) {
        final item = responseData[i];
        try {
          debugPrint('Parsing application ${i + 1}/${responseData.length}');
          debugPrint('Application ID: ${item['_id'] ?? item['id']}');
          debugPrint('Application type: ${item['type']}');
          debugPrint('Application status: ${item['status']}');

          final application = _parseApplicationFromBackend(item);
          _applications.add(application);
          successCount++;
          debugPrint('✓ Successfully parsed application ${i + 1}');
        } catch (e, stackTrace) {
          // Skip invalid applications but continue processing others
          errorCount++;
          debugPrint('✗ ERROR parsing application ${i + 1}: $e');
          debugPrint('Stack trace: $stackTrace');
          debugPrint('Raw application data: $item');
        }
      }

      debugPrint('=== PARSING SUMMARY ===');
      debugPrint('Total received: ${responseData.length}');
      debugPrint('Successfully parsed: $successCount');
      debugPrint('Failed to parse: $errorCount');
      debugPrint('Final list size: ${_applications.length}');

      // Sort by submitted date (newest first)
      _applications.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

      debugPrint('Total applications in list: ${_applications.length}');

      // Clear error if we successfully got data
      _error = null;
    } catch (e, stackTrace) {
      _error = e.toString();
      _applications.clear();
      debugPrint('Error fetching applications: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      // Always set loading to false and notify listeners
      _isLoading = false;
      notifyListeners(); // CRITICAL: Notify UI of state changes
    }
  }

  /// Parse backend application data to Application model
  /// Backend returns: _id, userId (populated with fullName, email), type, payload, status, createdAt, etc.
  Application _parseApplicationFromBackend(Map<String, dynamic> json) {
    try {
      debugPrint('Parsing application with keys: ${json.keys.toList()}');

      // Extract ID (could be _id or id)
      final idValue = json['_id'] ?? json['id'];
      if (idValue == null) {
        throw Exception(
          'Application ID is missing. Available keys: ${json.keys.toList()}',
        );
      }
      final id = idValue.toString();
      debugPrint('  - ID: $id');

      // Extract userId - could be ObjectId string or populated object
      String citizenId;
      String citizenName;
      final userIdValue = json['userId'];
      if (userIdValue == null) {
        // Try alternative field names
        final altUserId = json['user'] ?? json['user_id'] ?? json['userID'];
        if (altUserId == null) {
          throw Exception(
            'userId is missing. Available keys: ${json.keys.toList()}',
          );
        }
        // Use alternative field
        if (altUserId is Map<String, dynamic>) {
          final userObj = altUserId;
          final userIdObjId = userObj['_id'] ?? userObj['id'];
          if (userIdObjId == null) {
            throw Exception('Alternative userId._id is missing');
          }
          citizenId = userIdObjId.toString();
          citizenName =
              userObj['fullName'] as String? ??
              userObj['name'] as String? ??
              'Unknown';
        } else {
          citizenId = altUserId.toString();
          citizenName = 'Unknown';
        }
      } else if (userIdValue is Map<String, dynamic>) {
        // Populated user object
        final userObj = userIdValue;
        final userIdObjId = userObj['_id'] ?? userObj['id'];
        if (userIdObjId == null) {
          throw Exception('userId._id is missing in populated user object');
        }
        citizenId = userIdObjId.toString();
        citizenName =
            userObj['fullName'] as String? ??
            userObj['name'] as String? ??
            'Unknown';
        debugPrint('  - Citizen ID: $citizenId, Name: $citizenName');
      } else {
        // Just the ObjectId
        citizenId = userIdValue.toString();
        citizenName = 'Unknown';
        debugPrint('  - Citizen ID: $citizenId (unpopulated)');
      }

      // Extract type (serviceType)
      final typeStr = json['type'] as String? ?? 'birth';
      final serviceType = ApplicationType.values.firstWhere(
        (e) => e.name == typeStr,
        orElse: () => ApplicationType.birth,
      );

      // Extract status
      final statusStr = json['status'] as String? ?? 'pending';
      final status = ApplicationStatus.values.firstWhere(
        (e) => e.name == statusStr,
        orElse: () => ApplicationStatus.pending,
      );

      // Extract submitted date (createdAt from backend)
      // MongoDB returns dates in various formats, handle all of them
      DateTime submittedAt;
      try {
        // Try multiple date field names and formats
        dynamic dateValue =
            json['submittedAt'] ??
            json['submittedDate'] ??
            json['createdAt'] ??
            json['updatedAt'];

        if (dateValue == null) {
          debugPrint('WARNING: No date field found, using current time');
          submittedAt = DateTime.now();
        } else if (dateValue is String) {
          // Try parsing ISO 8601 string
          try {
            submittedAt = DateTime.parse(dateValue);
          } catch (e) {
            debugPrint('Failed to parse date string "$dateValue": $e');
            submittedAt = DateTime.now();
          }
        } else if (dateValue is int) {
          // Handle timestamp (could be milliseconds or seconds)
          if (dateValue > 1000000000000) {
            // Milliseconds timestamp
            submittedAt = DateTime.fromMillisecondsSinceEpoch(dateValue);
          } else if (dateValue > 1000000000) {
            // Seconds timestamp (10 digits)
            submittedAt = DateTime.fromMillisecondsSinceEpoch(dateValue * 1000);
          } else {
            debugPrint('WARNING: Invalid timestamp value: $dateValue');
            submittedAt = DateTime.now();
          }
        } else if (dateValue is Map) {
          // MongoDB date object format: { "$date": "2024-01-01T00:00:00.000Z" }
          final dateStr = dateValue['\$date'] ?? dateValue['date'];
          if (dateStr != null) {
            try {
              submittedAt = DateTime.parse(dateStr.toString());
            } catch (e) {
              debugPrint('Failed to parse MongoDB date object: $e');
              submittedAt = DateTime.now();
            }
          } else {
            debugPrint('WARNING: Date object missing date field: $dateValue');
            submittedAt = DateTime.now();
          }
        } else {
          debugPrint('WARNING: Unexpected date type: ${dateValue.runtimeType}');
          submittedAt = DateTime.now();
        }
      } catch (e) {
        debugPrint('Error parsing date: $e, using current time');
        submittedAt = DateTime.now();
      }

      // Extract form data (payload from backend)
      final formData =
          json['payload'] as Map<String, dynamic>? ?? <String, dynamic>{};

      // Extract rejection reason (adminComment from backend)
      final rejectionReason =
          json['rejectionReason'] as String? ?? json['adminComment'] as String?;

      // Extract certificate URL/ID
      final certificateUrl =
          json['certificateUrl'] as String? ??
          (json['certificateId'] != null
              ? json['certificateId'].toString()
              : null);

      return Application(
        id: id,
        citizenId: citizenId,
        citizenName: citizenName,
        serviceType: serviceType,
        status: status,
        submittedAt: submittedAt,
        formData: formData,
        rejectionReason: rejectionReason,
        certificateUrl: certificateUrl,
      );
    } catch (e, stackTrace) {
      debugPrint('Error in _parseApplicationFromBackend: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('JSON data: $json');
      rethrow;
    }
  }

  /// Clear applications and error state
  void clear() {
    _applications.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
