import 'package:flutter/material.dart';

/// Certificate Data Model
/// Contains all information needed to display a certificate
class CertificateData {
  final String id;
  final String certificateNumber;
  final String applicationId;
  final CertificateType type;
  final DateTime issueDate;
  final String issuedBy;
  final Map<String, dynamic> details; // Type-specific details
  final String? qrCodeUrl;
  final String? digitalSignatureHash;

  CertificateData({
    required this.id,
    required this.certificateNumber,
    required this.applicationId,
    required this.type,
    required this.issueDate,
    required this.issuedBy,
    required this.details,
    this.qrCodeUrl,
    this.digitalSignatureHash,
  });

  factory CertificateData.fromJson(Map<String, dynamic> json) {
    // Safely parse issueDate
    DateTime issueDate = DateTime.now();
    if (json['issueDate'] != null) {
      try {
        if (json['issueDate'] is String) {
          issueDate = DateTime.parse(json['issueDate'] as String);
        } else if (json['issueDate'] is DateTime) {
          issueDate = json['issueDate'] as DateTime;
        }
      } catch (e) {
        // If parsing fails, use current date
        issueDate = DateTime.now();
      }
    }

    // Safely parse details map and convert any DateTime objects to strings
    Map<String, dynamic> details = {};
    if (json['details'] != null && json['details'] is Map) {
      final detailsMap = json['details'] as Map<String, dynamic>;
      details = Map<String, dynamic>.from(detailsMap);
      
      // Convert any DateTime objects in details to ISO strings
      details.forEach((key, value) {
        if (value is DateTime) {
          details[key] = value.toIso8601String();
        }
      });
    }

    return CertificateData(
      id: json['id']?.toString() ?? '',
      certificateNumber: json['certificateNumber']?.toString() ?? '',
      applicationId: json['applicationId']?.toString() ?? '',
      type: CertificateType.fromString(json['type']?.toString() ?? 'birth'),
      issueDate: issueDate,
      issuedBy: json['issuedBy']?.toString() ?? 'System',
      details: details,
      qrCodeUrl: json['qrCodeUrl']?.toString(),
      digitalSignatureHash: json['digitalSignatureHash']?.toString(),
    );
  }
}

/// Certificate Type Enum with styling information
enum CertificateType {
  birth,
  marriage,
  death,
  divorce;

  static CertificateType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'birth':
        return CertificateType.birth;
      case 'marriage':
        return CertificateType.marriage;
      case 'death':
        return CertificateType.death;
      case 'divorce':
        return CertificateType.divorce;
      default:
        return CertificateType.birth;
    }
  }

  String get displayName {
    switch (this) {
      case CertificateType.birth:
        return 'Birth Certificate';
      case CertificateType.marriage:
        return 'Marriage Certificate';
      case CertificateType.death:
        return 'Death Certificate';
      case CertificateType.divorce:
        return 'Divorce Certificate';
    }
  }

  Color get primaryColor {
    switch (this) {
      case CertificateType.birth:
        return const Color(0xFF14B8A6); // Teal
      case CertificateType.marriage:
        return const Color(0xFF059669); // Deep Green
      case CertificateType.death:
        return const Color(0xFF475569); // Dark Gray/Navy
      case CertificateType.divorce:
        return const Color(0xFF991B1B); // Muted Red/Burgundy
    }
  }

  Color get accentColor {
    switch (this) {
      case CertificateType.birth:
        return const Color(0xFF06B6D4); // Soft Blue
      case CertificateType.marriage:
        return const Color(0xFFD97706); // Gold
      case CertificateType.death:
        return const Color(0xFF1E293B); // Navy
      case CertificateType.divorce:
        return const Color(0xFF7F1D1D); // Burgundy
    }
  }

  IconData get icon {
    switch (this) {
      case CertificateType.birth:
        return Icons.child_care;
      case CertificateType.marriage:
        return Icons.favorite;
      case CertificateType.death:
        return Icons.celebration;
      case CertificateType.divorce:
        return Icons.heart_broken;
    }
  }

  String get watermarkIcon {
    switch (this) {
      case CertificateType.birth:
        return '👶';
      case CertificateType.marriage:
        return '💍';
      case CertificateType.death:
        return '⚰️';
      case CertificateType.divorce:
        return '💔';
    }
  }
}

