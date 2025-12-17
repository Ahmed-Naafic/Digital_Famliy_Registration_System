import 'package:flutter/foundation.dart';
import '../../features/application_status/data/application_model.dart';
import '../../features/certificate_viewer/data/certificate_model.dart';
import '../notifications/notification_model.dart';
import '../../features/auth/data/user_model.dart';

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

  /// Get pending applications (for admin)
  List<Application> getPendingApplications() {
    return _applications
        .where((app) => app.status == ApplicationStatus.pending)
        .toList()
      ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
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

  /// Approve an application (admin only or for testing)
  Future<void> approveApplication(String applicationId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _applications.indexWhere((app) => app.id == applicationId);
    if (index == -1) return;

    final application = _applications[index];

    // Generate certificate URL
    final certificateUrl = _generateCertificateUrl(application);

    // Create certificate
    final certificateId = 'CERT-${DateTime.now().millisecondsSinceEpoch}';
    final certificateNumber = _generateCertificateNumber(
      application.serviceType,
    );
    final certificate = Certificate(
      id: certificateId,
      applicationId: applicationId,
      citizenId: application.citizenId,
      certificateNumber: certificateNumber,
      issueDate: DateTime.now(),
      type: application.serviceType.displayName,
      pdfUrl: certificateUrl,
    );

    _certificates.add(certificate);

    // Update application status and certificate URL
    _applications[index] = application.copyWith(
      status: ApplicationStatus.approved,
      certificateUrl: certificateUrl,
    );

    // Create notification for citizen
    _createNotification(
      userId: application.citizenId,
      title: 'Certificate Ready',
      message: 'Your certificate is ready. You can download it.',
      actionRoute: '/application-status',
    );

    notifyListeners();
  }

  /// Generate certificate URL (simulated - in real app, this would generate actual PDF)
  String _generateCertificateUrl(Application application) {
    // In a real app, this would generate a PDF and return the URL
    // For now, we'll return a simulated URL
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'certificate://${application.id}/$timestamp.pdf';
  }

  /// Reject an application (admin only or for testing)
  Future<void> rejectApplication(
    String applicationId, {
    String reason = 'Application does not meet requirements',
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    final index = _applications.indexWhere((app) => app.id == applicationId);
    if (index == -1) return;

    final application = _applications[index];

    // Update application status
    _applications[index] = application.copyWith(
      status: ApplicationStatus.rejected,
      rejectionReason: reason,
    );

    // Create notification for citizen
    _createNotification(
      userId: application.citizenId,
      title: 'Application Rejected',
      message: 'Your application was rejected.',
      actionRoute: '/application-status',
    );

    notifyListeners();
  }

  /// Generate certificate number
  String _generateCertificateNumber(ApplicationType serviceType) {
    final prefix = serviceType.name.substring(0, 2).toUpperCase();
    final year = DateTime.now().year;
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(
      7,
    );
    return '$prefix-$year-$random';
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

  /// Create a notification
  void _createNotification({
    required String userId,
    required String title,
    required String message,
    String? actionRoute,
  }) {
    final notification = AppNotification(
      id: 'NOTIF-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      title: title,
      message: message,
      createdAt: DateTime.now(),
      actionRoute: actionRoute,
    );

    _notifications.add(notification);
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
