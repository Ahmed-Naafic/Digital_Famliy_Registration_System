import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/certificate_data_model.dart';

/// Birth Certificate Widget
/// Fresh & Trustworthy design with Teal/Soft Blue colors
class BirthCertificateWidget extends StatelessWidget {
  final CertificateData certificate;

  const BirthCertificateWidget({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final details = certificate.details;
    final childName = details['childName'] as String? ?? 'Unknown';
    // Safely parse dateOfBirth
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
    final placeOfBirth = details['placeOfBirth'] as String? ?? '';
    final gender = details['gender'] as String? ?? '';
    final nationality = details['nationality'] as String? ?? 'Somalia';
    final fatherName = details['fatherName'] as String? ?? 'Unknown';
    final motherName = details['motherName'] as String? ?? 'Unknown';
    final weight = details['weight'] as String?;
    final height = details['height'] as String?;

    final dateFormat = DateFormat('MMMM dd, yyyy');
    final issueDateFormat = DateFormat('MMMM dd, yyyy');

    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 248, 246, 246),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 236, 235, 235).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  certificate.type.primaryColor,
                  certificate.type.accentColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Somalia Coat of Arms placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      34,
                      33,
                      33,
                    ).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flag, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Digital Family Registration System',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'BIRTH CERTIFICATE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
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
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Child Focus Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: certificate.type.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: certificate.type.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              certificate.type.icon,
                              color: certificate.type.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                childName.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: certificate.type.primaryColor,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow(
                          'Date of Birth',
                          dateOfBirth != null
                              ? dateFormat.format(dateOfBirth)
                              : 'N/A',
                        ),
                        _buildInfoRow('Place of Birth', placeOfBirth),
                        _buildInfoRow(
                          'Gender',
                          gender.isNotEmpty
                              ? gender[0].toUpperCase() + gender.substring(1)
                              : 'N/A',
                        ),
                        _buildInfoRow('Nationality', nationality),
                        if (weight != null) _buildInfoRow('Weight', weight),
                        if (height != null) _buildInfoRow('Height', height),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Parents Section
                  Row(
                    children: [
                      Expanded(
                        child: _buildParentCard(
                          'Father',
                          fatherName,
                          certificate.type.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildParentCard(
                          'Mother',
                          motherName,
                          certificate.type.accentColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issued on: ${issueDateFormat.format(certificate.issueDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Approved by: ${certificate.issuedBy}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 8,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Approved',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Digital Signature Note
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
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

  Widget _buildParentCard(String role, String name, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            role,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
