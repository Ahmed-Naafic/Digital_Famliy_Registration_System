import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/certificate_data_model.dart';

/// Marriage Certificate Widget
/// Elegant & Formal design with Deep Green/Gold colors
class MarriageCertificateWidget extends StatelessWidget {
  final CertificateData certificate;

  const MarriageCertificateWidget({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final details = certificate.details;
    final husbandName = details['husbandName'] as String? ?? 'Unknown';
    final wifeName = details['wifeName'] as String? ?? 'Unknown';
    // Safely parse dateOfMarriage
    DateTime? dateOfMarriage;
    if (details['dateOfMarriage'] != null) {
      try {
        if (details['dateOfMarriage'] is String) {
          dateOfMarriage = DateTime.parse(details['dateOfMarriage'] as String);
        } else if (details['dateOfMarriage'] is DateTime) {
          dateOfMarriage = details['dateOfMarriage'] as DateTime;
        }
      } catch (e) {
        dateOfMarriage = null;
      }
    }
    final placeOfMarriage = details['placeOfMarriage'] as String? ?? '';
    final marriageType = details['marriageType'] as String? ?? 'Civil';

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
          // Header
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
                  'MARRIAGE CERTIFICATE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  height: 2,
                  width: 200,
                  decoration: BoxDecoration(
                    color: certificate.type.accentColor,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 16),
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
                children: [
                  // Couple Section
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
                      children: [
                        _buildPersonRow('Husband', husbandName),
                        const SizedBox(height: 24),
                        Container(
                          height: 1,
                          color: certificate.type.accentColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 24),
                        _buildPersonRow('Wife', wifeName),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Marriage Details
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: certificate.type.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(
                          'Date of Marriage',
                          dateOfMarriage != null
                              ? dateFormat.format(dateOfMarriage)
                              : 'N/A',
                        ),
                        _buildDetailRow('Place of Marriage', placeOfMarriage),
                        _buildDetailRow('Marriage Type', marriageType),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Authorization
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: certificate.type.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified,
                          color: certificate.type.accentColor,
                          size: 12,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Approved by ${certificate.issuedBy}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: certificate.type.primaryColor,
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
                        'Digitally Generated',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonRow(String role, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$role:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: certificate.type.primaryColor,
          ),
        ),
        Expanded(
          child: Text(
            name.toUpperCase(),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: certificate.type.primaryColor,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
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
