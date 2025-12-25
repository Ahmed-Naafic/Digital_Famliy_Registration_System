import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/certificate_data_model.dart';

/// Death Certificate Widget
/// Respectful & Serious design with Dark Gray/Navy colors
class DeathCertificateWidget extends StatelessWidget {
  final CertificateData certificate;

  const DeathCertificateWidget({
    super.key,
    required this.certificate,
  });

  @override
  Widget build(BuildContext context) {
    final details = certificate.details;
    final deceasedName = details['deceasedName'] as String? ?? 'Unknown';
    final nationalId = details['nationalId'] as String? ?? '';
    // Safely parse dates
    DateTime? dateOfBirth;
    if (details['dateOfBirth'] != null) {
      try {
        if (details['dateOfBirth'] is String) {
          dateOfBirth = DateTime.parse(details['dateOfBirth'] as String);
        } else if (details['dateOfBirth'] is DateTime) {
          dateOfBirth = details['dateOfBirth'] as DateTime;
        }
      } catch (e) {
        dateOfBirth = null;
      }
    }

    DateTime? dateOfDeath;
    if (details['dateOfDeath'] != null) {
      try {
        if (details['dateOfDeath'] is String) {
          dateOfDeath = DateTime.parse(details['dateOfDeath'] as String);
        } else if (details['dateOfDeath'] is DateTime) {
          dateOfDeath = details['dateOfDeath'] as DateTime;
        }
      } catch (e) {
        dateOfDeath = null;
      }
    }
    final placeOfDeath = details['placeOfDeath'] as String? ?? '';
    final causeOfDeath = details['causeOfDeath'] as String?;

    final dateFormat = DateFormat('MMMM dd, yyyy');
    final issueDateFormat = DateFormat('MMMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header - Minimal and respectful
          Container(
            decoration: BoxDecoration(
              color: certificate.type.primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Text(
                  'DEATH CERTIFICATE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Certificate No: ${certificate.certificateNumber}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Deceased Information - Primary focus
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: certificate.type.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DECEASED INFORMATION',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: certificate.type.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          deceasedName.toUpperCase(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: certificate.type.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow(
                          'National ID',
                          nationalId.isNotEmpty ? nationalId : 'N/A',
                        ),
                        _buildInfoRow(
                          'Date of Birth',
                          dateOfBirth != null
                              ? dateFormat.format(dateOfBirth)
                              : 'N/A',
                        ),
                        _buildInfoRow(
                          'Date of Death',
                          dateOfDeath != null
                              ? dateFormat.format(dateOfDeath)
                              : 'N/A',
                        ),
                        _buildInfoRow('Place of Death', placeOfDeath),
                        if (causeOfDeath != null && causeOfDeath.isNotEmpty)
                          _buildInfoRow('Cause of Death', causeOfDeath),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Legal Status
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: certificate.type.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: certificate.type.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.verified,
                          color: certificate.type.primaryColor,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status: Deceased',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Legally Recorded',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Authority
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUTHORITY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Approved by: ${certificate.issuedBy}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Registry Officer',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Issued: ${issueDateFormat.format(certificate.issueDate)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Official Record',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: certificate.type.primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Center(
                    child: Text(
                      'Digitally Generated – No Physical Signature Required',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

