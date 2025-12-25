import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/certificate_data_model.dart';

/// Divorce Certificate Widget
/// Clear & Legal design with Muted Red/Burgundy colors
class DivorceCertificateWidget extends StatelessWidget {
  final CertificateData certificate;

  const DivorceCertificateWidget({super.key, required this.certificate});

  @override
  Widget build(BuildContext context) {
    final details = certificate.details;
    final husbandName = details['husbandName'] as String? ?? 'Unknown';
    final wifeName = details['wifeName'] as String? ?? 'Unknown';
    // Safely parse divorceDate
    DateTime? divorceDate;
    if (details['divorceDate'] != null) {
      try {
        if (details['divorceDate'] is String) {
          divorceDate = DateTime.parse(details['divorceDate'] as String);
        } else if (details['divorceDate'] is DateTime) {
          divorceDate = details['divorceDate'] as DateTime;
        }
      } catch (e) {
        divorceDate = null;
      }
    }
    final court = details['court'] as String? ?? '';
    final reasonCode = details['reasonCode'] as String?;

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
                  'DIVORCE CERTIFICATE',
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
                  // Former Couple Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: certificate.type.primaryColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FORMER COUPLE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: certificate.type.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildPersonRow('Former Husband', husbandName),
                        const SizedBox(height: 20),
                        Container(
                          height: 1,
                          color: certificate.type.primaryColor.withOpacity(0.3),
                        ),
                        const SizedBox(height: 20),
                        _buildPersonRow('Former Wife', wifeName),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Divorce Details
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
                        Text(
                          'DIVORCE DETAILS',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: certificate.type.primaryColor,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow(
                          'Divorce Date',
                          divorceDate != null
                              ? dateFormat.format(divorceDate)
                              : 'N/A',
                        ),
                        _buildDetailRow('Court / Authority', court),
                        if (reasonCode != null && reasonCode.isNotEmpty)
                          _buildDetailRow('Reason Code', reasonCode),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Legal Statement
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: certificate.type.primaryColor.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
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
                              Icons.gavel,
                              color: certificate.type.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'LEGAL STATEMENT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: certificate.type.primaryColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'This marriage is legally dissolved.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: certificate.type.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Footer
                  Center(
                    child: Column(
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
                          'Approved by: ${certificate.issuedBy}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
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

  Widget _buildPersonRow(String role, String name) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$role:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            name.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: certificate.type.primaryColor,
              letterSpacing: 0.5,
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
