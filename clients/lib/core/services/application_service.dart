import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../features/application_status/data/application_model.dart';
import '../../features/certificate_viewer/data/certificate_model.dart';
import '../notifications/notification_model.dart';
import '../../features/auth/data/user_model.dart';
import '../../features/applications/data/application_service.dart' as real_service;
import '../constants/api_constants.dart';

/// Application Service
/// Manages applications, certificates, and notifications
class ApplicationService extends ChangeNotifier {
  final List<Application> _applications = [];
  final List<Certificate> _certificates = [];
  final List<AppNotification> _notifications = [];

  List<Application> get applications => List.unmodifiable(_applications);
  List<Certificate> get certificates => List.unmodifiable(_certificates);
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Get applications for a specific citizen
  List<Application> getApplicationsForCitizen(String citizenId) {
    return _applications.where((app) => app.citizenId == citizenId).toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  /// Get recent applications for a specific citizen (last 3-5)
  List<Application> getRecentApplicationsForCitizen(
    String citizenId, {
    int limit = 5,
  }) {
    final apps = getApplicationsForCitizen(citizenId);
    return apps.take(limit).toList();
  }

  /// Get certificates for a specific citizen (only approved)
  List<Certificate> getCertificatesForCitizen(String citizenId) {
    return _certificates.where((cert) => cert.citizenId == citizenId).toList()
      ..sort((a, b) => b.issueDate.compareTo(a.issueDate));
  }

  List<Application> _pendingApplications = [];
  List<Application> _approvedApplications = [];
  List<Application> _rejectedApplications = [];

  List<Application> get pendingApplications => List.unmodifiable(_pendingApplications);
  List<Application> get approvedApplications => List.unmodifiable(_approvedApplications);
  List<Application> get rejectedApplications => List.unmodifiable(_rejectedApplications);

  /// Get pending applications (for admin) - backward compatibility
  List<Application> getPendingApplications() {
    return List.from(_pendingApplications)
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
  }

  /// Fetch all applications by status from backend (admin only)
  Future<void> fetchAllApplications(String token) async {
    try {
      final realService = const real_service.ApplicationService();

      // Fetch all three statuses in parallel
      final results = await Future.wait([
        realService.getApplicationsByStatus(status: 'pending', token: token),
        realService.getApplicationsByStatus(status: 'approved', token: token),
        realService.getApplicationsByStatus(status: 'rejected', token: token),
      ]);

      // Convert and store each status
      _pendingApplications.clear();
      _approvedApplications.clear();
      _rejectedApplications.clear();
      _applications.clear();

      // Process pending
      for (final item in results[0]) {
        try {
          final app = _convertBackendToApplication(Map<String, dynamic>.from(item));
          // Only add if application has valid ID
          if (app.id.isNotEmpty) {
            _pendingApplications.add(app);
            _applications.add(app);
          } else {
            debugPrint('Warning: Skipping pending application with empty ID');
          }
        } catch (e) {
          debugPrint('Error converting pending application: $e');
        }
      }

      // Process approved
      for (final item in results[1]) {
        try {
          final app = _convertBackendToApplication(Map<String, dynamic>.from(item));
          // Only add if application has valid ID
          if (app.id.isNotEmpty) {
            _approvedApplications.add(app);
            _applications.add(app);
          } else {
            debugPrint('Warning: Skipping approved application with empty ID');
          }
        } catch (e) {
          debugPrint('Error converting approved application: $e');
        }
      }

      // Process rejected
      for (final item in results[2]) {
        try {
          final app = _convertBackendToApplication(Map<String, dynamic>.from(item));
          // Only add if application has valid ID
          if (app.id.isNotEmpty) {
            _rejectedApplications.add(app);
            _applications.add(app);
          } else {
            debugPrint('Warning: Skipping rejected application with empty ID');
          }
        } catch (e) {
          debugPrint('Error converting rejected application: $e');
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all applications: $e');
      rethrow;
    }
  }

  /// Fetch pending applications from backend (admin only)
  /// Kept for backward compatibility
  Future<void> fetchPendingApplications(String token) async {
    await fetchAllApplications(token);
  }

  /// Convert backend application format to Application model
  Application _convertBackendToApplication(Map<String, dynamic> json) {
    // Safely extract application ID
    final applicationId = json['_id']?.toString() ?? 
                         json['id']?.toString() ?? 
                         '';
    
    if (applicationId.isEmpty) {
      throw Exception('Application ID is missing in backend response');
    }

    // Safely extract user information
    final userId = json['userId'];
    String userIdStr;
    String userName;
    
    if (userId == null) {
      userIdStr = 'unknown';
      userName = 'Unknown';
    } else if (userId is Map) {
      userIdStr = userId['_id']?.toString() ?? 
                  userId['id']?.toString() ?? 
                  userId.toString();
      userName = userId['fullName']?.toString() ?? 
                 userId['name']?.toString() ?? 
                 'Unknown';
    } else {
      userIdStr = userId.toString();
      userName = 'Unknown';
    }

    return Application(
      id: applicationId,
      citizenId: userIdStr,
      citizenName: userName,
      serviceType: ApplicationType.values.firstWhere(
        (e) => e.name == (json['type'] as String? ?? 'birth'),
        orElse: () => ApplicationType.birth,
      ),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'pending'),
        orElse: () => ApplicationStatus.pending,
      ),
      submittedAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      formData: json['payload'] as Map<String, dynamic>? ?? {},
      rejectionReason: json['adminComment'] as String?,
      certificateUrl: json['certificateId']?.toString(),
    );
  }

  /// Submit a new application
  Future<String> submitApplication({
    required User user,
    required ApplicationType type,
    required Map<String, dynamic> formData,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final applicationId = 'APP-${DateTime.now().millisecondsSinceEpoch}';
    final application = Application(
      id: applicationId,
      citizenId: user.id,
      citizenName: user.name,
      serviceType: type,
      status: ApplicationStatus.pending,
      submittedAt: DateTime.now(),
      formData: formData,
      certificateUrl: null,
    );

    _applications.add(application);
    notifyListeners();

    return applicationId;
  }

  String? _adminToken;

  /// Set admin token for API calls
  void setAdminToken(String? token) {
    _adminToken = token;
  }

  /// Approve an application (admin only)
  Future<void> approveApplication(String applicationId) async {
    if (_adminToken == null || _adminToken!.isEmpty) {
      throw Exception('Admin token required');
    }

    // Validate application ID
    if (applicationId.isEmpty) {
      throw Exception('Application ID is missing');
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/admin/applications/$applicationId/approve',
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_adminToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Move application from pending to approved
        final pendingIndex = _pendingApplications.indexWhere(
          (app) => app.id == applicationId,
        );
        if (pendingIndex != -1) {
          final app = _pendingApplications[pendingIndex];
          final approvedApp = app.copyWith(status: ApplicationStatus.approved);
          
          _pendingApplications.removeAt(pendingIndex);
          _approvedApplications.add(approvedApp);
          
          // Update in main list
          final mainIndex = _applications.indexWhere((app) => app.id == applicationId);
          if (mainIndex != -1) {
            _applications[mainIndex] = approvedApp;
          }
          
          notifyListeners();
        }
      } else {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final message =
            body['message'] as String? ?? 'Failed to approve application';
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Error approving application: $e');
      rethrow;
    }
  }

  /// Reject an application (admin only)
  Future<void> rejectApplication(
    String applicationId, {
    String reason = 'Application does not meet requirements',
  }) async {
    if (_adminToken == null || _adminToken!.isEmpty) {
      throw Exception('Admin token required');
    }

    // Validate application ID
    if (applicationId.isEmpty) {
      throw Exception('Application ID is missing');
    }

    // Validate reason
    if (reason.trim().isEmpty) {
      throw Exception('Rejection reason is required');
    }

    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/admin/applications/$applicationId/reject',
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $_adminToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Move application from pending to rejected
        final pendingIndex = _pendingApplications.indexWhere(
          (app) => app.id == applicationId,
        );
        if (pendingIndex != -1) {
          final app = _pendingApplications[pendingIndex];
          final rejectedApp = app.copyWith(
            status: ApplicationStatus.rejected,
            rejectionReason: reason,
          );
          
          _pendingApplications.removeAt(pendingIndex);
          _rejectedApplications.add(rejectedApp);
          
          // Update in main list
          final mainIndex = _applications.indexWhere((app) => app.id == applicationId);
          if (mainIndex != -1) {
            _applications[mainIndex] = rejectedApp;
          }
          
          notifyListeners();
        }
      } else {
        final Map<String, dynamic> body =
            jsonDecode(response.body) as Map<String, dynamic>;
        final message =
            body['message'] as String? ?? 'Failed to reject application';
        throw Exception(message);
      }
    } catch (e) {
      debugPrint('Error rejecting application: $e');
      rethrow;
    }
  }

  /// Get certificate for an application
  Certificate? getCertificateForApplication(String applicationId) {
    try {
      return _certificates.firstWhere(
        (cert) => cert.applicationId == applicationId,
      );
    } catch (e) {
      return null;
    }
  }


  /// Mark notification as read
  void markNotificationAsRead(String notificationId) {
    final index = _notifications.indexWhere(
      (notif) => notif.id == notificationId,
    );
    if (index == -1) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    notifyListeners();
  }

  /// Get unread notifications for user
  List<AppNotification> getUnreadNotifications(String userId) {
    return _notifications
        .where((notif) => notif.userId == userId && !notif.isRead)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get all notifications for user
  List<AppNotification> getNotificationsForUser(String userId) {
    return _notifications.where((notif) => notif.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
