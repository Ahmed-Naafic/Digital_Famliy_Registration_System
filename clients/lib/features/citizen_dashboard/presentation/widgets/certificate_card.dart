import 'package:flutter/material.dart';
import '../../../../core/utils/constants.dart';

/// Certificate Card Widget
/// Dark-themed card displaying certificate information
class CertificateCard extends StatelessWidget {
  /// Certificate name/title
  final String name;

  /// Date when certificate was issued
  final String dateIssued;

  /// Status of the certificate
  final String status;

  /// Callback when view button is tapped
  final VoidCallback? onView;

  /// Callback when download button is tapped
  final VoidCallback? onDownload;

  /// Constructor for CertificateCard
  const CertificateCard({
    super.key,
    required this.name,
    required this.dateIssued,
    required this.status,
    this.onView,
    this.onDownload,
  });

  /// Get status color based on status text
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return kSuccessColor;
      case 'pending':
        return Colors.orange;
      case 'expired':
      case 'rejected':
        return kErrorColor;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: kDarkCardColor,
      margin: const EdgeInsets.only(bottom: kDefaultPadding * 0.75),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          children: [
            // Certificate icon
            Container(
              padding: const EdgeInsets.all(kDefaultPadding * 0.75),
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.description,
                color: kPrimaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: kDefaultPadding),
            // Certificate details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: kSubheadingFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        dateIssued,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: kBodyFontSize - 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _getStatusColor(status).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Action buttons
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.white70),
                  onPressed: onView,
                  tooltip: 'View',
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white70),
                  onPressed: onDownload,
                  tooltip: 'Download',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
