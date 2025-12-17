import 'package:flutter/material.dart';

/// Certificate Model
class Certificate {
  final String id;
  final String applicationId;
  final String citizenId;
  final String certificateNumber;
  final DateTime issueDate;
  final String type; // 'Birth', 'Marriage', 'Divorce', 'Death'
  final String pdfUrl; // Placeholder URL for now

  Certificate({
    required this.id,
    required this.applicationId,
    required this.citizenId,
    required this.certificateNumber,
    required this.issueDate,
    required this.type,
    required this.pdfUrl,
  });

  String get displayName {
    return '$type Certificate';
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'birth':
        return Icons.child_care;
      case 'marriage':
        return Icons.favorite;
      case 'death':
        return Icons.celebration;
      case 'divorce':
        return Icons.heart_broken;
      default:
        return Icons.description;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicationId': applicationId,
      'citizenId': citizenId,
      'certificateNumber': certificateNumber,
      'issueDate': issueDate.toIso8601String(),
      'type': type,
      'pdfUrl': pdfUrl,
    };
  }

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] as String,
      applicationId: json['applicationId'] as String,
      citizenId: json['citizenId'] as String,
      certificateNumber: json['certificateNumber'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      type: json['type'] as String,
      pdfUrl: json['pdfUrl'] as String,
    );
  }
}


