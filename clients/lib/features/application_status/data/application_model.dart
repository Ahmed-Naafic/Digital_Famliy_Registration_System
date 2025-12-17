import 'package:flutter/material.dart';

/// Application Status Enum
enum ApplicationStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.approved:
        return 'Approved';
      case ApplicationStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case ApplicationStatus.pending:
        return Colors.orange;
      case ApplicationStatus.approved:
        return Colors.green;
      case ApplicationStatus.rejected:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationStatus.pending:
        return Icons.pending;
      case ApplicationStatus.approved:
        return Icons.check_circle;
      case ApplicationStatus.rejected:
        return Icons.cancel;
    }
  }
}

/// Application Type Enum
enum ApplicationType {
  birth,
  marriage,
  divorce,
  death;

  String get displayName {
    switch (this) {
      case ApplicationType.birth:
        return 'Birth Registration';
      case ApplicationType.marriage:
        return 'Marriage Registration';
      case ApplicationType.divorce:
        return 'Divorce Registration';
      case ApplicationType.death:
        return 'Death Registration';
    }
  }

  IconData get icon {
    switch (this) {
      case ApplicationType.birth:
        return Icons.child_care;
      case ApplicationType.marriage:
        return Icons.favorite;
      case ApplicationType.divorce:
        return Icons.heart_broken;
      case ApplicationType.death:
        return Icons.celebration;
    }
  }
}

/// Application Model
class Application {
  final String id;
  final String citizenId;
  final String citizenName;
  final ApplicationType
  serviceType; // Renamed from 'type' to match requirements
  final ApplicationStatus status;
  final DateTime
  submittedAt; // Renamed from 'submittedDate' to match requirements
  final Map<String, dynamic> formData;
  final String? rejectionReason;
  final String?
  certificateUrl; // Renamed from 'certificateId' to match requirements

  Application({
    required this.id,
    required this.citizenId,
    required this.citizenName,
    required this.serviceType,
    required this.status,
    required this.submittedAt,
    required this.formData,
    this.rejectionReason,
    this.certificateUrl,
  });

  // Compatibility getters for existing code
  ApplicationType get type => serviceType;
  DateTime get submittedDate => submittedAt;
  String? get certificateId => certificateUrl;

  Application copyWith({
    String? id,
    String? citizenId,
    String? citizenName,
    ApplicationType? serviceType,
    ApplicationStatus? status,
    DateTime? submittedAt,
    Map<String, dynamic>? formData,
    String? rejectionReason,
    String? certificateUrl,
  }) {
    return Application(
      id: id ?? this.id,
      citizenId: citizenId ?? this.citizenId,
      citizenName: citizenName ?? this.citizenName,
      serviceType: serviceType ?? this.serviceType,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      formData: formData ?? this.formData,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      certificateUrl: certificateUrl ?? this.certificateUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'citizenId': citizenId,
      'citizenName': citizenName,
      'serviceType': serviceType.name,
      'type': serviceType.name, // Keep for backward compatibility
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'submittedDate': submittedAt
          .toIso8601String(), // Keep for backward compatibility
      'formData': formData,
      'rejectionReason': rejectionReason,
      'certificateUrl': certificateUrl,
      'certificateId': certificateUrl, // Keep for backward compatibility
    };
  }

  factory Application.fromJson(Map<String, dynamic> json) {
    return Application(
      id: json['id'] as String,
      citizenId: json['citizenId'] as String,
      citizenName: json['citizenName'] as String,
      serviceType: ApplicationType.values.firstWhere(
        (e) => e.name == (json['serviceType'] ?? json['type']),
        orElse: () => ApplicationType.birth,
      ),
      status: ApplicationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ApplicationStatus.pending,
      ),
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? json['submittedDate'] as String,
      ),
      formData: json['formData'] as Map<String, dynamic>,
      rejectionReason: json['rejectionReason'] as String?,
      certificateUrl:
          json['certificateUrl'] ?? json['certificateId'] as String?,
    );
  }
}
